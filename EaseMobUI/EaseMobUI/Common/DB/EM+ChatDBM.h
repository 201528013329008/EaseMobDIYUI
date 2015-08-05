//
//  EM+ChatDBM.h
//  EaseMobUI
//
//  Created by 周玉震 on 15/7/23.
//  Copyright (c) 2015年 周玉震. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EM_ChatConversation;
@class EM_ChatLatelyEmoji;

@interface EM_ChatDBM : NSObject

#pragma mark - Conversation
+ (BOOL)insertConversation:(EM_ChatConversation *)conversation;
+ (BOOL)deleteConversation:(EM_ChatConversation *)conversation;
+ (EM_ChatConversation*)queryConversation:(NSString *)chatter;
+ (BOOL)updateConversation:(EM_ChatConversation *)conversation;

#pragma mark - Emoji
+ (BOOL)insertEmoji:(EM_ChatLatelyEmoji *)emoji;
+ (BOOL)deleteEmoji:(EM_ChatLatelyEmoji *)emoji;
+ (NSArray *)queryEmoji;
+ (BOOL)updateEmoji:(EM_ChatLatelyEmoji *)emoji;

@end