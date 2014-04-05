//
//  UIViewExtention.m
//  WallPaper
//
//  Created by penghui on 11-5-30.
//  Copyright 2011 #. All rights reserved.
//

#import "UIViewExtention.h"


@implementation UIView(FindUIViewController)

+ (UIView *)findFirstResponderBeneathView:(UIView *) view
{
    for ( UIView *childView in view.subviews )
    {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder] ) return childView;
        UIView *result = [self findFirstResponderBeneathView:childView];
        if ( result ) return result;
    }
    return nil;
}

- (UIViewController *) firstAvailableUIViewController 
{
    return (UIViewController *)[self traverseResponderChainForUIViewController];
}

- (id) traverseResponderChainForUIViewController 
{
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) 
	{
        return nextResponder;
    } 
	else if ([nextResponder isKindOfClass:[UIView class]]) 
	{
        return [nextResponder traverseResponderChainForUIViewController];
    } 
	else 
	{
        return nil;
    }
}

@end


@implementation UIView (Rendering)

- (UIImage *)imageRepresentation 
{
	UIGraphicsBeginImageContext(self.bounds.size);
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

@end


@implementation UIView (Action)

- (void)hide
{
	self.alpha = 0.0f;
}


- (void)show 
{
	self.alpha = 1.0f;
}


- (void)fadeOut 
{
	UIView *view = self;
	[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
		view.alpha = 0.0f;
	} completion:nil];
}


- (void)fadeOutAndRemoveFromSuperview
{
	UIView *view = self;
	[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
		view.alpha = 0.0f;
	} completion:^(BOOL finished) 
     {
         [view removeFromSuperview];
     }];
}


- (void)fadeIn 
{
	UIView *view = self;
	[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
		view.alpha = 1.0f;
	} completion:nil];
}

@end

@implementation UIView (SuperViewUIViewHierarchy)

- (NSArray *)superviews 
{
	NSMutableArray *superviews = [NSMutableArray array];
	
	UIView *view = self;
	UIView *superview = nil;
	while (view) 
    {
		superview = [view superview];
		if (!superview) 
        {
			break;
		}
		
		[superviews addObject:superview];
		view = superview;
	}
	
	return superviews;
}


- (id)firstSuperviewOfClass:(Class)superviewClass 
{
	UIView *view = self;
	UIView *superview = nil;
	while (view) 
    {
		superview = [view superview];
		if ([superview isKindOfClass:superviewClass]) 
        {
			return superview;
		}		
		view = superview;
	}
	return nil;
}

@end
