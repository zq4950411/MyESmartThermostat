//
//  MyESectorView.m
//  MyE
//
//  Created by Ye Yuan on 2/3/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyESectorView.h"
#import "MyEUtil.h"


//
// PrivateMethods
// This category provide private APIs for MyESectorView class
//
@interface MyESectorView(PrivateMethods)

- (UIBezierPath *)_drawBezierPath;

// Highlight view's border, better visual effect for testing.
- (void)_highlightBorder;

// 让本view的背景不断进行闪烁
- (void)_backgroundFlash;
@end

@implementation MyESectorView(PrivateMethods)




// 用BezierPath方法来绘制扇形梯形
- (UIBezierPath *)_drawBezierPath
{
    float margin = 0;
    float length = self.bounds.size.height -margin;//本矩形的高度减去margin，设置为扇形梯形的腰长,减去margin的目的是使梯形小一点，能露出外边。
    
    //扇形梯形内圆和本矩形的下边线交点和Y轴的偏移的距离，前面的常数是对偏离距离的微调
    double offsetX = length * sin(ALPHA/2.0);
    
    CGPoint centerOfCC = CGPointMake(self.bounds.size.width/2, _radiusOfCC);
    
    UIBezierPath *bPath = [UIBezierPath bezierPath];
    
    [bPath moveToPoint:CGPointMake(offsetX, length) ];
    
    [bPath addArcWithCenter:centerOfCC 
                     radius:_radiusOfCC - margin //外圆半径减去margin，目的是使梯形小一点，能露出外边
                 startAngle:-ALPHA/2.0 - M_PI_2 //前面的系数1.12是对角度进行了微调
                   endAngle:ALPHA/2.0 - M_PI_2 //前面的系数1.12是对角度进行了微调
                  clockwise:YES];
    
    [bPath addLineToPoint:CGPointMake(self.bounds.size.width-offsetX, length)];
    
    
    [bPath closePath];  
    
    return bPath;
}


- (void)_highlightBorder
{
    CALayer *theLayer= [self layer];
    theLayer.borderColor = [UIColor purpleColor].CGColor;
    theLayer.borderWidth = 1;

}

// 仅用于Today面板的当前时刻所在的Sector的动画
- (void)_backgroundFlash
{
    /*// debug freeze iPhone4 when press Home button on Schedule panel
     // After the debugging in these days, I have confirmed the bug that cause the iPhone4 frozen when press Home button on Schedule panel. In MyESectorView class I used a Core Animation function to make sector view on current time blinks, there is a CALayer's removeAllAnimations method which cause the iPhone4's freezing. 
    if (self.isFlashing) {
        // Fade out the view right away
        [UIView animateWithDuration:2.0
                              delay: 0.0
         //必须有后面这个UIViewAnimationOptionAllowUserInteraction才能在动画是接受用户触摸事件
                            options: UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             [UIView setAnimationRepeatCount: FLT_MAX];
                             self.alpha = 0.6;
                             
                         }
                         completion:^(BOOL finished){
                         }];
    }
    
    else
    {
        // 取消前面的动画
        [self.layer removeAllAnimations];
        self.alpha = 1.0;
    }
    //*/
}
@end



@implementation MyESectorView
@synthesize fillColor = _fillColor;
@synthesize isFlashing = _isFlashing;
@synthesize uid = _uid;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame fillColor:(UIColor *)fillColor radiusOfCC:(CGFloat)radiusOfCC angle:(float)angle uid:(int)index isFlashing:(BOOL)isFlashing
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // 设置view的背景色
        [self setBackgroundColor:[UIColor clearColor]];
        _fillColor = fillColor;
        _radiusOfCC = radiusOfCC;
        _angle = angle;        
        _uid = index;
        
        _path = [self _drawBezierPath];
        
        _isFlashing = isFlashing;
        
        //[self _highlightBorder];
        
        self.clipsToBounds = NO;
    }
    return self;
}

- (void) setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    [self setNeedsDisplay];
}

- (void) setIsFlashing:(BOOL)isFlashing
{
    _isFlashing = isFlashing;
    [self setNeedsDisplay];
}

