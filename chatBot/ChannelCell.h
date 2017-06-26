//
//  ChannelCell.h
//  chatBot
//
//  Created by Shivani on 22/06/17.
//  Copyright © 2017 Shivani. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ChannelCellProtocol
@required
-(void)createChannelDataForNewChannelWithTitle:(NSString *)title;
@end

@interface ChannelCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UITextField *CreateNewChannelTextField;

@property (weak, nonatomic) IBOutlet UIButton *createChannelButton;

@property (strong,nonatomic)id<ChannelCellProtocol> delegate;

- (IBAction)createChannelButtonTapped:(id)sender;

@end
