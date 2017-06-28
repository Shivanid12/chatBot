//
//  ChatViewController.m
//  chatBot
//
//  Created by Shivani on 23/06/17.
//  Copyright © 2017 Shivani. All rights reserved.
//

#import "ChatViewController.h"
@import Photos ;

@interface ChatViewController () <UIImagePickerControllerDelegate>
@property (nonatomic, strong) NSMutableArray *messagesArray ;

 //To hold the message references to the database
@property (nonatomic, strong) FIRDatabaseReference *messageReference ;
@property (nonatomic ,assign) FIRDatabaseHandle newMessageHandle ;

// properties for showing whether the other user is typing or not.
@property (nonatomic ,assign) BOOL isTyping ;
@property (nonatomic ,strong) FIRDatabaseReference *userIsTypingRef ;

// Adding image attachment option
@property (nonatomic ,weak) NSString *imageUrlNotSetKey ;

@end

@implementation ChatViewController

#pragma mark -App lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
// sets the sender ID based on logged in firebase user
    self.senderId = [[[FIRAuth auth] currentUser] uid];
    self.messagesArray = [NSMutableArray new];
    
// setting avatar images to nil
    
    [self.collectionView collectionViewLayout].incomingAvatarViewSize = CGSizeZero ;
    [self.collectionView collectionViewLayout ].outgoingAvatarViewSize = CGSizeZero ;
    
    [self observeMessages];
    
    self.imageUrlNotSetKey = @"NOTSET";
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self observeTyping];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) dealloc
{
    if(self.newMessageHandle)
        [[self.messageReference child:@"messages"] removeObserverWithHandle:self.newMessageHandle];
}

#pragma mark - CollectionView Datasource
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messagesArray objectAtIndex:indexPath.item];
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messagesArray count];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messagesArray objectAtIndex:indexPath.item];
    JSQMessagesBubbleImage * bubbleImageView ;
    if(message.senderId == self.senderId)
    {
        bubbleImageView = [self setupOutgoingMessages];
        
    }
    else
        bubbleImageView = [self setupIncomingMessages];
    return  bubbleImageView ;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil ;
}


#pragma mark - Message Setup
/* 
 * to set up color for incoming message bubble
 */

-(JSQMessagesBubbleImage *)setupIncomingMessages
{
    JSQMessagesBubbleImageFactory *bubbleImageFactory = [JSQMessagesBubbleImageFactory new];
    return [bubbleImageFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    
}

/*
* to set color for outgoing message bubble
 */

-(JSQMessagesBubbleImage *) setupOutgoingMessages
{
    JSQMessagesBubbleImageFactory *bubbleImageFactory = [JSQMessagesBubbleImageFactory new];
    return [bubbleImageFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
}

/* 
 * to create a JSQMessage with the input text and adding to the datasource
 * @param idString unique sender ID for each user
 * @param nameString sender's display name
 * @param textString message text 
 */

-(void) addMessageWithID:(NSString *)idString name:(NSString *)nameString andText:(NSString *)textString
{
    JSQMessage *messageObject = [JSQMessage messageWithSenderId:idString displayName:nameString text:textString];
    [self.messagesArray addObject:messageObject];
    
}

#pragma mark - Message Delegate

-(void) didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    self.messageReference = [self.channelReference child:@"messages"];
    
// to create child reference with a unique ID
    FIRDatabaseReference *itemReference = [self.messageReference childByAutoId];
    
// dictionary representing the message
    NSMutableDictionary *messageDict = [NSMutableDictionary new];
    NSAssert(senderId != nil, @"SenderID passed nil value");
    [messageDict setObject:senderId forKey:@"senderId"];
    
    NSAssert(senderDisplayName != nil, @" sender display name passed nil value");
    [messageDict setObject:senderDisplayName forKey:@"senderDisplayName"];
    
    NSAssert(text !=nil, @"message text passed nil value");
    [messageDict setObject:text forKey:@"text"];
    
// to save value to new child location
    [itemReference setValue:messageDict];
    
// playing sound
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    self.isTyping = NO ;
    [self.userIsTypingRef setValue:@NO];
// to complete the send action and resetting input toolbar to empty
    [self finishSendingMessage];
}

/*
 * observe method to listen to the messages being added
 */

-(void) observeMessages
{
    self.messageReference =[[FIRDatabaseReference alloc] init];
    self.messageReference =  [self.channelReference child:@"messages"];
// query limiting synchronisation to the last 25 messages
    FIRDatabaseQuery *messageQuery = [self.messageReference queryLimitedToLast:25];
    
    self.newMessageHandle = [messageQuery observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *msgData = [[NSDictionary alloc] initWithDictionary:snapshot.value] ;
        if(msgData)
        {
            [self addMessageWithID:[msgData valueForKey:@"senderId"] name:[msgData valueForKey:@"senderDisplayName"] andText:[msgData valueForKey:@"text"]];
            [self finishReceivingMessage];
        }
        else
            NSLog(@" Error loading message");
        
         
    }];
}

