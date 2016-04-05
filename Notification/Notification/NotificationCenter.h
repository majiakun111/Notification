//
//  NotificationCenter.h
//  Notification
//
//  Created by Ansel on 16/4/5.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Notification;

typedef  void (^NotificationBlock)(Notification * _Nonnull notification);

@interface NotificationCenter : NSObject

+ (nullable instancetype)defaultCenter;

- (void)addObserver:(nonnull id)observer block:(nonnull NotificationBlock)block name:(nullable NSString *)name object:(nullable id)object;

- (void)postNotification:(nonnull Notification *)notification;
- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object;
- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo;

- (void)removeObserver:(nonnull id)observer;
- (void)removeObserver:(nonnull id)observer name:(nonnull NSString *)name object:(nullable id)object;

@end
