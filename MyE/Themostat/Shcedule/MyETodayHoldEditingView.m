//
//  MyETodayHoldEditingView.m
//  MyE
//
//  Created by Ye Yuan on 6/30/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyETodayHoldEditingView.h"
#import "MyEUtil.h"

@interface MyETodayHoldEditingView(PrivateMethods)
- (void) _runButtonAction;
- (void) _okButtonAction;
- (void) _cancelButtonAction;
@end


@implementation MyETodayHoldEditingView

@synthesize delegate, 
    holdString = _holdString,
    setpoint = _setpoint, 
    periodIndex = _periodIndex;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _holdString = @"Temporary hold";
        
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 240, frame.size.width, 240)];
        [bottomView setBackgroundColor:[UIColor blackColor]];
        [bottomView setOpaque:NO];
        [bottomView setAlpha:0.75];
        
        // create a label
        _holdLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(_okButton.frame) +  5, self.bounds.size.width, 30)];
        [_holdLabel setBackgroundColor:[UIColor clearColor]];
        [_holdLabel setTextColor:[UIColor whiteColor]];
        //        [captionLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14]];
        [_holdLabel setText:[NSString stringWithFormat:@"Current set to: %@", _holdString]];
        [_holdLabel setTextAlignment:NSTextAlignmentCenter]; 
        

        // create a UIButton
        CGRect runButtonFrame = CGRectMake(CGRectGetMaxX(self.bounds)- 80, 50, 70, 30);
        _runButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _runButton.frame = runButtonFrame;
        [_runButton setTitle:@"Run" forState:UIControlStateNormal];
        [_runButton addTarget:self action:@selector(_runButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_runButton setEnabled:YES];
        
        // create a UIButton
        CGRect okButtonFrame = CGRectMake(CGRectGetMaxX(self.bounds)- 80, 100, 70, 30);
        _okButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _okButton.frame = okButtonFrame;
        [_okButton setTitle:@"Ok" forState:UIControlStateNormal];
        [_okButton addTarget:self action:@selector(_okButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_okButton setEnabled:YES];
        
        // create a UIButton
        CGRect cancelButtonFrame = CGRectMake(CGRectGetMaxX(self.bounds)- 80, 150, 70, 30);
        _cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _cancelButton.frame = cancelButtonFrame;
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(_cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setEnabled:YES];
        
     
        // create a picker for cooling and heating
        //这里设置了就可以自定义高度了，一般默认是无法修改其216像素的高度
        //There are 3 valid heights for UIDatePicker (and UIPickerView) 162.0, 180.0, and 216.0. 
        //If you set a UIPickerView height to anything else you will see the following in the console when debugging on an iOS device.
        // -[UIPickerView setFrame:]: invalid height value ... pinned to 162.0 
        _setpointPickerView = [[UIPickerView alloc] init];
        _setpointPickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _setpointPickerView.frame = CGRectMake(30, 50, 180, 162);
        [_setpointPickerView setDelegate:self];
        [_setpointPickerView setDataSource:self];
        _setpointPickerView.showsSelectionIndicator = YES;
        // 设置初始默认选择的行
        _setpoint = 66;
        
        // add subviews to container view
        [bottomView addSubview:_holdLabel];
        [bottomView addSubview:_runButton];
        [bottomView addSubview:_okButton];
        [bottomView addSubview:_cancelButton];
        [bottomView addSubview:_setpointPickerView];
        
        [self addSubview:bottomView];
    }
    return self;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma setter methods
- (void) setHoldString:(NSString *)holdString {
    _holdString = holdString;
    _holdLabel.text = [NSString stringWithFormat:@"Current set to: %@", _holdString];
}
- (void) setSetpoint:(NSInteger)setpoint
{
    _setpoint = setpoint;
    [_setpointPickerView selectRow:setpoint - 55 inComponent:0 animated:YES];
    [_setpointPickerView setNeedsLayout];
}


#pragma mark -
#pragma mark button action methods
- (void) _runButtonAction
{
    if ([delegate respondsToSelector:@selector(didFinishHoldEditingWithAction:setpoint:run:)])
        [delegate didFinishHoldEditingWithAction:0 setpoint:self.setpoint run:YES];
}
- (void) _okButtonAction
{
    if ([delegate respondsToSelector:@selector(didFinishHoldEditingWithAction:setpoint:run:)])
        [delegate didFinishHoldEditingWithAction:1 setpoint:self.setpoint run:NO];
}
- (void) _cancelButtonAction
{
    if ([delegate respondsToSelector:@selector(didFinishHoldEditingWithAction:setpoint:run:)])
        [delegate didFinishHoldEditingWithAction:2 setpoint:self.setpoint run:YES];
}


#pragma mark -
#pragma mark Picker Data Source Methodes 数据源方法

//选取器如果有多个滚轮，就返回滚轮的数量，我们这里有两个，就返回2
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}
//返回给定的组件有多少行数据
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 36;
}

#pragma mark -
#pragma mark Picker Delegate Methods 委托方法

//官方的意思是，指定组件中的指定数据，就是每一行所对应的显示字符是什么。
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"  %i", row + 55];
}
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [NSString stringWithFormat:@"  %i", row + 55];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
    
}

//当选取器的行发生改变的时候调用这个方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [_okButton setAlpha:1.0];
    [_okButton setEnabled:YES];
    self.setpoint  = row + 55;
}

// returns width of column and height of row for each component. 
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 60;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 50;
}


@end
