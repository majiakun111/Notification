//
//  NotificationCenter.m
//  Notification
//
//  Created by Ansel on 16/4/5.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "NotificationCenter.h"
#import "Notification.h"

@interface NotificationObserverRecord : NSObject

@property (nonatomic, weak) id object;
@property (nonatomic, weak) id observer;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, copy) NotificationBlock block;

- (instancetype)initWithObject:(id)object observer:(id)observer block:(nonnull NotificationBlock)block;

- (instancetype)initWithObject:(id)object observer:(id)observer selector:(SEL)selector;

@end

@implementation NotificationObserverRecord

- (instancetype)initWithObject:(id)object observer:(id)observer block:(nonnull NotificationBlock)block
{
    self = [super init];
    if (self) {
        _object = object;
        _observer = observer;
        _block = [block copy];
    }
    
    return self;
}

- (instancetype)initWithObject:(id)object observer:(id)observer selector:(SEL)selector
{
    self = [super init];
    if (self) {
        _object = object;
        _observer = observer;
        _selector = selector;
    }
    
    return self;
}

- (void)dealloc
{
    self.block = nil;
}

@end

@interface NotificationCenter ()

@property (nonatomic, strong) NSMutableDictionary *notificationObserverRecordMap;

@end

@implementation NotificationCenter

+ (nullable instancetype)defaultCenter
{
    static NotificationCenter *instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == instance) {
            instance = [[NotificationCenter alloc] init];
        }
    });
    
    return instance;
}

- (void)addObserver:(nonnull id)observer block:(nonnull NotificationBlock)block name:(nullable NSString *)name object:(nullable id)object
{
    NSParameterAssert(observer && name && block);
    
    if ([NSThread isMainThread]) {
        NotificationObserverRecord *notificationObserverRecord = [[NotificationObserverRecord alloc] initWithObject:object observer:observer block:block];
        [self _addNotificationObserverRecord:notificationObserverRecord name:name];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NotificationObserverRecord *notificationObserverRecord = [[NotificationObserverRecord alloc] initWithObject:object observer:observer block:block];
            [self _addNotificationObserverRecord:notificationObserverRecord name:name];
        });
    }
}

- (void)addObserver:(nonnull id)observer selector:(nonnull SEL)selector name:(nullable NSString *)name object:(nullable id)object
{
    NSParameterAssert(observer && name && selector);
    
    if ([NSThread isMainThread]) {
        NotificationObserverRecord *notificationObserverRecord = [[NotificationObserverRecord alloc] initWithObject:object observer:observer selector:selector];
        [self _addNotificationObserverRecord:notificationObserverRecord name:name];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NotificationObserverRecord *notificationObserverRecord = [[NotificationObserverRecord alloc] initWithObject:object observer:observer selector:selector];
            [self _addNotificationObserverRecord:notificationObserverRecord name:name];
        });
    }
}

- (void)postNotification:(nonnull Notification *)notification
{
    if ([NSThread isMainThread]) {
        [self _postNotification:notification];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _postNotification:notification];
        });
    }
}

- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object
{
    Notification *notification = [[Notification alloc] initWithName:name object:object userInfo:nil];
    [self postNotification:notification];
}

- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo
{
    Notification *notification = [[Notification alloc] initWithName:name object:object userInfo:userInfo];
    [self postNotification:notification];
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
    
    [self postNotificationName:name object:object argumentList:(NSArray *)argumentList];
}

- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object argumentList:(nullable NSArray *)argumentList
{
    if ([NSThread isMainThread]) {
        [self _postNotificationName:name object:object argumentList:argumentList];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _postNotificationName:name object:object argumentList:argumentList];
        });
    }
}

- (void)removeObserver:(nonnull id)observer
{
    if ([NSThread isMainThread]) {
        [self _removeObserver:observer];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _removeObserver:observer];
        });
    }
}

- (void)removeObserver:(nonnull id)observer name:(nonnull NSString *)name object:(nullable id)object
{
    if ([NSThread isMainThread]) {
        [self _removeObserver:observer name:name object:object];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _removeObserver:observer name:name object:object];
        });
    }
}

#pragma mark - property

- (NSMutableDictionary *)notificationObserverRecordMap
{
    if (nil == _notificationObserverRecordMap) {
        _notificationObserverRecordMap = [[NSMutableDictionary alloc] init];
    }
    
    return _notificationObserverRecordMap;
}

#pragma mark - PrivateMethod

