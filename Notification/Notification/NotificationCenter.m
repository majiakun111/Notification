//
//  NotificationCenter.m
//  Notification
//
//  Created by Ansel on 16/4/5.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "NotificationCenter.h"
#import "Notification.h"
#import "BlockDescription.h"

@interface NotificationObserverRecord : NSObject

@property (nonatomic, weak) id object;
@property (nonatomic, weak) id observer;
@property (nonatomic, assign) SEL selector;

@property (nonatomic, strong) BlockDescription *blockDescription;

- (instancetype)initWithObject:(id)object observer:(id)observer block:(id)block;

- (instancetype)initWithObject:(id)object observer:(id)observer selector:(SEL)selector;

@end

@implementation NotificationObserverRecord

- (instancetype)initWithObject:(id)object observer:(id)observer block:(nullable id)block
{
    self = [super init];
    if (self) {
        _object = object;
        _observer = observer;
        
        if (block) {
            _blockDescription = [[BlockDescription alloc] initWithBlock:block];
        }
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
    self.blockDescription = nil;
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

- (void)addObserver:(nonnull id)observer block:(nullable id)block name:(nullable NSString *)name object:(nullable id)object
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
    [self postNotification:notification argumentList:nil];
}

- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object
{
    [self postNotificationName:name object:object userInfo:nil];
}

- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object userInfo:(nullable NSDictionary *)userInfo
{
    [self postNotificationName:name object:object userInfo:userInfo argumentList:nil];
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
    [self postNotificationName:name object:object userInfo:nil argumentList:argumentList];
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

- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object userInfo:(NSDictionary *)userInfo argumentList:(nullable NSArray *)argumentList
{
    Notification *notification = [[Notification alloc] initWithName:name object:object userInfo:userInfo];
    [self postNotification:notification argumentList:argumentList];
}

- (void)postNotification:(Notification *)notification argumentList:(nullable NSArray *)argumentList
{
    if ([NSThread isMainThread]) {
        [self _postNotification:notification argumentList:argumentList];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _postNotification:notification argumentList:argumentList];
        });
    }
}

- (void)_postNotification:(Notification *)notification argumentList:(nullable NSArray *)argumentList
{
    NSMutableArray *notificationObserverRecords = [self.notificationObserverRecordMap objectForKey:[notification name]];
    
    for (NotificationObserverRecord *notificationObserverRecord in notificationObserverRecords) {
        id object = [notificationObserverRecord object];
        if (object != nil && object != [notification object]) {
            continue;
        }
        
        NSInvocation *invocation = nil;
        NSInteger startIndex = 2;
        if (notificationObserverRecord.blockDescription) {
            invocation = [NSInvocation invocationWithMethodSignature:notificationObserverRecord.blockDescription.blockSignature];
            [invocation setTarget:notificationObserverRecord.blockDescription.block];
            startIndex = 1; //block argument 0的符号是”@?”代表block, argument 1不是selector而是第一个参数, 所以setArgument是从1开始, 而不是2.
        } else if (notificationObserverRecord.observer  &&
                   notificationObserverRecord.selector &&
                   [notificationObserverRecord.observer respondsToSelector:notificationObserverRecord.selector]) {
            invocation = [NSInvocation invocationWithMethodSignature:[notificationObserverRecord.observer  methodSignatureForSelector:notificationObserverRecord.selector]];
            [invocation setSelector:notificationObserverRecord.selector];
            [invocation setTarget:notificationObserverRecord.observer];
            startIndex = 2; //SEL argument 0代表self, argument 1是_cmd,
        }
        
        //不管block还是SEL第一个参数是notification
        [invocation setArgument:&notification atIndex:startIndex];
        
        startIndex++;
        
        if (invocation.methodSignature.numberOfArguments - startIndex !=  [argumentList count]) {
            NSAssert(NO, @"参数不匹配");
        }
        
        for (NSInteger index = startIndex; index < invocation.methodSignature.numberOfArguments; index++) {
            id argument = argumentList[index-startIndex];
            [invocation setArgument:&argument atIndex:index];
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
            
            if (currentNotificationObserverRecord.blockDescription) {
                currentNotificationObserverRecord.blockDescription = nil;
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
        
        if (currentNotificationObserverRecord.blockDescription) {
            currentNotificationObserverRecord.blockDescription = nil;
        }
        [notificationObserverRecords removeObjectAtIndex:index];
    }
    
    if ([notificationObserverRecords count] == 0) {
        [self.notificationObserverRecordMap removeObjectForKey:name];
    }
}

@end