- (void)viewDidUnload
{
    [self setFillColor:nil];
    [self setDelegate:nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 设置反锯齿效果
    CGContextSetShouldAntialias(context, YES);
    CGContextSetAllowsAntialiasing(context, YES);
    
    CGContextSaveGState(context);
    [self.fillColor setFill];
    [[UIColor colorWithRed:0.79 green:0.79 blue:0.79 alpha:0.6] setStroke];
    CGContextSetLineWidth(context, 1.0);
    
    //为filled path添加阴影，此阴影绘制在此View上，但由filled path占满了整个View，所以看不见了，因此把添加阴影的工作放在添加View到其父View的代码除，直接给整个View添加阴影。
    //CGContextSetShadow(context, CGSizeMake(4*sin(_angle+M_PI_4), 4*cos(_angle+M_PI_4)), 3);

    // 用BezierPath方法来绘制扇形梯形
    [_path fill];
    [_path stroke];
    
    CGContextRestoreGState(context);    
    
    
    /*//////////////////////////////////////////////////////////////////////////////////////
    // 下面测试在每个块上面绘制文字，并且文字能正确旋转。
    CGContextSaveGState(context);
    
    [[UIColor redColor] setFill];
    CGContextSetLineWidth(context, 1.0);
    NSString* string = [NSString stringWithFormat:@"%2i", self.uid+40];
    UIFont* theFont = [UIFont systemFontOfSize:8];
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    CGSize maxSize = CGSizeMake(width, height);
    float angle = -ALPHA/2; // 文字旋转的角度
    
    CGSize stringSize = [string sizeWithFont:theFont
                           constrainedToSize:maxSize
                               lineBreakMode:NSLineBreakByClipping];

    CGRect stringRect = CGRectMake(5, // 调节水平位置，向右移动1点
                                   5 ,
                                   stringSize.width,
                                   stringSize.height);
    
    //进行文字旋转，由于整个view为了使0点指向正上方而旋转了ALPHA/2
    //此处反向旋转ALPHA/2角度，以校正由于父容器MyEDoughnutView为了使0点线垂直而进行的旋转
    CGContextRotateCTM(context, angle);
    [string drawInRect:stringRect withFont:theFont];
    
    CGContextRestoreGState(context);
    
    //-------------------------------------------------------------------
    CGContextSaveGState(context);
    
    [[UIColor blueColor] setFill];
    CGContextSetLineWidth(context, 1.0);
    string = [NSString stringWithFormat:@"%2i", self.uid+50];
    theFont = [UIFont systemFontOfSize:8];
    width = self.bounds.size.width;
    height = self.bounds.size.height;
    maxSize = CGSizeMake(width, height);
    angle = - self.uid*ALPHA -ALPHA/2;
    
    stringSize = [string sizeWithFont:theFont
                           constrainedToSize:maxSize
                               lineBreakMode:NSLineBreakByClipping];
    NSLog(@"STARTX: %f", (width - stringSize.width)/2);
    stringRect = CGRectMake((width - stringSize.width)/2, 
                            stringSize.height * 1.5 ,
                            stringSize.width,
                            stringSize.height);

    // 先把坐标原点移动到第二行文字的中心
    CGContextTranslateCTM(context, stringRect.origin.x + stringRect.size.width/2, stringRect.origin.y + stringRect.size.height/2);
    
    //进行文字旋转
    CGContextRotateCTM(context,  angle);
    
    // 恢复坐标平移变换
    CGContextTranslateCTM(context, -(stringRect.origin.x + stringRect.size.width/2), -(stringRect.origin.y + stringRect.size.height/2));
    
    [string drawInRect:stringRect withFont:theFont];
    
    CGContextRestoreGState(context);
    ///////////////////////////////////////////////////////////////////////////////////////*/
    
    
    [self _backgroundFlash];
    
        
    // 每重绘完成一次，就执行下面动画，使得sector闪烁一次
    CALayer *myLayer = [self layer];
    CABasicAnimation *theAnimation;
    theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
    theAnimation.duration=0.5;
    theAnimation.repeatCount=1;
    theAnimation.autoreverses=YES;
    theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
    theAnimation.toValue=[NSNumber numberWithFloat:0.6];
    [myLayer addAnimation:theAnimation forKey:@"animateOpacity"];
}
   
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event{
    return [_path containsPoint:point];
}

- (BOOL)pointInside:(CGPoint)point{
    return [_path containsPoint:point];
}

#pragma mark -
#pragma mark UIResponder touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _touchLocation = [touch locationInView:self];
    
    // Animate the first touch, "Pulse" the view by scaling up then down.
	[self animateFirstTouchAtPoint:_touchLocation];
    
    CGPoint ap = [self convertPoint:_touchLocation toView:self.delegate];
    [self.delegate handleTouchBeganAtLocation:ap  sectorId:self.uid];
    [self.delegate manageTouches:touches];
    
    _pressAndDrag = NO;

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"SectorView touchesMoved");
    UITouch *touch = [touches anyObject];
    _touchLocation = [touch locationInView:self];
    
    CGPoint ap = [self convertPoint:_touchLocation toView:self.delegate];
    [self.delegate handleTouchMovedAtLocation:ap  sectorId:self.uid];
    [self.delegate manageTouches:touches];
    _pressAndDrag = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {    
    UITouch *touch = [touches anyObject];
    _touchLocation = [touch locationInView:self];
    
    // first check for plain single/double tap, which is only possible if we haven't seen multiple touches
    NSLog(@"==================== SectorView touchesEnded,  [touch tapCount] = %i",[touch tapCount]);

    if ([touch tapCount] < 2) {//有时候单指触摸并拖动结束后，tapCount可能是0或1，不知原因，
        
        // 如果拖动过才发送下面的给delegate，否则不发送
       // if (_pressAndDrag ) {
            CGPoint ap = [self convertPoint:_touchLocation toView:self.delegate];
            [self.delegate handleTouchEndedAtLocation:ap  sectorId:self.uid];
        //}
        
    }
    _pressAndDrag = NO;


    
    [self.delegate manageTouches:touches];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    //做一些清理的工作，比如状态变量恢复，清理对象的使用
    NSLog(@"touch canceld in sector");
    
    // 由于在DoughnutView里面识别了单击和双击，当单双击发生时，此处的touch识别就会执行touchesBegan、touchesMoved，而不会执行touchesEnded而直接进入touchesCancelled，所以可能导致touchesEnded中的本类代理的handleTouchEndedAtLocation函数未被调用，但是前两个touch函数中调用的代理函数已经设置了拖动、涂抹变量，这就会导致以后真正进行拖动涂抹是，选择的modeId不正确的错误，所以这里需要进一步处理
    // touchesCancelled被调用的情况也分为两种，在单双击的时候有可能被调用，在拖动正常时手指到另外的sector时，也有可能被调用（原因未知）
    //*
    UITouch *touch = [touches anyObject];
    _touchLocation = [touch locationInView:self];
//    if([self pointInside:_touchLocation]){
//        NSLog(@"11==================== SectorView touchesCancelled,  [touch tapCount] = %i",[touch tapCount]);
//        CGPoint ap = [self convertPoint:_touchLocation toView:self.delegate];
//        [self.delegate handleTouchCanceledAtLocation:ap  sectorId:self.uid];
//    }
//    else 
    if(![self pointInside:_touchLocation]){
        NSLog(@"22==================== SectorView touchesCancelled,  [touch tapCount] = %i",[touch tapCount]);
        CGPoint ap = [self convertPoint:_touchLocation toView:self.delegate];
        [self.delegate handleTouchEndedAtLocation:ap  sectorId:self.uid];
    }
    //*/

}





