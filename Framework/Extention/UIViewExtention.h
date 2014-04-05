//
//  UIViewExtention.h
//  WallPaper
//
//  Created by penghui on 11-5-30.
//  Copyright 2011 #. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIView(FindUIViewController)

+ (UIView *)findFirstResponderBeneathView:(UIView *) view;
- (UIViewController *) firstAvailableUIViewController;
- (id) traverseResponderChainForUIViewController;

@end


@interface UIView (Rendering)

- (UIImage *)imageRepresentation;

@end

@interface UIView (Action)

- (void)hide;
- (void)show;
- (void)fadeOut;
- (void)fadeOutAndRemoveFromSuperview;
- (void)fadeIn;

@end


@interface UIView (SuperViewUIViewHierarchy)
- (NSArray *)superviews;
- (id)firstSuperviewOfClass:(Class)superviewClass;

@end