- (void)_addNotificationObserverRecord:(nonnull NotificationObserverRecord *)notificationObserverRecord name:(nonnull NSString *)name
{
    NSMutableArray *notificationObserverRecords = [self.notificationObserverRecordMap objectForKey:name];
    if (notificationObserverRecords == nil) {
        notificationObserverRecords = [NSMutableArray arrayWithObjects:notificationObserverRecord, nil];
        [self.notificationObserverRecordMap setObject:notificationObserverRecords forKey:name];
    }
    else {
        [notificationObserverRecords addObject:notificationObserverRecord];
    }
}

- (void)_postNotification:(nonnull Notification *)notification
{
    NSMutableArray *notificationObserverRecords = [self.notificationObserverRecordMap objectForKey:[notification name]];
    
    for (NotificationObserverRecord *notificationObserverRecord in notificationObserverRecords) {
        id object = [notificationObserverRecord object];
        if (object != nil && object != [notification object]) {
            continue;
        }
        
        if (notificationObserverRecord.block) {
            notificationObserverRecord.block(notification);
        } else if (notificationObserverRecord.selector && [notificationObserverRecord.observer respondsToSelector:notificationObserverRecord.selector]) {
            NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[notificationObserverRecord.observer  methodSignatureForSelector:notificationObserverRecord.selector]];
            [invocation setSelector:notificationObserverRecord.selector];
            [invocation setTarget:notificationObserverRecord.observer];
            
            id argument = notification.userInfo;
            [invocation setArgument:&argument atIndex:2];
            [invocation invoke];
        }
    }
}

- (void)_postNotificationName:(nonnull NSString *)name object:(nullable id)object argumentList:(NSArray *)argumentList
{
    NSMutableArray *notificationObserverRecords = [self.notificationObserverRecordMap objectForKey:name];
    
    for (NotificationObserverRecord *notificationObserverRecord in notificationObserverRecords) {
        if ([notificationObserverRecord object] != nil && object != [notificationObserverRecord object]) {
            continue;
        }
        
        if (![notificationObserverRecord.observer respondsToSelector:notificationObserverRecord.selector]) {
            continue;
        }
        
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[notificationObserverRecord.observer  methodSignatureForSelector:notificationObserverRecord.selector]];
        [invocation setSelector:notificationObserverRecord.selector];
        [invocation setTarget:notificationObserverRecord.observer];
        
        if (argumentList) {
            [self bindArgumentList:argumentList forInvocation:invocation];
        }
        
        [invocation invoke];
    }
}

- (void)_removeObserver:(nonnull id)observer
{
    NSMutableArray *allKeys = (NSMutableArray *)[self.notificationObserverRecordMap allKeys];
    for (NSInteger index = [allKeys count] - 1; index >= 0; index--) {
        NSString *key = [allKeys objectAtIndex:index];
        NSMutableArray *notificationObserverRecords = [self.notificationObserverRecordMap objectForKey:key];
        if (!notificationObserverRecords) {
            continue;
        }
        
        for (NSInteger index = [notificationObserverRecords count]-1; index >= 0; index--) {
            NotificationObserverRecord *currentNotificationObserverRecord = [notificationObserverRecords objectAtIndex:index];
            if (observer != [currentNotificationObserverRecord observer]) {
                continue;
            }
            
            if (currentNotificationObserverRecord.block) {
                currentNotificationObserverRecord.block = nil;
            }
            [notificationObserverRecords removeObjectAtIndex:index];
        }
        
        if ([notificationObserverRecords count] == 0) {
            [self.notificationObserverRecordMap removeObjectForKey:key];
        }
    }
}

- (void)_removeObserver:(nonnull id)observer name:(nonnull NSString *)name object:(nullable id)object
{
    NSMutableArray *notificationObserverRecords = [self.notificationObserverRecordMap objectForKey:name];
    if (!notificationObserverRecords) {
        return;
    }
    
    for (NSInteger index = [notificationObserverRecords count]-1; index >= 0; index--) {
        NotificationObserverRecord *currentNotificationObserverRecord = [notificationObserverRecords objectAtIndex:index];
        
        if (observer != [currentNotificationObserverRecord observer]) {
            continue;
        }
        
        if (object && object != [currentNotificationObserverRecord object]) {
            continue;
        }
        
        if (currentNotificationObserverRecord.block) {
            currentNotificationObserverRecord.block = nil;
        }
        [notificationObserverRecords removeObjectAtIndex:index];
    }
    
    if ([notificationObserverRecords count] == 0) {
        [self.notificationObserverRecordMap removeObjectForKey:name];
    }
}

- (void)bindArgumentList:(NSArray *)argumentList forInvocation:(NSInvocation*)invocation
{
    for (unsigned int index = 2; index < invocation.methodSignature.numberOfArguments; index++) {
        id argument = argumentList[index-2];
        [invocation setArgument:&argument atIndex:index];
    }
}

@end
