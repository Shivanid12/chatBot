//
//  ChatViewController.m
//  chatBot
//
//  Created by Shivani on 23/06/17.
//  Copyright © 2017 Shivani. All rights reserved.
//

#import "ChatViewController.h"


@interface ChatViewController ()
@property (nonatomic, strong) NSMutableArray *messagesArray ;

 //To hold the
@property (nonatomic, strong) FIRDatabaseReference *messageReference ;
@property (nonatomic ,assign) FIRDatabaseHandle newMessageHandle ;

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
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
@end
