//
//  ChannelCell.m
//  chatBot
//
//  Created by Shivani on 22/06/17.
//  Copyright © 2017 Shivani. All rights reserved.
//

#import "ChannelCell.h"
@import Firebase ;
@interface ChannelCell () <UITextFieldDelegate>

@end

@implementation ChannelCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.CreateNewChannelTextField.delegate = self ;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES ;
}
- (IBAction)createChannelButtonTapped:(id)sender {
    
    NSLog(@"title: %@",self.CreateNewChannelTextField.text);
    
    [self.delegate createChannelDataForNewChannelWithTitle:self.CreateNewChannelTextField.text];
    
}

@end
