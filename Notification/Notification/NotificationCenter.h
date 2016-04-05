//
//  NotificationCenter.h
//  Notification
//
//  Created by Ansel on 16/4/5.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Notification;

typedef  void (^NotificationBlock)(Notification * _Nonnull notification);

@interface NotificationCenter : NSObject

+ (nullable instancetype)defaultCenter;

- (void)addObserver:(nonnull id)observer block:(nonnull NotificationBlock)block name:(nullable NSString *)name object:(nullable id)object;
- (void)addObserver:(nonnull id)observer selector:(nonnull SEL)selector name:(nullable NSString *)name object:(nullable id)object;

- (void)postNotification:(nonnull Notification *)notification;
- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object;
- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo;

//针对参数可变, 只会执行selector不会执行block, block不支持参数可变
- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object firstArgument:(nullable id)firstArgument,...;
- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object firstArgument:(nullable id)firstArgument behindArgumentList:(va_list)behindArgumentList;

- (void)removeObserver:(nonnull id)observer;
- (void)removeObserver:(nonnull id)observer name:(nonnull NSString *)name object:(nullable id)object;

@end
