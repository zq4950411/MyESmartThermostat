/*
 Copyright (C) <2012> <Wojciech Czelalski/CzekalskiDev>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#define deceleration_multiplier 30.0f

#import <QuartzCore/QuartzCore.h>
#import "CDCircleGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "CDCircle.h"
#import "CDCircleThumb.h"
#import <AudioToolbox/AudioServices.h>
#import "CDCircleOverlayView.h"
#import "Common.h"
@interface CDCircleGestureRecognizer ()
- (float) getTouchAngle:(CGPoint)touch;
- (void) loopRotate;
@property (nonatomic, assign) NSInteger remainingDegree;
@property (nonatomic, weak) NSTimer *autoRotateTimer;
@property (nonatomic, assign) NSInteger loopCounter;

@end

@implementation CDCircleGestureRecognizer

@synthesize rotation = rotation_, controlPoint;
@synthesize ended;
@synthesize currentThumb;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CDCircle *view = (CDCircle *) [self view];
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:view];
    
   // Fail when more than 1 finger detected.
   if ([[event touchesForGestureRecognizer:self] count] > 1 || ([view.path containsPoint:point] == YES )) {
      [self setState:UIGestureRecognizerStateFailed];
   }
    self.ended = NO;

    [view.delegate circleToucheBegan:view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
   if ([self state] == UIGestureRecognizerStatePossible) {
      [self setState:UIGestureRecognizerStateBegan];
   } else {
      [self setState:UIGestureRecognizerStateChanged];
   }

   // We can look at any touch object since we know we 
   // have only 1. If there were more than 1 then 
   // touchesBegan:withEvent: would have failed the recognizer.
   UITouch *touch = [touches anyObject];

   // To rotate with one finger, we simulate a second finger.
   // The second figure is on the opposite side of the virtual
   // circle that represents the rotation gesture.

    CDCircle *view = (CDCircle *) [self view];
    CGPoint center = CGPointMake(CGRectGetMidX([view bounds]), CGRectGetMidY([view bounds]));
    CGPoint currentTouchPoint = [touch locationInView:view];
    CGPoint previousTouchPoint = [touch previousLocationInView:view];
    
    // 计算当前触摸点到圆心的距离，如果用户触摸点离开了圆环而是直接到了圆心，并会最终跨越圆心到其他圆环地方，此时我们就不计算选择的角度，否则在靠近圆心的地方旋转会太大
    CGFloat distance = sqrtf(powf(currentTouchPoint.x-center.x, 2) + powf(currentTouchPoint.y-center.y,2));
    if(distance < 70)return;
    
    
    previousTouchDate = [NSDate date];
    CGFloat angleInRadians = atan2f(currentTouchPoint.y - center.y, currentTouchPoint.x - center.x) - atan2f(previousTouchPoint.y - center.y, previousTouchPoint.x - center.x);
   [self setRotation:angleInRadians];
    currentTransformAngle = atan2f(view.transform.b, view.transform.a);
    
    // 注意angleInRadians的计时方法其实和下面的getTouchAngle函数原理一样
    CGFloat direction = [self getTouchAngle:currentTouchPoint] - [self getTouchAngle:previousTouchPoint];
    
    NSInteger degree = (NSInteger)(180.0 * direction / M_PI);// 两次调用之间旋转过的度数
    if(abs( degree ) < 90)// 限制一次转动的度数，现在会因为异常导致度数跳跃，异常原因似乎是由于计算角度的算法有问题
    [view.delegate circle:view didMoveDegree:degree];
    NSLog(@"touch moved, arc = %f,  旋转的度数=%d", angleInRadians, degree);

    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
   // Perform final check to make sure a tap was not misinterpreted.
   if ([self state] == UIGestureRecognizerStateChanged) {
    NSLog(@"touch ended");
       
       CDCircle *view = (CDCircle *) [self view];
       CGFloat flipintime=0;
       CGFloat angle = 0;
       NSTimeInterval interval = 1;
       if (view.inertiaeffect == YES) {
           CGFloat angleInRadians = atan2f(view.transform.b, view.transform.a) - currentTransformAngle;
           double time = [[NSDate date] timeIntervalSinceDate:previousTouchDate];
           double velocity = angleInRadians/time;
           CGFloat a = deceleration_multiplier;
           
            flipintime = fabs(velocity)/a; 
           
           
           
            angle = (velocity*flipintime)-(a*flipintime*flipintime/2);
           
           
           if (angle>M_PI/2 || (angle<0 && angle<-1*M_PI/2)) {
               if (angle<0) {
                   angle =-1 * M_PI/2.1f;
               }    
               else { angle = M_PI/2.1f; }
               
               flipintime = 1/(-1*(a/2*velocity/angle));
           }

       }
       
       
//       NSLog(@"--------计时开始, 次数:%d, 间隔=%f",self.loopCounter, (flipintime/fabs(angle)));
       self.remainingDegree = (NSInteger)(angle * 180 / M_PI);
       self.loopCounter = (NSInteger)fabs(self.remainingDegree);
       interval = flipintime/self.loopCounter;
       

       self.autoRotateTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                        target:self
                                      selector:@selector(loopRotate)
                                      userInfo:Nil
                                       repeats:YES];
              
       [UIView animateWithDuration:flipintime delay:0.f options:UIViewAnimationCurveEaseOut animations:^{
           [view setTransform:CGAffineTransformRotate(view.transform,angle)];

       } completion:^(BOOL finished) {
           for (CDCircleThumb *thumb in view.thumbs) {
               
               
               CGPoint point = [thumb convertPoint:thumb.centerPoint toView:nil];
               CDCircleThumb *shadow = view.overlayView.overlayThumb;
               CGRect shadowRect = [shadow.superview convertRect:shadow.frame toView:nil];
               
               if (CGRectContainsPoint(shadowRect, point) == YES) {
                   CGPoint pointInShadowRect = [thumb convertPoint:thumb.centerPoint toView:shadow];
                   if (CGPathContainsPoint(shadow.arc.CGPath, NULL, pointInShadowRect, NULL)) {
                       CGAffineTransform current = view.transform;
                   
                       
                    CGFloat deltaAngle= - degreesToRadians(180) + atan2(view.transform.a, view.transform.b) + atan2(thumb.transform.a, thumb.transform.b);

                       
                        [UIView animateWithDuration:0.2f animations:^{
                       [view setTransform:CGAffineTransformRotate(current, deltaAngle)];
                        }];
                       
                       
                       
                       
                       

//                       SystemSoundID soundID;
//                       NSString *filePath = [[NSBundle mainBundle] pathForResource:@"iPod Click" ofType:@"aiff"];
//                       NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
//                       AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileUrl, &soundID);
//                       AudioServicesPlaySystemSound(soundID);
                       
                       [currentThumb.iconView setIsSelected:NO];
                       [thumb.iconView setIsSelected:YES];
                       self.currentThumb = thumb;
                       //Delegate method
                       [view.delegate circle:view didMoveToSegment:thumb.tag thumb:thumb];
                       self.ended = YES;
                       break;
                   }
                   
               }            
           };
       }];


       currentTransformAngle = 0;
       
       
              
     [self setState:UIGestureRecognizerStateEnded];  
       
   } else {
      [self setState:UIGestureRecognizerStateFailed];
   }
}



- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
   [self setState:UIGestureRecognizerStateFailed];
}

- (float)getTouchAngle:(CGPoint)touch {
    
    // Translate into cartesian space with origin at the center of a 320-pixel square
    // 现在修改成240-pixel的正方形, 就是Circle的外接矩形
    float x = touch.x - 120;
    float y = -(touch.y - 120);
    
    // Take care not to divide by zero!
    if (y == 0) {
        if (x > 0) {
            return M_PI_2;
        }
        else {
            return 3 * M_PI_2;
        }
    }
    
    float arctan = atanf(x/y);
    
    // Figure out which quadrant we're in
    
    // Quadrant I
    if ((x >= 0) && (y > 0)) {
        return arctan;
    }
    // Quadrant II
    else if ((x < 0) && (y > 0)) {
        return arctan + 2 * M_PI;
    }
    // Quadrant III
    else if ((x <= 0) && (y < 0)) {
        return arctan + M_PI;
    }
    // Quadrant IV
    else if ((x > 0) && (y < 0)) {
        return arctan + M_PI;
    }
    
    return -1;
}

- (void) loopRotate{
    
    
    if (self.loopCounter <= 0) {
        if([self.autoRotateTimer isValid]){
            [self.autoRotateTimer invalidate];
        }
        self.autoRotateTimer = nil;
    } else {
        CDCircle *view = (CDCircle *) [self view];
        if(self.remainingDegree < 0)
            [view.delegate circle:view didMoveDegree:-1];
        else
            [view.delegate circle:view didMoveDegree:1];
    }
    self.loopCounter --;
//    NSLog(@"定时函数里面: self.loopCounter=%d, self.remainingDegree=%d",self.loopCounter, self.remainingDegree);
}
@end
