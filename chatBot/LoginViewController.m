//
//  LoginViewController.m
//  chatBot
//
//  Created by Shivani on 22/06/17.
//  Copyright © 2017 Shivani. All rights reserved.
//

#import "LoginViewController.h"
@import Firebase;

@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *IntroLabel;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (weak, nonatomic) IBOutlet UIButton *AnonymousLoginButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldCentreConstraint;
- (IBAction)AnonymousLoginButtonTapped:(id)sender;

@end

@implementation LoginViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    // TODO add keyboard notification observer
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShowNOtification:) name:UIKeyboardWillShowNotification object:nil ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil ];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    // TODO remove observer for keyboard notification
    
    [[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardWillShowNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:UIKeyboardWillHideNotification];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES ;
}

-(void) keyBoardWillShowNOtification:(NSNotification *)notification
{
   // NSDictionary* info = [notification userInfo];
  //  CGRect kbFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] ;
      self.textFieldCentreConstraint.constant = 0 ;
}

-(void) keyBoardWillHideNotification:(NSNotification *)notification
{
    self.textFieldCentreConstraint.constant = 50 ;
}
- (IBAction)AnonymousLoginButtonTapped:(id)sender {
    
    if( self.emailTextField.text != nil && ![self.emailTextField.text  isEqual: @""])
    {
        // using the Firebase Auth API to sign in anonymously

        [[FIRAuth auth] signInAnonymouslyWithCompletion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            if(error)
            {
            NSLog(@" Error : %@",error.localizedDescription);
            return ;
            }
            [self performSegueWithIdentifier:@"loginToChat" sender:nil];
        }];
        
    }
}
@end
