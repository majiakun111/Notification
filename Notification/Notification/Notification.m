//
//  Notification.m
//  Notification
//
//  Created by Ansel on 16/4/5.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "Notification.h"

@implementation Notification

+ (instancetype)notificationWithName:(NSString *)name object:(id)object
{
    return [[[self class] alloc] initWithName:name object:object userInfo:nil];
}

+ (instancetype)notificationWithName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo
{
    return [[[self class] alloc] initWithName:name object:object userInfo:userInfo];
}

- (instancetype)initWithName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _object = object;
        _userInfo = [userInfo copy];
    }
    
    return self;
}

@end