/* 
 * to check if the user is typing message 
 */

-(void) textViewDidChange:(UITextView *)textView
{
    [super textViewDidChange:textView];
    self.userIsTypingRef = [FIRDatabaseReference new];
    self.userIsTypingRef = [[self.channelReference child:@"typingIndicator"] child:self.senderId];
    if(![textView.text  isEqual: @""])
    {
        self.isTyping = YES ;
        [self.userIsTypingRef setValue:@YES];
        
    }
    else
    {
        self.isTyping = NO ;
        [self.userIsTypingRef setValue:@NO];
    }
    
    
}

-(void) observeTyping
{
    FIRDatabaseReference *typingIndicatorRef = [FIRDatabaseReference new];
    typingIndicatorRef = [self.channelReference child:@"typingIndicator"];
    self.userIsTypingRef = [typingIndicatorRef child:self.senderId];
    
// to delete typing indicator once the user has logged out
    [self.userIsTypingRef onDisconnectRemoveValue];
    
    FIRDatabaseQuery *userTypingQuery = [FIRDatabaseQuery new];
    userTypingQuery = [[[self.channelReference child:@"typingIndicator"] queryOrderedByValue] queryEqualToValue:@YES];
    [userTypingQuery observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if(snapshot.childrenCount == 1 && self.isTyping)
            return ;
        if(snapshot.childrenCount >0)
            self.showTypingIndicator = YES ;
        else
            self.showTypingIndicator = NO ;
        [self scrollToBottomAnimated:YES];
        
        
    }];

}

#pragma mark - photo messages

/* 
 * method to create database reference to the image a
 * and setting in database
 */
-(NSString *)sendPhotoMessage
{
    FIRDatabaseReference *itemRef = [FIRDatabaseReference new];
    itemRef = [self.messageReference childByAutoId];
    NSMutableDictionary *msgItem = [NSMutableDictionary new];
    [msgItem setObject:self.imageUrlNotSetKey forKey:@"photoUrl"];
    [msgItem setObject:self.senderId forKey:@"senderId"];
    
    [itemRef setValue:msgItem];
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self finishSendingMessage];
    return itemRef.key ;
  
}
/*
 * setting image url
 * @param urlString the url obtained after storing in Firebase storage
 * @param key unique photo message key
 */
-(void) setImageUrl:(NSString *)urlString forPhotoMessageWithKey:(NSString *)key
{
    FIRDatabaseReference *itemRef = [FIRDatabaseReference new];
    itemRef = [self.messageReference child:key];
    [itemRef updateChildValues:@{@"photoUrl": urlString} ];
    
}
/*
 * overriding method to set the image source type.
 */
- (void) didPressAccessoryButton:(UIButton *)sender
{
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.delegate = self ;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera ;
    else
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary ;
    
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSArray *photoReferenceUrl = info[UIImagePickerControllerReferenceURL];
// pulling PHAsset from the photo url
    PHFetchResult *assetArray = [PHAsset fetchAssetsWithALAssetURLs:photoReferenceUrl options:nil];
    PHAsset *asset = [assetArray firstObject];
    
// retrieving the photo's firebase key
    NSString *photoKey = [self sendPhotoMessage];
        if(photoKey)
    {
        

        [asset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
// getting url for the image
            NSURL *imageFileURL = [contentEditingInput fullSizeImageURL];
            
// creating path based on unique ID and current time
            NSString *path = @"\(FIRAuth.auth()?.currentUser?.uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)";
        //    [[[[FIRAuth auth] currentUser] uid]
            
        }] ;
    }
        
    
}

@end