#pragma mark -
#pragma mark Animation for self

- (void)growAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	
#define MOVE_ANIMATION_DURATION_SECONDS 0.15
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:MOVE_ANIMATION_DURATION_SECONDS];
    CGAffineTransform originalTransform = [self transform];
	CGAffineTransform transform = CGAffineTransformScale(originalTransform, 1.0f/1.2f, 1.0f/1.2f);
	self.transform = transform	;
	[UIView commitAnimations];
}

- (void)animateFirstTouchAtPoint:(CGPoint)touchPoint {
	/*  
     参考Apple MoveMe例程  https://developer.apple.com/library/ios/#samplecode/MoveMe/Introduction/Intro.html#//apple_ref/doc/uid/DTS40007315
	 "Pulse" the view by scaling up then down.
	 
	 This illustrates using UIView's built-in animation.  We want, though, to animate the same property (transform) twice -- first to scale up, then to shrink.  You can't animate the same property more than once using the built-in animation -- the last one wins.  So we'll set a delegate action to be invoked after the first animation has finished.  It will complete the sequence.
	 */
	
#define GROW_ANIMATION_DURATION_SECONDS 0.15
	
	NSValue *touchPointValue = [NSValue valueWithCGPoint:touchPoint];
	[UIView beginAnimations:nil context:(__bridge void*)touchPointValue];//context 仅用于打包必要的信息，用于在DidStopSelector函数中可以获得这些信息
	[UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
    CGAffineTransform originalTransform = [self transform];
	CGAffineTransform transform = CGAffineTransformScale(originalTransform, 1.2f, 1.2f); //CGAffineTransformMakeScale(1.2f, 1.2f);
	self.transform = transform;
	[UIView commitAnimations];
}


@end
