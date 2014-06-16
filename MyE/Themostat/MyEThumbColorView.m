//
//  MyEThumbColorView.m
//  MyE
//
//  Created by Ye Yuan on 3/5/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MyEThumbColorView.h"
#import "MyEUtil.h"

#define DRAG_THRESHOLD 10

float distanceBetweenPoints(CGPoint a, CGPoint b);

@implementation MyEThumbColorView
@synthesize delegate;
@synthesize colorIndex = _colorIndex;
@synthesize color = _color;


- (id)initWithColor:(UIColor *)color {
    self = [super init];
    if (self) {
        [self setUserInteractionEnabled:YES];
        [self setExclusiveTouch:YES];  // block other touches while dragging a thumb view
        _color = color;
        //UIView设置边框
        [[self layer] setCornerRadius:0];// 现在扁平化， 不要圆角了
        [[self layer] setBorderWidth:0.0];
        [[self layer] setBorderColor:[UIColor whiteColor].CGColor];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // store the location of the starting touch so we can decide when we've moved far enough to drag
    touchLocation = [[touches anyObject] locationInView:self];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    // we want to establish a minimum distance that the touch has to move before it counts as dragging,
    // so that the slight movement involved in a tap doesn't cause the frame to move.
    
    CGPoint newTouchLocation = [[touches anyObject] locationInView:self];
    
    // if we're already dragging, do nothing
    if (dragging) {

    }
    
    // if we're not dragging yet, check if we've moved far enough from the initial point to start
    else if (distanceBetweenPoints(touchLocation, newTouchLocation) > DRAG_THRESHOLD) {
        touchLocation = newTouchLocation;
        dragging = YES;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (dragging) {
        dragging = NO;
    } else if ([[touches anyObject] tapCount] == 1) {
        if ([delegate respondsToSelector:@selector(thumbColorViewWasTapped:)])
            [delegate thumbColorViewWasTapped:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

    dragging = NO;

}
//*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
     CGRect bounds = [self bounds];
     
     //create a cglayer and draw the background graphic to it
     CGContextRef context = UIGraphicsGetCurrentContext();
     // 设置反锯齿效果
     CGContextSetShouldAntialias(context, YES);
     CGContextSetAllowsAntialiasing(context, YES);
     
     
     // ========================= 1 绘制矩形  ===============================
     CGContextSaveGState(context);
     CGContextAddRect(context, bounds);
     
     CGContextEOClip(context);
     
     
     CGContextTranslateCTM(context, 0, bounds.size.height);
     CGContextScaleCTM(context, 1, -1);
     CGGradientRef myGradient;
     CGColorSpaceRef myColorspace;
     size_t num_locations = 2;
     CGFloat locations[3] = { 0.0, 0.5, 1.0 };
     
     // 创建一个亮度更低和一个亮度更高的颜色，作为颜色梯度的首位和中间
     // 根据上述颜色，生成一个颜色相同但亮度更低的
     MyEHSVColorStruct hsv;
     [_color getHue:&hsv.hue saturation:&hsv.sat brightness:&hsv.val alpha:&hsv.alpha];
     UIColor *startEndColor = [UIColor colorWithHue:hsv.hue saturation:hsv.sat brightness:hsv.val * 0.8 alpha:hsv.alpha];
     UIColor *middleColor = [UIColor colorWithHue:hsv.hue saturation:hsv.sat brightness:hsv.val * 1.2 > 1.0 ? 1.0: hsv.val * 1.2 alpha:hsv.alpha];
     
     MyERGBColorStruct startEndRGB =[MyEUtil componetsWithUIColor:startEndColor];
     MyERGBColorStruct middleRGB =[MyEUtil componetsWithUIColor:middleColor];
     
     CGFloat components[12] = { startEndRGB.r, startEndRGB.g, startEndRGB.b, startEndRGB.alpha, // Start color
         middleRGB.r, middleRGB.g, middleRGB.b, middleRGB.alpha, // Middle color
         startEndRGB.r, startEndRGB.g, startEndRGB.b, startEndRGB.alpha }; // End color
     
     myColorspace = CGColorSpaceCreateDeviceRGB();
     myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                       locations, num_locations);  
     CGPoint myStartPoint, myEndPoint;
     myStartPoint.x = bounds.origin.x;
     myStartPoint.y = bounds.origin.y;
     myEndPoint.x = bounds.origin.x;
     myEndPoint.y = bounds.origin.y + bounds.size.height;
     CGContextDrawLinearGradient (context, myGradient, myStartPoint, myEndPoint, 0);
     
     CGColorSpaceRelease(myColorspace);
     CGGradientRelease(myGradient);
     CGContextRestoreGState(context);
 }
 //*/
@end



