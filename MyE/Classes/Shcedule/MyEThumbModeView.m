//
//  MyEThumbModeView.m
//  MyE
//
//  Created by Ye Yuan on 3/8/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MyEThumbModeView.h"
#import "MyEUtil.h"


#define DRAG_THRESHOLD 10
#define MARK_CIRCLE_RADIUS 5.0f


float distanceBetweenPoints(CGPoint a, CGPoint b);
@interface MyEThumbModeView(PrivateMethods)
- (void)_handleSingleTap;
- (void)_handleDoubleTap;
@end

@implementation MyEThumbModeView
@synthesize delegate;
@synthesize modeId = _modeId;
@synthesize title = _title, color = _color;


- (id)initWithFrame:(CGRect)frame Color:(UIColor *)color  modeId:(NSInteger)modeId title:(NSString *)title {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:YES];
        [self setExclusiveTouch:YES];  // block other touches while dragging a thumb view
        //self.backgroundColor = color;
        _modeId = modeId;
        _title = [title copy];
        _color = color;
        
        _highlited = NO;
        
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        [_label setTextAlignment:UITextAlignmentCenter];
        _label.font = [UIFont boldSystemFontOfSize:12.0f];
        _label.minimumFontSize = 8.0f;
        _label.adjustsFontSizeToFitWidth = YES;
        _label.lineBreakMode = UILineBreakModeMiddleTruncation;
        _label.text = self.title;
        _label.backgroundColor = [UIColor clearColor];
        [self addSubview:_label];
        
        //UIView设置边框
        [[self layer] setCornerRadius:2];
        [[self layer] setBorderWidth:0.0];
        [[self layer] setBorderColor:[UIColor greenColor].CGColor];
        
        [self setNeedsDisplay];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    if (_title != title) {
        _title = [title copy];
        //[self setNeedsDisplay];
        _label.text = self.title;
    }
}
- (void)setColor:(UIColor *)color {
    if (_color != color) {
        _color = color;
        [self setNeedsDisplay];
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"thumb mode view touch began=============");
    // store the location of the starting touch so we can decide when we've moved far enough to drag
    touchLocation = [[touches anyObject] locationInView:self];
    
    // cancel any pending handleSingleTap messages 
    if ([[touches anyObject] tapCount] == 2)
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"thumb mode view touch moved =============");
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
//    NSLog(@"ended=============");
    // first check for plain single/double tap, which is only possible if we haven't seen multiple touches


    
    if (dragging) {
        dragging = NO;
    } else if ([[touches anyObject] tapCount] == 1) {
        [self performSelector:@selector(_handleSingleTap:) withObject:touches afterDelay:DOUBLE_TAP_DELAY];
        
    } else if([[touches anyObject] tapCount] == 2) {
        [self _handleDoubleTap];
        
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    dragging = NO;
}
- (void)_handleSingleTap:(NSSet *)touches {
    if ([delegate respondsToSelector:@selector(thumbModeViewWasTapped:)])
        [delegate thumbModeViewWasTapped:self];
}
- (void)_handleDoubleTap {
    if ([delegate respondsToSelector:@selector(thumbModeViewWasDoubleTapped:)])
        [delegate thumbModeViewWasDoubleTapped:self];
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
     [self.color getHue:&hsv.hue saturation:&hsv.sat brightness:&hsv.val alpha:&hsv.alpha];
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
     
     
     //如果选中，在右上角绘制一个远点
     if(_highlited) {
         CGContextSaveGState(context);
         [[UIColor redColor] setFill];
         [[UIColor greenColor] setStroke];
         CGContextSetLineWidth(context, 2);
         CGFloat radius = MARK_CIRCLE_RADIUS; // 圆半径
         CGFloat margin = 2.0f; // 圆距离边界的距离
         CGFloat cx = bounds.size.width - radius - margin;
         CGFloat cy = margin + radius;
         UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:CGPointMake(cx, cy) radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
         [circle fill];
         [circle stroke];
         CGContextRestoreGState(context);
     }
}
- (void)highlight
{
    _highlited = YES;
    [[self layer] setBorderWidth:2.0];
    _label.textColor = [UIColor redColor];
    CGRect labelRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width- MARK_CIRCLE_RADIUS, self.bounds.size.height);
    _label.frame = labelRect;
    [self setNeedsDisplay];
    
    // Fade out the view right away
    [UIView animateWithDuration:2.0
                          delay: 0.0
     //必须有后面这个UIViewAnimationOptionAllowUserInteraction才能在动画是接受用户触摸事件
                        options: UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         [UIView setAnimationRepeatCount: FLT_MAX];
                         _label.alpha = 1.0;

                     }
                     completion:^(BOOL finished){
                         // Wait one second and then fade in the view
                         [UIView animateWithDuration:2.0
                                               delay: 2.0
                          //必须有后面这个UIViewAnimationOptionAllowUserInteraction才能在动画是接受用户触摸事件
                                             options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              [UIView setAnimationRepeatCount: FLT_MAX];
                                              _label.alpha = 0.4;
                                          }
                                          completion:nil];
                     }];

}
- (void)unhighlight
{
    _highlited = NO;
    [[self layer] setBorderWidth:0.0];
    _label.frame = self.bounds;
    [self setNeedsDisplay];
    
    // 取消前面的动画
    [_label.layer removeAllAnimations];
    _label.alpha = 1.0;
    _label.textColor = [UIColor blackColor];
}

@end




