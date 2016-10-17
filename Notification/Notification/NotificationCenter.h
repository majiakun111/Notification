//
//  NotificationCenter.h
//  Notification
//
//  Created by Ansel on 16/4/5.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Notification;


@interface NotificationCenter : NSObject

+ (nullable instancetype)defaultCenter;

- (void)addObserver:(nonnull id)observer block:(nullable id)block name:(nullable NSString *)name object:(nullable id)object;
- (void)addObserver:(nonnull id)observer selector:(nonnull SEL)selector name:(nullable NSString *)name object:(nullable id)object;

- (void)postNotification:(nonnull Notification *)notification;
- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object;
- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo;

//针对参数可变, 只会执行selector不会执行block, block不支持参数可变 只支持id类型的数据
- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object firstArgument:(nullable id)firstArgument,...;
- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object argumentList:(nullable NSArray *)argumentList;

- (void)removeObserver:(nonnull id)observer;
- (void)removeObserver:(nonnull id)observer name:(nonnull NSString *)name object:(nullable id)object;

@end
