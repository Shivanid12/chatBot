//
//  AppDelegate.h
//  chatBot
//
//  Created by Shivani on 22/06/17.
//  Copyright © 2017 Shivani. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;
@import GoogleSignIn ;


@interface AppDelegate : UIResponder <UIApplicationDelegate, GIDSignInDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

