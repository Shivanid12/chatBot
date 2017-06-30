//
//  MeasurementHelper.m
//  chatBot
//
//  Created by Shivani on 28/06/17.
//  Copyright © 2017 Shivani. All rights reserved.
//

#import "MeasurementHelper.h"

@import Firebase;

@implementation MeasurementHelper

+ (void)sendLoginEvent
{
    [FIRAnalytics logEventWithName:@"login" parameters:nil];

}

+ (void)sendLogoutEvent
{
    [FIRAnalytics logEventWithName:@"logout" parameters:nil];

}

+ (void)sendMessageEvent
{
    [FIRAnalytics logEventWithName:@"messages" parameters:nil];

    
}

@end
