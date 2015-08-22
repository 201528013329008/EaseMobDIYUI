//
//  EM+ChatMessageLocationBubble.m
//  EaseMobUI
//
//  Created by 周玉震 on 15/7/21.
//  Copyright (c) 2015年 周玉震. All rights reserved.
//

#import "EM+ChatMessageLocationBody.h"
#import "EM+ChatUIConfig.h"
#import "EM+ChatMessageModel.h"
#import "EM+ChatResourcesUtils.h"

@implementation EM_ChatMessageLocationBody{
    UIImageView *mapView;
    UILabel *addressLabel;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        mapView = [[UIImageView alloc]init];
        mapView.image = [EM_ChatResourcesUtils cellImageWithName:@"location_preview"];
        [self addSubview:mapView];
        
        addressLabel = [[UILabel alloc]init];
        addressLabel.textAlignment = NSTextAlignmentCenter;
        addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
        addressLabel.numberOfLines = 0;
        [self addSubview:addressLabel];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGSize size = self.frame.size;
    
    mapView.bounds = self.bounds;
    mapView.center = CGPointMake(size.width / 2, size.height / 2);
    addressLabel.frame = CGRectMake(mapView.frame.origin.x, mapView.frame.origin.y + (mapView.frame.size.height - 44), mapView.frame.size.width , 44);

}

- (NSMutableDictionary *)userInfo{
    NSMutableDictionary *userInfo = [super userInfo];
    [userInfo setObject:HANDLE_ACTION_LOCATION forKey:kHandleActionName];
    return userInfo;
}

- (void)setMessage:(EM_ChatMessageModel *)message{
    [super setMessage:message];
    
    EMLocationMessageBody *locationBody = (EMLocationMessageBody *)message.messageBody;
    addressLabel.text = locationBody.address;
}

@end