//
//  BlockDescription.h
//  Notification
//
//  Created by Ansel on 2016/10/17.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import <Foundation/Foundation.h>

struct BlockLiteral {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct block_descriptor {
        unsigned long int reserved;	// NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
    // imported variables
};

typedef NS_ENUM(NSInteger, BlockDescriptionFlags){
    BlockDescriptionFlagsHasCopyDispose = (1 << 25),
    BlockDescriptionFlagsHasCtor = (1 << 26), // helpers have C++ code
    BlockDescriptionFlagsIsGlobal = (1 << 28),
    BlockDescriptionFlagsHasStret = (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    BlockDescriptionFlagsHasSignature = (1 << 30)
};

@interface BlockDescription : NSObject

@property (nonatomic, readonly, assign) BlockDescriptionFlags flags;
@property (nonatomic, readonly, strong) NSMethodSignature *blockSignature;
@property (nonatomic, readonly, assign) unsigned long int size;
@property (nonatomic, readonly, copy) id block; //通用block

- (id)initWithBlock:(id)block;

@end
