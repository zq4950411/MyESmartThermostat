//
//  MyEThumbColorView.h
//  MyE
//
//  Created by Ye Yuan on 3/5/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MyEThumbColorViewDelegate;

@interface MyEThumbColorView : UIView {
    id <MyEThumbColorViewDelegate> delegate;
    
    // 本Thumb color view在父scroll view里面的序号，也是在SampleColorArray数组里面的序号，可以作为惟一的编号
    NSInteger _colorIndex;
    
    UIColor *_color;
    
    BOOL dragging;
    CGPoint touchLocation; // Location of touch in own coordinates (stays constant during dragging).
}
@property (nonatomic) NSInteger colorIndex;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, retain) id <MyEThumbColorViewDelegate> delegate;

- (id)initWithColor:(UIColor *)color;

@end



@protocol MyEThumbColorViewDelegate <NSObject>

@optional
- (void)thumbColorViewWasTapped:(MyEThumbColorView *)tcv;
@end
