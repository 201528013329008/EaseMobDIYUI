//
//  EM+ChatDBM.m
//  EaseMobUI
//
//  Created by 周玉震 on 15/7/23.
//  Copyright (c) 2015年 周玉震. All rights reserved.
//

#import "EM+ChatDBM.h"
#import "EM+ChatDB.h"

@implementation EM_ChatDBM


#pragma mark - MessageDetails
+ (BOOL)insertMessageDetails:(EM_ChatMessageState *)state{
    __block BOOL ret = NO;
    
    [[EM_ChatDB shared] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [EM_DBOPHelper insertInto:[EM_ChatMessageState tableName] WithContent:[state getContentValues] UseDB:db];
    }];
    
    return ret;
}

+ (BOOL)deleteMessageDetails:(EM_ChatMessageState *)state{
    __block BOOL ret = NO;
    
    [[EM_ChatDB shared] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSMutableString *selection = [[NSMutableString alloc]init];
        [selection appendString:MESSAGE_DETAILS_COLUMN_MESSAGE_ID];
        [selection appendString:@" = ? AND "];
        [selection appendString:MESSAGE_DETAILS_COLUMN_BODY_TYPE];
        [selection appendString:@" = ? AND "];
        [selection appendString:MESSAGE_DETAILS_COLUMN_TYPE];
        [selection appendString:@" = ? AND "];
        
        NSArray *args = @[state.messageId,@(state.messageBodyType),@(state.messageType)];
        
        ret = [EM_DBOPHelper deleteFrom:[EM_ChatMessageState tableName] Selection:selection SelArgs:args UseDB:db];
    }];
    
    return ret;
}

+ (BOOL)queryMessageDetails:(EM_ChatMessageState *)state{
    __block BOOL ret = NO;
    
    [[EM_ChatDB shared] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSArray *projects = @[MESSAGE_DETAILS_COLUMN_DETAILS];
        
        NSMutableString *selection = [[NSMutableString alloc]init];
        
        [selection appendString:MESSAGE_DETAILS_COLUMN_MESSAGE_ID];
        [selection appendString:@" = ? AND "];
        [selection appendString:MESSAGE_DETAILS_COLUMN_BODY_TYPE];
        [selection appendString:@" = ? AND "];
        [selection appendString:MESSAGE_DETAILS_COLUMN_TYPE];
        [selection appendString:@" = ? AND "];
        
        NSArray *args = @[state.messageId,@(state.messageBodyType),@(state.messageType)];
        
        FMResultSet *result = [EM_DBOPHelper query:[EM_ChatMessageState tableName] Projects:projects Selection:selection SelArgs:args Order:nil UseDB:db];
        if ([result next]) {
            ret = [result.resultDictionary[MESSAGE_DETAILS_COLUMN_DETAILS] boolValue];
        }else{
            [EM_DBOPHelper insertInto:[EM_ChatMessageState tableName] WithContent:[state getContentValues] UseDB:db];
        }
        [result close];
    }];
    
    return ret;
}

+ (BOOL)updateMessageDetails:(EM_ChatMessageState *)state{
    __block BOOL ret = NO;
    
    [[EM_ChatDB shared] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSDictionary *content = @{MESSAGE_DETAILS_COLUMN_DETAILS:@(state.details)};
        
        NSMutableString *selection = [[NSMutableString alloc]init];
        [selection appendString:MESSAGE_DETAILS_COLUMN_MESSAGE_ID];
        [selection appendString:@" = ? AND "];
        [selection appendString:MESSAGE_DETAILS_COLUMN_BODY_TYPE];
        [selection appendString:@" = ? AND "];
        [selection appendString:MESSAGE_DETAILS_COLUMN_TYPE];
        [selection appendString:@" = ? AND "];
        
        NSArray *args = @[state.messageId,@(state.messageBodyType),@(state.messageType)];
        
        ret = [EM_DBOPHelper update:[EM_ChatMessageState tableName] WithContent:content Selection:selection SelArgs:args UseDB:db];
        
    }];
    
    return ret;
}


