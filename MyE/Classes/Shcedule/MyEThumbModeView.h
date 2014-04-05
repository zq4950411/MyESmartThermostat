//
//  MyEThumbModeView.h
//  MyE
//
//  Created by Ye Yuan on 3/8/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyEThumbModeViewDelegate;

@interface MyEThumbModeView : UIView {
    id <MyEThumbModeViewDelegate> delegate;
    
    // 本Thumb color view在父scroll view里面的序号，也是在SampleColorArray数组里面的序号，可以作为惟一的编号
    NSInteger _modeId;
    NSString *_title;
    UIColor *_color;//模式的颜色，用于绘制本view的背景
    BOOL _highlited;//用于在高亮和普通之间切换绘制颜色
    BOOL dragging;
    CGPoint touchLocation; // Location of touch in own coordinates (stays constant during dragging).
    
    UILabel *_label;
}
@property (nonatomic) NSInteger modeId;
@property (copy,nonatomic) NSString *title;
@property (retain, nonatomic) UIColor *color;//模式的颜色，用于绘制本view的背景
@property (nonatomic, retain) id <MyEThumbModeViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame Color:(UIColor *)color modeId:(NSInteger)modeId title:(NSString *)title;
- (void)highlight;
- (void)unhighlight;
@end



@protocol MyEThumbModeViewDelegate <NSObject>
@optional
- (void)thumbModeViewWasTapped:(MyEThumbModeView *)tiv;
- (void)thumbModeViewWasDoubleTapped:(MyEThumbModeView *)tiv;
@end

