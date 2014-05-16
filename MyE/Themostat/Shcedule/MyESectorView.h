//
//  MyESectorView.h
//  MyE
//
//  Created by Ye Yuan on 2/3/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MyEDoughnutView.h"

@interface MyESectorView : UIView
{
    CGFloat _radiusOfCC; // The radius of outer circle of the concentric circle
    CGFloat _angle; // 扇形相对于X轴旋转的角度
    int _uid; // Unique Period id of Half hour, from 0 to 47
    UIBezierPath *_path; //存储当前扇形梯形的外边路径
    
    BOOL _isFlashing;//尽用于Today面板，在sector跨越当前时刻是，这sector要闪烁
    
    BOOL _pressAndDrag; // YES if user press and move one finger on view
    CGPoint _touchLocation;// 记录下触摸的位置
}
@property (retain, nonatomic) UIColor *fillColor;
@property (nonatomic) BOOL isFlashing;
@property (nonatomic) int uid;
@property (weak, nonatomic) MyEDoughnutView *delegate;

- (id)initWithFrame:(CGRect)frame  fillColor:(UIColor *)fillColor radiusOfCC:(CGFloat)radiusOfCC angle:(float)angle uid:(int)index isFlashing:(BOOL)isFlashing delegate:(MyEDoughnutView *)delegate;
- (void) viewDidUnload;

// 判定点point是否在本View的定制曲线范围内。点point必须在本View的坐标系内
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event;
- (BOOL)pointInside:(CGPoint)point;

- (void)animateFirstTouchAtPoint:(CGPoint)touchPoint;
- (void)growAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end
