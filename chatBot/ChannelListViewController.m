//
//  ChannelListViewController.m
//  chatBot
//
//  Created by Shivani on 23/06/17.
//  Copyright © 2017 Shivani. All rights reserved.
//

#import "ChannelListViewController.h"
#import "Channel.h"
#import "ChannelCell.h"
#import "ExistingChannelListCell.h"
#import "ChatViewController.h"
@import Firebase ;

NS_ENUM(int, sectionType)
{
    CreateNewChannelSection = 0,
    CurrentChannelSection
    
};

@interface ChannelListViewController ()<UITextFieldDelegate, ChannelCellProtocol>


@property (nonatomic, strong )NSMutableArray *channelsArray;

@property (nonatomic ,weak) IBOutlet UITextField* channelTextField ;
// to store a reference to the list of channels in databse
@property (nonatomic, strong) FIRDatabaseReference *channelReference ;

// to store handle to the channel reference
@property (nonatomic, assign) FIRDatabaseHandle channelRefHandle ;


@end

    
@implementation ChannelListViewController

#pragma mark -view lifecycle methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.channelReference = [FIRDatabaseReference new];
    
    self.channelReference = [[[FIRDatabase database] reference] child:@"channels"];
    self.title = @"My Channels" ;
    self.channelsArray = [NSMutableArray new];

    [self observeChannels];
    
  }

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    if(self.channelRefHandle)
        [self.channelReference removeObserverWithHandle:self.channelRefHandle];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section)
    {
        case CreateNewChannelSection: return 1 ;
            
        case CurrentChannelSection: return [self.channelsArray count];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // section 1: containing create new channel test field + creat button
    if(indexPath.section == CreateNewChannelSection)
    {
        ChannelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewChannelCell"];
        cell.delegate = self ;
        return cell;
        
    }
    // section 2 : contains the channel list
    ExistingChannelListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExistingCellID" forIndexPath:indexPath];
    
    cell.titleLabel.text = [[self.channelsArray objectAtIndex:indexPath.row] channelName];
    NSLog(@" title text --->  %@",cell.titleLabel.text);
    
    return cell ;
}

# pragma meak - table view delegate method
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // to show chat controller on selecting channel
    if(indexPath.section == CurrentChannelSection)
    {
        Channel *tempChannel = [self.channelsArray objectAtIndex:indexPath.row] ;
        [self performSegueWithIdentifier:@"showChannel" sender:tempChannel];
    }
}



#pragma mark -Firebase related methods

/* 
* observe method to listen to new channels being written to the firebase DB
*/
-(void) observeChannels
{
    // creating a channel model and adding to channelsArray
    self.channelRefHandle =
     [self.channelReference observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        NSDictionary *channelData = snapshot.value ;
        NSString *cid = snapshot.key ;
        NSString *cname = channelData[@"name"];
        if(cname && ![cname isEqualToString:@""])
        {
            [self.channelsArray addObject:[Channel initWithChannelName:cname andChannelID:cid]];
            [self.tableView reloadData];
             
        }
        else
            NSLog(@"Sorry could not load data");
        
    }];
}

/*
 * To create new channles and save to firebase db 
  @param title to set the name of the channel
 */
-(void) createChannelDataForNewChannelWithTitle:(NSString *)title
{
    FIRDatabaseReference *tempChannelRef = [[FIRDatabaseReference alloc] init];
    
    // to create a channel with a unique key
    tempChannelRef = [self.channelReference childByAutoId];
    // to create the dictionary to hold channel data
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:title forKey:@"name"];
    // setting name to the channel (saved to firebase automatically)
    [tempChannelRef setValue:tempDict];
    
    NSLog(@"logging info ");
    
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender] ;
    Channel *tempChannel = (Channel *)sender ;
    if(tempChannel)
    {
        ChatViewController *chatVC = [segue destinationViewController];
        chatVC.senderDisplayName = self.SenderDisplayName ;
        chatVC.chatChannel = tempChannel ;
        chatVC.channelReference = [self.channelReference child:tempChannel.channelID];
        
    }
    
}


@end
