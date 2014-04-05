//
//  UISegmentedControl+Extension.m
//  MyE
//
//  Created by Ye Yuan on 4/11/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "UISegmentedControl+Extension.h"

@implementation UISegmentedControl (Extension)
-(void)setTag:(NSInteger)tag forSegmentAtIndex:(NSUInteger)segment {
    [[[self subviews] objectAtIndex:segment] setTag:tag];
}

-(void)setTintColor:(UIColor*)color forTag:(NSInteger)aTag {
    // must operate by tags.  Subview index is unreliable
    UIView *segment = [self viewWithTag:aTag];
    
    // UISegment is an undocumented class, so tread carefully
    // if the segment exists and if it responds to the setTintColor message
    if (segment && ([segment respondsToSelector:@selector(setTintColor:)])) {
        [segment performSelector:@selector(setTintColor:) withObject:color];
    }
}

-(void)setTextColor:(UIColor*)color forTag:(NSInteger)aTag {
    UIView *segment = [self viewWithTag:aTag];
    for (UIView *view in segment.subviews) {
        
        // if the sub view exists and if it responds to the setTextColor message
        if (view && ([view respondsToSelector:@selector(setTextColor:)])) {
            [view performSelector:@selector(setTextColor:) withObject:color];
        }
    }
}

-(void)setShadowColor:(UIColor*)color forTag:(NSInteger)aTag {
    
    // you probably know the drill by now
    // you could also combine setShadowColor and setTextColor
    UIView *segment = [self viewWithTag:aTag];
    for (UIView *view in segment.subviews) {
        if (view && ([view respondsToSelector:@selector(setShadowColor:)])) {
            [view performSelector:@selector(setShadowColor:) withObject:color];
        }
    }
}

@end
