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
@import Firebase ;

NS_ENUM(int, sectionType)
{
    CreateNewChannelSection = 0,
    CurrentChannelSection
    
};

@interface ChannelListViewController ()<UITextFieldDelegate, ChannelCellProtocol>
@property (nonatomic , weak) NSString *SenderDisplayName ;

@property (nonatomic, strong )NSMutableArray *channelsArray;

@property (nonatomic ,weak) IBOutlet UITextField* channelTextField ;

@property (nonatomic, strong) FIRDatabaseReference *channelReference ;

@property (nonatomic, assign) FIRDatabaseHandle channelRefHandle ;


@end

    
@implementation ChannelListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.channelReference = [FIRDatabaseReference new];
    
    self.channelReference = [[[FIRDatabase database] reference] child:@"channels"];
    
    self.title = @"My Channels" ;
    self.channelsArray = [NSMutableArray new];

    [self observeChannels];
    
  /*  [self.channelsArray addObject:[Channel initWithChannelName:@"Channel 1" andChannelID:101 ]];
    [self.channelsArray addObject:[Channel initWithChannelName:@"Channel 2" andChannelID:102]];
    [self.channelsArray addObject:[Channel initWithChannelName:@"Channel 3" andChannelID:103]] ;
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;*/
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 /*
    [self.channelsArray addObject:[Channel initWithChannelName:@"Channel 1" andChannelID:101 ]];
    [self.channelsArray addObject:[Channel initWithChannelName:@"Channel 2" andChannelID:102]];
    [self.channelsArray addObject:[Channel initWithChannelName:@"Channel 3" andChannelID:103]] ;
    [self.tableView reloadData] ;*/
    
     
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
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
    NSLog(@"----->section %ld",(long)indexPath.section);
    
    if(indexPath.section == CreateNewChannelSection)
    {
        ChannelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewChannelCell"];
       // cell.CreateNewChannelTextField = self.channelTextField ;
        cell.delegate = self ;
        return cell;
        
    }
    ExistingChannelListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExistingCellID" forIndexPath:indexPath];
    
    cell.titleLabel.text = [[self.channelsArray objectAtIndex:indexPath.row] channelName];
    NSLog(@" title text --->  %@",cell.titleLabel.text);
    
    
        return cell ;
}

#pragma mark -Firebase related methods

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

-(void) createChannelDataForNewChannelWithTitle:(NSString *)title
{
    FIRDatabaseReference *tempChannelRef = [[FIRDatabaseReference alloc] init];
    tempChannelRef = [self.channelReference childByAutoId];
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:title forKey:@"name"];
    [tempChannelRef setValue:tempDict];
    
    NSLog(@"logging info ");
    
    
}
-(void)dealloc
{
    if(self.channelRefHandle)
        [self.channelReference removeObserverWithHandle:self.channelRefHandle];
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == CurrentChannelSection)
    {
        Channel *tempChannel = [self.channelsArray objectAtIndex:indexPath.row] ;
        [self performSegueWithIdentifier:@"showChannel" sender:tempChannel];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
