//
//  MyEWeeklyDaySelectionView.m
//  MyE
//
//  Created by Ye Yuan on 6/24/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEWeeklyDaySelectionView.h"
#import "MyECheckBoxView.h"



#define INFO_LABEL_HEIGHT 20.0
#define VERTICAL_GAP 5.0
#define BOTTOM_VIEW_HEIGHT 254

@interface MyEWeeklyDaySelectionView(PrivateMethods)
- (void) _daySelectionCancel;
- (void) _daySelectionDone;
@end


@implementation MyEWeeklyDaySelectionView
@synthesize delegate;
@synthesize currentWeekdayIndex = _currentWeekdayIndex;



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - BOTTOM_VIEW_HEIGHT, frame.size.width, BOTTOM_VIEW_HEIGHT)];
        [_bottomView setBackgroundColor:[UIColor blackColor]];
        [_bottomView setOpaque:NO];
        [_bottomView setAlpha:0.75];
        
        
        CGRect bounds = [self bounds];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 227, 21)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor =[ UIColor  
                          colorWithRed : 0xff / 255.0  
                          green : 0xff / 255.0  
                          blue : 0xee / 255.0  
                          alpha : 1 ];
        label.text = @"Apply this schedule to";
        [_bottomView addSubview:label];
        
        _dayCheckboxViews = [NSMutableArray array];
        
        _sundayCB = [[MyECheckBoxView alloc] initWithFrame:CGRectMake(165, 117, 140, 35)];
        _sundayCB.label.text = @"Sunday";
        [_dayCheckboxViews addObject:_sundayCB];
        [_bottomView addSubview:_sundayCB];
        
        _mondayCB = [[MyECheckBoxView alloc] initWithFrame:CGRectMake(15, 41, 140, 35)];
        _mondayCB.label.text = @"Monday";
        [_dayCheckboxViews addObject:_mondayCB];
        [_bottomView addSubview:_mondayCB];
        
        _tuesdayCB = [[MyECheckBoxView alloc] initWithFrame:CGRectMake(15, 79, 140, 35)];
        _tuesdayCB.label.text = @"Tuesday";
        [_dayCheckboxViews addObject:_tuesdayCB];
        [_bottomView addSubview:_tuesdayCB];
        
        _wednesdayCB = [[MyECheckBoxView alloc] initWithFrame:CGRectMake(15, 117, 140, 35)];
        _wednesdayCB.label.text = @"Wednesday";
        [_dayCheckboxViews addObject:_wednesdayCB];
        [_bottomView addSubview:_wednesdayCB];
        
        _thursdayCB = [[MyECheckBoxView alloc] initWithFrame:CGRectMake(15, 155, 140, 35)];
        _thursdayCB.label.text = @"Thursday";
        [_dayCheckboxViews addObject:_thursdayCB];
        [_bottomView addSubview:_thursdayCB];
        
        _fridayCB = [[MyECheckBoxView alloc] initWithFrame:CGRectMake(165, 41, 140, 35)];
        _fridayCB.label.text = @"Friday";
        [_dayCheckboxViews addObject:_fridayCB];
        [_bottomView addSubview:_fridayCB];
        
        _saturdayCB = [[MyECheckBoxView alloc] initWithFrame:CGRectMake(165, 79, 140, 35)];
        _saturdayCB.label.text = @"Saturday";
        [_dayCheckboxViews addObject:_saturdayCB];
        [_bottomView addSubview:_saturdayCB];
        

        
        // create a UIButton
        CGRect cancelButtonFrame = CGRectMake(10, BOTTOM_VIEW_HEIGHT - 50, 90, 37);
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelButton.frame = cancelButtonFrame;
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(_daySelectionCancel) forControlEvents:UIControlEventTouchUpInside];
        
        // create a UIButton
        CGRect doneButtonFrame = CGRectMake(CGRectGetMaxX(bounds)- 100, BOTTOM_VIEW_HEIGHT - 50, 90, 37);
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        doneButton.frame = doneButtonFrame;
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(_daySelectionDone) forControlEvents:UIControlEventTouchUpInside];
        
        [_bottomView addSubview:cancelButton];
        [_bottomView addSubview:doneButton];
        
        
        [self addSubview:_bottomView];
    }
    return self;
}

#pragma mark -
#pragma mark setter methods
//取值对应关系是：0-Sun， 1-Mon, ..., 6-Sat
- (void)setCurrentWeekdayIndex:(NSInteger)dayId {
    _currentWeekdayIndex = dayId;
    for (MyECheckBoxView *cbv in _dayCheckboxViews) {
        [cbv setChecked:NO];
        [cbv setDisabled:NO];
    }
    [[_dayCheckboxViews objectAtIndex:dayId] setChecked:YES];
    [[_dayCheckboxViews objectAtIndex:dayId] setDisabled:YES];
    
}

#pragma mark -
#pragma mark button action methods
- (void) _daySelectionCancel
{
    if ([delegate respondsToSelector:@selector(didFinishSelectApplyToDays:)])
        [delegate didFinishSelectApplyToDays:nil];// 发送空数组表示取消，仅关闭此view即可
}
- (void) _daySelectionDone
{
    NSMutableArray *days = [NSMutableArray array];
    for(NSInteger i = 0; i < 7; i++) {
        if(i == self.currentWeekdayIndex)
            continue; // 不记录当前正在编辑的week day index
        MyECheckBoxView *cbv = [_dayCheckboxViews objectAtIndex:i];
        if(cbv.isChecked) {
            [days addObject:[NSNumber numberWithInt:i]];
        }
    }
    if ([delegate respondsToSelector:@selector(didFinishSelectApplyToDays:)])
        [delegate didFinishSelectApplyToDays:days];
}
@end
