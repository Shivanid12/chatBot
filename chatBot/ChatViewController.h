//
//  ChatViewController.h
//  chatBot
//
//  Created by Shivani on 23/06/17.
//  Copyright © 2017 Shivani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>
#import "Channel.h"
@import Firebase ;



@interface ChatViewController : JSQMessagesViewController<JSQMessagesCollectionViewDataSource>


@property (nonatomic , strong) FIRDatabaseReference *channelReference ;
@property (nonatomic ,strong) Channel *chatChannel;

@end
