//
//  Notification.h
//  Notification
//
//  Created by Ansel on 16/4/5.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject

@property (nonatomic, readonly, copy)   NSString *name;  //通知名称
@property (nonatomic, readonly, assign) id object;       //谁发出的通知
@property (nonatomic, readonly, copy)   NSDictionary *userInfo; //传递的内容

+ (instancetype)notificationWithName:(NSString *)name object:(id)object;
+ (instancetype)notificationWithName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo;

- (instancetype)initWithName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo;

@end
