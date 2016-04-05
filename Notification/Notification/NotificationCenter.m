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

- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object firstArgument:(nullable id)firstArgument,...
{
    __block struct {
        va_list behindArgumentList;
    }argumentListStruct;
    
    if (firstArgument) {// The first argument isn't part of the varargs list, so we'll handle it separately.
        va_start(argumentListStruct.behindArgumentList, firstArgument);// Start scanning for arguments after firstObject.
    }
    
    [self postNotificationName:name object:object firstArgument:firstArgument behindArgumentList:argumentListStruct.behindArgumentList];
    
    if (firstArgument) {
        va_end(argumentListStruct.behindArgumentList);
    }
}

- (void)postNotificationName:(nonnull NSString *)name object:(nullable id)object firstArgument:(nullable id)firstArgument behindArgumentList:(va_list)behindArgumentList
{
    if ([NSThread isMainThread]) {
        [self _postNotificationName:name object:object firstArgument:firstArgument behindArgumentList:behindArgumentList];
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _postNotificationName:name object:object firstArgument:firstArgument behindArgumentList:behindArgumentList];
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

- (void)_postNotificationName:(nonnull NSString *)name object:(nullable id)object firstArgument:(id)firstArgument behindArgumentList:(va_list)behindArgumentList
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
        
        if (firstArgument) {
            [invocation setArgument:&firstArgument atIndex:2];
            [self bindArgumentList:behindArgumentList forInvocation:invocation];
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

- (BOOL)bindArgumentList:(va_list)argumentList forInvocation:(NSInvocation*)invocation
{
    BOOL result = YES;
    
    for (unsigned int index = 3; index < invocation.methodSignature.numberOfArguments; index++) {
        const char* argumentType = [invocation.methodSignature getArgumentTypeAtIndex:index];
        
        switch (argumentType[0]) {
            case 's':
            case 'S':
            case 'c':
            case 'C':
            case 'i':
            case 'I':
            case 'B': {
                int argument = va_arg(argumentList, int);
                [invocation setArgument:&argument atIndex:index];
                break;
            }
            case 'l':
            case 'L': {
                long argument = va_arg(argumentList, long);
                [invocation setArgument:&argument atIndex:index];
                break;
            }
            case 'q':
            case 'Q': {
                long long argument = va_arg(argumentList, long long);
                [invocation setArgument:&argument atIndex:index];
                break;
            }
            case 'f': {
                float argument = va_arg(argumentList, double);
                [invocation setArgument:&argument atIndex:index];
                break;
            }
            case 'd': {
                double argument = va_arg(argumentList, double);
                [invocation setArgument:&argument atIndex:index];
                break;
            }
            case '@': {
                id argument = va_arg(argumentList, id);
                [invocation setArgument:&argument atIndex:index];
                
                break;
            }
            case '^':
            case '*':
            case '#':
            case ':':
            case '[': {
                int* argument = va_arg(argumentList, int*);
                [invocation setArgument:&argument atIndex:index];
                break;
            }
            case '{': {
                if (strcmp(argumentType, @encode(CGPoint)) == 0) {
                    CGPoint argument = va_arg(argumentList, CGPoint);
                    [invocation setArgument:&argument atIndex:index];
                }
                else if (strcmp(argumentType, @encode(CGRect)) == 0) {
                    CGRect argument = va_arg(argumentList, CGRect);
                    [invocation setArgument:&argument atIndex:index];
                }
                else if (strcmp(argumentType, @encode(CGSize)) == 0) {
                    CGSize argument = va_arg(argumentList, CGSize);
                    [invocation setArgument:&argument atIndex:index];
                }
                else {
#ifdef _DEBUG
                    NSLog(@"####:Can't handle argument type (%s)", argumentType);
                    NSLog(@"####:If neccesary, you can add support of this struct type in NotificationCenter");
                    
                    assert(0);
#endif
                    result = NO;
                }
                break;
            }
            default: {
#ifdef _DEBUG
                NSLog(@"####:Can't handle argument type (%s)", argumentType);
                
                assert(0);
#endif
                result = NO;
                break;
            }
        }
    }
    
    return result;
}

@end
