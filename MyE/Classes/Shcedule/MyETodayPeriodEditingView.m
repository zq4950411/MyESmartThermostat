//
//  MyETodayPeriodEditingView.m
//  MyE
//
//  Created by Ye Yuan on 3/12/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyETodayPeriodEditingView.h"
#import "MyEUtil.h"

@interface MyETodayPeriodEditingView(PrivateMethods)
- (void) _cancelButtonAction;
- (void) _doneButtonAction;
@end

@implementation MyETodayPeriodEditingView
@synthesize delegate, doneButton = _doneButton, periodIndex = _periodIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 240, frame.size.width, 240)];
        [bottomView setBackgroundColor:[UIColor blackColor]];
        [bottomView setOpaque:NO];
        [bottomView setAlpha:0.75];

        
        // create a UIButton
        CGRect cancelButtonFrame = CGRectMake(10, 10, 70, 30);
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelButton.frame = cancelButtonFrame;
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(_cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        // create a UIButton
        CGRect doneButtonFrame = CGRectMake(CGRectGetMaxX(self.bounds)- 80, 10, 70, 30);
        _doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _doneButton.frame = doneButtonFrame;
        [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(_doneButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_doneButton setAlpha:0.439216];
        [_doneButton setEnabled:NO];
        
        // create a label
        UILabel *setpointLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_doneButton.frame) +  5, self.bounds.size.width, 30)];
        [setpointLabel setBackgroundColor:[UIColor clearColor]];
        [setpointLabel setTextColor:[UIColor whiteColor]];
        //        [setpointLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14]];
        [setpointLabel setText:@"Heating     Cooling"];
        [setpointLabel setTextAlignment:UITextAlignmentCenter]; 
        
        // create a picker for cooling and heating
        //这里设置了就可以自定义高度了，一般默认是无法修改其216像素的高度
        //There are 3 valid heights for UIDatePicker (and UIPickerView) 162.0, 180.0, and 216.0. 
        //If you set a UIPickerView height to anything else you will see the following in the console when debugging on an iOS device.
        // -[UIPickerView setFrame:]: invalid height value ... pinned to 162.0 
        _setpointPickerView = [[UIPickerView alloc] init];
        _setpointPickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _setpointPickerView.frame = CGRectMake(70, CGRectGetMaxY(bottomView.bounds) - 162, 180, 162);
        [_setpointPickerView setDelegate:self];
        [_setpointPickerView setDataSource:self];
        _setpointPickerView.showsSelectionIndicator = YES;
        // 设置初始默认选择的行
        _cooling = 77;
        _heating = 66;
        
        
        // add subviews to container view
        [bottomView addSubview:cancelButton];
        [bottomView addSubview:_doneButton];
        [bottomView addSubview:setpointLabel];
        [bottomView addSubview:_setpointPickerView];
        
        [self addSubview:bottomView];
    }
    return self;
}

- (void) setHeatingCooling:(NSInteger)heating cooling:(NSInteger)cooling
{
    _heating = heating;
    _cooling = cooling;
    
    [_setpointPickerView selectRow:heating - 55 inComponent:0 animated:YES];
    [_setpointPickerView selectRow:cooling - _heating - MINIMUM_HEATING_COOLING_GAP inComponent:1 animated:YES];
    [_setpointPickerView setNeedsLayout];
}


#pragma mark -
#pragma mark button action methods
- (void) _cancelButtonAction
{
    if ([delegate respondsToSelector:@selector(didFinishEditingPeriodIndex:cooling:heating:)])
        [delegate didFinishEditingPeriodIndex:-1 cooling:_cooling heating:_heating];
}
- (void) _doneButtonAction
{
    if ([delegate respondsToSelector:@selector(didFinishEditingPeriodIndex:cooling:heating:)])
        [delegate didFinishEditingPeriodIndex:self.periodIndex cooling:_cooling heating:_heating];
}

#pragma mark -
#pragma mark Picker Data Source Methodes 数据源方法

//选取器如果有多个滚轮，就返回滚轮的数量，我们这里有两个，就返回2
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 2;
}
//返回给定的组件有多少行数据
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //return 36;
    if (component == 0) {//heating
        return _cooling - MINIMUM_HEATING_COOLING_GAP - 55 +1;
    } else {//cooling
        return 90 - (_heating + MINIMUM_HEATING_COOLING_GAP) +1;
    }
}

#pragma mark -
#pragma mark Picker Delegate Methods 委托方法

//官方的意思是，指定组件中的指定数据，就是每一行所对应的显示字符是什么。
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	//return [NSString stringWithFormat:@"%i", row+55];
    if (component == 0) {//heating
        return [NSString stringWithFormat:@"  %i", row + 55];
    } else {//cooling
        return [NSString stringWithFormat:@"  %i", row + _heating + MINIMUM_HEATING_COOLING_GAP];
    }
}

//当选取器的行发生改变的时候调用这个方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.doneButton setAlpha:1.0];
    [self.doneButton setEnabled:YES];
    
    if (component == 0) { //heating
        _heating  = row + 55;
    }
    if (component == 1) { //cooling
        _cooling = row + _heating + MINIMUM_HEATING_COOLING_GAP;
    }
}

// returns width of column and height of row for each component. 
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 60;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 50;
}
@end
