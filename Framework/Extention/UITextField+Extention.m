//
//  UITextField+Extention.m
//  明信片
//
//  Created by space bj on 12-12-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <objc/runtime.h>
#import "UITextField+Extention.h"


// 定义存取的Key
static const char *contextKey = "contextKey";

@implementation UITextField (Extention)

// get方法
- (int) context 
{
    NSNumber *number = objc_getAssociatedObject(self, contextKey);
    return number.intValue;
}
// set方法
- (void) setContext:(int) context 
{
    objc_setAssociatedObject(self, contextKey, [NSNumber numberWithInt:context], OBJC_ASSOCIATION_ASSIGN);
}

@end
