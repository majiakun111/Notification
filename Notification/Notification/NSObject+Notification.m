//
//  NSObject+Notification.m
//  Notification
//
//  Created by Ansel on 16/4/5.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "NSObject+Notification.h"

@implementation NSObject (Notification)

- (void)addObserver:(nonnull id)observer block:(nonnull NotificationBlock)block name:(nullable NSString *)name object:(nullable id)object
{
    [[NotificationCenter defaultCenter] addObserver:observer block:block name:name object:object];
}

- (void)addObserver:(nonnull id)observer selector:(nonnull SEL)selector name:(nullable NSString *)name object:(nullable id)object
{
    [[NotificationCenter defaultCenter] addObserver:observer selector:selector name:name object:object];
}

- (void)postNotification:(nonnull Notification *)notification
{
    [[NotificationCenter defaultCenter] postNotification:notification];
}

- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object
{
    [[NotificationCenter defaultCenter] postNotificationName:name object:object];
}

- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo
{
    [[NotificationCenter defaultCenter] postNotificationName:name object:object userInfo:userInfo];
}

- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object firstArgument:(nullable id)firstArgument,...
{
    NSMutableArray* argumentList = [NSMutableArray array];
    va_list arguments;
    if (firstArgument) {
        [argumentList addObject:firstArgument];
        
        va_start(arguments, firstArgument);
        id arg;
        while ((arg = va_arg(arguments, id))) {
            [argumentList addObject:arg];
        }
        
        va_end(arguments);
    }
    
    [[NotificationCenter defaultCenter] postNotificationName:name object:object argumentList:(NSArray *)argumentList];
}

- (void)removeObserver:(nonnull id)observer
{
    [[NotificationCenter defaultCenter] removeObserver:observer];
}

- (void)removeObserver:(nonnull id)observer name:(nonnull NSString *)name object:(nullable id)object
{
    [[NotificationCenter defaultCenter] removeObserver:observer name:name object:object];
}

@end
