//
//  UIView+Frame.m
//  DouMiJie
//
//  Created by space bj on 12-6-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (PSCollectionView)

- (CGFloat)left 
{
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat) x 
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top 
{
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat) y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right 
{
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)width 
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width 
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height 
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height 
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

@end
