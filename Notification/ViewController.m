//
//  ViewController.m
//  Notification
//
//  Created by Ansel on 16/4/5.
//  Copyright © 2016年 PingAn. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+Notification.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self postNotificationName:@"Test" object:nil userInfo:@{@"name" : @"Ansel"}];
    });
    
    [self postNotificationName:@"PersonInfo" object:nil firstArgument:@"Ansel", @"13809891621", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
