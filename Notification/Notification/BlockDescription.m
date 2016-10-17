//
//  BlockDescription.m
//  Notification
//
//  Created by Ansel on 2016/10/17.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "BlockDescription.h"

@implementation BlockDescription

- (void)dealloc
{
    _block = nil;
    _blockSignature = nil;
}

- (id)initWithBlock:(id)block
{
    if (self = [super init]) {
        _block = [block copy];
        
        struct BlockLiteral *blockRef = (__bridge struct BlockLiteral *)block;
        _flags = blockRef->flags;
        _size = blockRef->descriptor->size;
        
        if (_flags & BlockDescriptionFlagsHasSignature) {
            void *signatureLocation = blockRef->descriptor;
            signatureLocation += sizeof(unsigned long int);
            signatureLocation += sizeof(unsigned long int);
            
            if (_flags & BlockDescriptionFlagsHasCopyDispose) {
                signatureLocation += sizeof(void(*)(void *dst, void *src));
                signatureLocation += sizeof(void (*)(void *src));
            }
            
            const char *signature = (*(const char **)signatureLocation);
            _blockSignature = [NSMethodSignature signatureWithObjCTypes:signature];
        }
    }
    return self;
}

@end
