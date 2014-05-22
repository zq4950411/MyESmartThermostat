//
//  MyEPeriodInforDoughnutView.m
//  MyE
//
//  Created by Ye Yuan on 6/28/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEPeriodInforDoughnutView.h"
#import <QuartzCore/QuartzCore.h>
#import "MyETodayPeriodInforView.h"
#import "MyENext24HrsPeriodData.h"
#import "MyEUtil.h"
@interface MyEPeriodInforDoughnutView(PrivateMethods)
- (void) _doneView;

@end
@implementation MyEPeriodInforDoughnutView
@synthesize delegate;
@synthesize periods = _periods;
@synthesize doughnutViewRadius = _doughnutViewRadius;
@synthesize doughnutCenterOffsetX = _doughnutCenterOffsetX;
@synthesize doughnutCenterOffsetY = _doughnutCenterOffsetY;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.doughnutViewRadius = NEXT24HRS_DOUGHNUT_VIEW_SIZE / 2;//默认的一个值
        //偏移量初始值设置为0.
        self.doughnutCenterOffsetX = 0;
        self.doughnutCenterOffsetY = 0;
    }
    return self;
}
// 此处的Periods数组的元素是MyETodayPeriodData类型对象，所以Today本类时可以直接传入其MyEScheduleTodayData的periods对象，
// 如果对Weekly模块调用此类，就要重构一个类似的由MyETodayPeriodData类型对象构成的数组，才能正确显示。
-(void)setPeriods:(NSArray *)periods {
    _periods = [NSMutableArray array];
    
    /* 下面算法的功能是合并具有相同setpoint的相邻时段，这里不需要
    NSInteger count = [periods count];
    MyETodayPeriodData *spd = [periods objectAtIndex:count-1];//start period
    MyETodayPeriodData *newpd = [spd copy];
    
    NSInteger j = 0;
    while (j < count-1) {
        MyETodayPeriodData *nextpd = [periods objectAtIndex:j];
        if (spd.heating == nextpd.heating && spd.cooling == nextpd.cooling) {
            // 合并进前一个
            newpd.etid = nextpd.etid;
        }
        else {
            [_periods addObject:newpd];
            spd = [periods objectAtIndex:j];
            newpd = [spd copy];
        }
        j++;
    }
    [_periods addObject:newpd];
     */
    // 下面算法的功能是Sleep的两个区段，当setpoint都一样的时候，合并公用一个setpoint提示框，但必须传进来的periods数目大于1.
    NSInteger count = [periods count];
    if(count > 1) {
        for (NSInteger i = 0; i < count - 1; i++) {
            MyENext24HrsPeriodData *pd = [periods objectAtIndex:i];
            [_periods addObject:[pd copy]];
        }
        MyENext24HrsPeriodData *firstpd = [_periods objectAtIndex:0];
        MyENext24HrsPeriodData *lastpd = [periods objectAtIndex:count - 1];
        if (firstpd.heating == lastpd.heating && firstpd.cooling == lastpd.cooling) {
            firstpd.stid = lastpd.stid;
        } else {
            [_periods addObject:lastpd];
        }
    }else if(count == 1){// 如果传递进来的periods数组的数目只等于1，就不需要进行Sleep的两个区段的合并处理。
        MyENext24HrsPeriodData *pd = [periods objectAtIndex:0];
        [_periods addObject:[pd copy]];
    } else {
        NSLog(@"错误，传递进来的periods数组的数目<1");
    }
    [self setNeedsDisplay];
}

 - (void)drawRect:(CGRect)rect
 {
     CGPoint center = CGPointMake(rect.size.width / 2.0 + self.doughnutCenterOffsetX, 
                                  rect.size.height / 2.0 + self.doughnutCenterOffsetY);
     float radius = self.doughnutViewRadius;//MIN(rect.size.width/2, rect.size.height/2);//同心圆外圆外半径
     float perimeter = 2 * M_PI * radius; //同心圆外圆的周长
     float sectorWidth = perimeter / NUM_SECTOR; // 每个sectorView所在矩形的宽度
     float sectorHeight = sectorWidth * SECTOR_ASPECT_RATIO; // 每个sectorView所在矩形的高度，取为宽度的3倍
     
     float middleRadius = (radius - sectorHeight / 2.0f);// Doughunut的中间半径，在半径位置绘制文字
     float width = self.bounds.size.width;
     float height = self.bounds.size.height;
     
     
     UIFont* theFont = [UIFont boldSystemFontOfSize:16];
     CGSize maxSize = CGSizeMake(width, height);
     
     CGContextRef context = UIGraphicsGetCurrentContext();
     // 设置反锯齿效果
     CGContextSetShouldAntialias(context, YES);
     CGContextSetAllowsAntialiasing(context, YES);
     
     // 平移坐标原点到View的中心
     CGContextTranslateCTM(context, center.x, center.y);

     
     /* ===================start of 绘制表盘的白色圆盘背景 dial plate====================================
     CGContextSaveGState(context);

     [[UIColor colorWithRed:0.8 green:0.8 blue:0 alpha:0.4] setFill];
     bPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0, 0) 
                                                          radius:middleRadius 
                                                      startAngle:0 
                                                        endAngle:2*M_PI 
                                                       clockwise:YES];
     [bPath fill];
     CGContextRestoreGState(context);
     // ===================end of 绘制表盘的白色圆盘背景 dial plate==================================== */
     
     
     
     
     
     /* 
     // ----------------- Drawing arc sector  & 绘制两个时段接头处的线段
     float innerRadius = (radius - sectorHeight);// Doughunut的内部半径
     UIBezierPath* bPath;
     for (MyETodayPeriodData *period in self.periods) {
         
         
         // ----------------- Drawing arc sector ----------------------
         CGContextSaveGState(context);
         CGContextSetLineWidth(context, 6.0f);
         [[UIColor blackColor] setStroke];
         
         float margin = 2;//绘制圆环带时，要缩一点，以露出外边的阴影，这是缩的量
         
         MyERGBColorStruct rgbcs = [MyEUtil componetsWithUIColor:period.color];
         [[UIColor colorWithRed:rgbcs.r green:rgbcs.g blue:rgbcs.b alpha:0.88] setFill];
         
         bPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0, 0) 
                                                radius:innerRadius + margin //缩一点，以露出外边的阴影
                                            startAngle:period.etid * ALPHA - M_PI_2
                                              endAngle:period.stid * ALPHA - M_PI_2
                                             clockwise:NO];
         [bPath addArcWithCenter:CGPointMake(0, 0) 
                          radius:radius-  margin //缩一点，以露出外边的阴影
                      startAngle:period.stid * ALPHA - M_PI_2
                        endAngle:period.etid * ALPHA - M_PI_2
                       clockwise:YES];
         
         [bPath fill];
         
         // 绘制两个时段接头处的线段
         bPath = [UIBezierPath bezierPath];
         [bPath moveToPoint:CGPointMake((innerRadius + margin) * cos(period.stid * ALPHA - M_PI_2), 
                                        (innerRadius + margin) * sin(period.stid * ALPHA - M_PI_2))];
         [bPath addLineToPoint:CGPointMake((radius - margin) * cos(period.stid * ALPHA - M_PI_2), 
                                           (radius - margin) * sin(period.stid * ALPHA - M_PI_2))];
         [bPath moveToPoint:CGPointMake((innerRadius + margin) * cos(period.etid * ALPHA - M_PI_2), 
                                        (innerRadius + margin) * sin(period.etid * ALPHA - M_PI_2))];
         [bPath addLineToPoint:CGPointMake((radius - margin) * cos(period.etid * ALPHA - M_PI_2), 
                                           (radius - margin) * sin(period.etid * ALPHA - M_PI_2))];
         [bPath stroke];
         CGContextRestoreGState(context);
     }
     //*/
     for (MyENext24HrsPeriodData *period in self.periods) {
         
         // 取得时段中间半点id,专门取浮点数，可以精确计算角度
         
         float ctid = (period.stid + (period.etid - period.stid)/2.0f);
         if(period.etid < period.stid) {//如果是开始时刻小于结束时刻，此时段就是两个sleep时段合并后的新时段，就重新计算中点
             float periodLentgh = NUM_SECTOR - period.stid + period.etid;
             ctid = period.stid + periodLentgh / 2.0f;
             if(ctid > NUM_SECTOR)
                 ctid = ctid - NUM_SECTOR;
         }
         float angle = ctid * ALPHA - M_PI_2;//时段中心在圆环上的角度
         
         // ----------------- Drawing background filled rectangle ----------------------
         CGContextSaveGState(context);
         [[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.6] setFill];
         
         NSString *string = @"77 / 66";//样本字符串，用于计算背景矩形的的大小
         CGSize stringSize = [string sizeWithFont:theFont
                                constrainedToSize:maxSize
                                    lineBreakMode:NSLineBreakByClipping];
         CGRect bgRect = CGRectMake(middleRadius*cos(angle) - stringSize.width, 
                                    middleRadius*sin(angle) - stringSize.height,
                                    stringSize.width,
                                    stringSize.height);
         UIRectFill(CGRectMake(middleRadius*cos(angle) - stringSize.width/2.0f + 3,//微调了一点 
                               middleRadius*sin(angle) - stringSize.height/2.0f, 
                               bgRect.size.width, bgRect.size.height));
         CGContextRestoreGState(context);
         
         // ----------------- Drawing heating ----------------------
         CGContextSaveGState(context);
         [[UIColor redColor] setFill];
         [[UIColor whiteColor] setStroke];
         
         string = [NSString stringWithFormat:@"%2i", period.heating];
         
         stringSize = [string sizeWithFont:theFont
                         constrainedToSize:maxSize
                             lineBreakMode:NSLineBreakByClipping];
         
         CGRect stringRect = CGRectMake(middleRadius*cos(angle) - stringSize.width, 
                                        middleRadius*sin(angle) - stringSize.height/2.0f,
                                        stringSize.width,
                                        stringSize.height);
         [string drawInRect:stringRect withFont:theFont];
         CGContextRestoreGState(context);
         
         
         // ---------------------- Drawing '/' --------------------------
         CGContextSaveGState(context);
         [[UIColor blackColor] setFill];
         [[UIColor grayColor] setStroke];
         //CGContextSetTextDrawingMode (context, kCGTextFillStroke); // 设置文字绘制模式为空心字
         
         string = [NSString stringWithFormat:@"/"];
         
         
         stringSize = [string sizeWithFont:theFont
                         constrainedToSize:maxSize
                             lineBreakMode:NSLineBreakByClipping];
         
         stringRect = CGRectMake(middleRadius*cos(angle), 
                                 middleRadius*sin(angle) - stringSize.height/2.0f,
                                 stringSize.width,
                                 stringSize.height);
         [string drawInRect:stringRect withFont:theFont];
         
         CGContextRestoreGState(context);
         
         // ---------------------- Drawing Cooling --------------------------
         CGContextSaveGState(context);
         [[UIColor blueColor] setFill];
         [[UIColor whiteColor] setStroke];
         
         string = [NSString stringWithFormat:@"%2i", period.cooling];
         
         
         stringSize = [string sizeWithFont:theFont
                         constrainedToSize:maxSize
                             lineBreakMode:NSLineBreakByClipping];
         stringRect = CGRectMake(middleRadius*cos(angle) + 8, // 后面的数字是留出空间给中间的'/'
                                 middleRadius*sin(angle) - stringSize.height/2.0f,
                                 stringSize.width,
                                 stringSize.height);
         [string drawInRect:stringRect withFont:theFont];
         
         CGContextRestoreGState(context);
     }
 }

#pragma mark -
#pragma mark touch methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self _doneView];
    
}

#pragma mark -
#pragma mark private methods
- (void)_doneView {
    if ([self.delegate respondsToSelector:@selector(didFinishPeriodInforDoughnutView)])
        [self.delegate didFinishPeriodInforDoughnutView];
}

@end
