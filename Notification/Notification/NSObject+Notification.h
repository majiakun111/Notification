//
//  NSObject+Notification.h
//  Notification
//
//  Created by Ansel on 16/4/5.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationCenter.h"
#import "Notification.h"

@interface NSObject (Notification)

- (void)addObserver:(nonnull id)observer block:(nullable id)block name:(nullable NSString *)name object:(nullable id)object;
- (void)addObserver:(nonnull id)observer selector:(nonnull SEL)selector name:(nullable NSString *)name object:(nullable id)object;

- (void)postNotification:(nonnull Notification *)notification;
- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object;
- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo;

- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object firstArgument:(nullable id)firstArgument,...;

- (void)removeObserver:(nonnull id)observer;
- (void)removeObserver:(nonnull id)observer name:(nonnull NSString *)name object:(nullable id)object;

@end
