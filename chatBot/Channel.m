//
//  Channel.m
//  chatBot
//
//  Created by Shivani on 22/06/17.
//  Copyright © 2017 Shivani. All rights reserved.
//

#import "Channel.h"

@implementation Channel

+(instancetype) initWithChannelName:(NSString *)name andChannelID:(NSString * )cid
{
    Channel *channelObject = [Channel new];
    channelObject.channelName = name ;
    channelObject.channelID = cid ;
    
    return channelObject;
    
}


@end