#pragma mark - Conversation
+ (BOOL)insertConversation:(EM_ChatConversation *)conversation{
    __block BOOL ret = NO;
    
    [[EM_ChatDB shared] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [EM_DBOPHelper insertInto:[EM_ChatConversation tableName] WithContent:[conversation getContentValues] UseDB:db];
    }];
    
    return ret;
}

+ (BOOL)deleteConversation:(EM_ChatConversation *)conversation{
    __block BOOL ret = NO;
    
    [[EM_ChatDB shared] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSMutableString *selection = [[NSMutableString alloc]init];
        [selection appendString:CONVERSATION_COLUMN_CHATTER];
        [selection appendString:@" = ?"];
        
        NSArray *args = @[conversation.conversationChatter];
        
        ret = [EM_DBOPHelper deleteFrom:[EM_ChatConversation tableName] Selection:selection SelArgs:args UseDB:db];
    }];
    
    return ret;
}

+ (EM_ChatConversation *)queryConversation:(NSString *)chatter{
    __block EM_ChatConversation *ret = nil;
    
    [[EM_ChatDB shared] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSMutableString *selection = [[NSMutableString alloc]init];
        
        [selection appendString:CONVERSATION_COLUMN_CHATTER];
        [selection appendString:@" = ?"];
        
        NSArray *args = @[chatter];
        
        FMResultSet *result = [EM_DBOPHelper query:[EM_ChatConversation tableName] Projects:nil Selection:selection SelArgs:args Order:nil UseDB:db];
        if ([result next]) {
            ret = [[EM_ChatConversation alloc]init];
            [ret getFromResultSet:result.resultDictionary];
        }
        [result close];
    }];
    
    return ret;
}

+ (BOOL)updateConversation:(EM_ChatConversation *)conversation{
    __block BOOL ret = NO;
    
    [[EM_ChatDB shared] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSDictionary *content = @{CONVERSATION_COLUMN_EDITOR:conversation.conversationEditor};
        
        NSMutableString *selection = [[NSMutableString alloc]init];
        [selection appendString:CONVERSATION_COLUMN_CHATTER];
        [selection appendString:@" = ?"];
        
        NSArray *args = @[conversation.conversationChatter];
        
        ret = [EM_DBOPHelper update:[EM_ChatConversation tableName] WithContent:content Selection:selection SelArgs:args UseDB:db];
        
    }];
    
    return ret;
}

#pragma mark - Emoji
+ (BOOL)insertEmoji:(EM_ChatLatelyEmoji *)emoji{
    __block BOOL ret = NO;
    
    [[EM_ChatDB shared] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        ret = [EM_DBOPHelper insertInto:[EM_ChatLatelyEmoji tableName] WithContent:[emoji getContentValues] UseDB:db];
    }];
    
    return ret;
}

+ (BOOL)deleteEmoji:(EM_ChatLatelyEmoji *)emoji{
    __block BOOL ret = NO;
    
    [[EM_ChatDB shared] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSMutableString *selection = [[NSMutableString alloc]init];
        [selection appendString:EMOJI_COLUMN_EMOJI];
        [selection appendString:@" = ?"];
        
        NSArray *args = @[emoji.emoji];
        
        ret = [EM_DBOPHelper deleteFrom:[EM_ChatLatelyEmoji tableName] Selection:selection SelArgs:args UseDB:db];
    }];
    
    return ret;
}

+ (NSArray *)queryEmoji{
    __block NSMutableArray *ret = [[NSMutableArray alloc]init];
    
    [[EM_ChatDB shared] inTransaction:^(FMDatabase *db, BOOL *rollback) {
        FMResultSet *result = [EM_DBOPHelper query:[EM_ChatLatelyEmoji tableName] Projects:nil Selection:nil SelArgs:nil Order:nil UseDB:db];
        while ([result next]) {
            EM_ChatLatelyEmoji *emoji = [[EM_ChatLatelyEmoji alloc]init];
            [emoji getFromResultSet:result.resultDictionary];
            [ret addObject:emoji];
        }
        [result close];
    }];
    
    return ret;
}

@end