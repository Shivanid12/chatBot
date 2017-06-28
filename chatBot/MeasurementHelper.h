//
//  MeasurementHelper.h
//  chatBot
//
//  Created by Shivani on 28/06/17.
//  Copyright © 2017 Shivani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MeasurementHelper : NSObject

+ (void)sendLoginEvent;
+ (void)sendLogoutEvent;
+ (void)sendMessageEvent;

@end
