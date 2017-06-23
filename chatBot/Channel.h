//
//  Channel.h
//  chatBot
//
//  Created by Shivani on 22/06/17.
//  Copyright © 2017 Shivani. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Channel : NSObject

@property (nonatomic, weak) NSString* channelID ;
@property (nonatomic , weak) NSString *channelName ;

+(instancetype) initWithChannelName:(NSString *)name andChannelID:(NSString * )cid ;
@end
