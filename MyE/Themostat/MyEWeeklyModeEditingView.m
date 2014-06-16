//
//  MyEWeeklyModeEditingView.m
//  MyE
//
//  Created by Ye Yuan on 3/5/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MyEWeeklyModeEditingView.h"
#import "MyEThumbColorView.h"
#import "MyEUtil.h"

#define INFO_LABEL_HEIGHT 20.0
#define VERTICAL_GAP 5.0
#define THUMB_SIZE 40
#define THUMB_V_PADDING 5
#define THUMB_H_PADDING 5

#define AUTOSCROLL_THRESHOLD 30

#define NUMBER_OF_SAMPLE_COLOR 16

@interface MyEWeeklyModeEditingView(PrivateMethods)
- (void) _editingModeCancel;
- (void) _editingModeDone;
- (void) _deleteMode;
- (void)_createThumbScrollViewIfNecessary;
- (void)_highlightThumbColorView:(MyEThumbColorView *)tcv;
@end


@implementation MyEWeeklyModeEditingView
@synthesize delegate;
@synthesize cooling = _cooling, heating = _heating;
@synthesize modeColor = _modeColor;
@synthesize modeId = _modeId;
@synthesize modeName = _modeName;
@synthesize typeOfEditing = _typeOfEditing;
@synthesize nameTextField = _nameTextField;
@synthesize delButton = _delButton;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // Initialization code
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 334, frame.size.width, 334)];
        [_bottomView setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.85]];
        [_bottomView setOpaque:NO];
        [_bottomView setAlpha:0.95];
        
        
        _typeOfEditing = ModeEditingViewTypeEditing;
        
        CGRect bounds = [self bounds];
        
        // create a UIButton
        CGRect cancelButtonFrame = CGRectMake(10, 5, 70, 30);
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelButton.frame = cancelButtonFrame;
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(_editingModeCancel) forControlEvents:UIControlEventTouchUpInside];
        
        // create a UIButton
        CGRect doneButtonFrame = CGRectMake(CGRectGetMaxX(bounds)- 80, 10, 70, 30);
        _doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _doneButton.frame = doneButtonFrame;
        [_doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(_editingModeDone) forControlEvents:UIControlEventTouchUpInside];
        
        // create a UIButton
        CGRect deleteModeButtonFrame = CGRectMake(145, 5, 30, 30);
        self.delButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.delButton.frame = deleteModeButtonFrame;
        [self.delButton setImage:[UIImage imageNamed:@"xMark.png"] forState:UIControlStateNormal];
        [self.delButton setTitle:@"Del" forState:UIControlStateNormal];
        [self.delButton addTarget:self action:@selector(_deleteMode) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, CGRectGetMaxY(doneButtonFrame) + VERTICAL_GAP *2, 50, INFO_LABEL_HEIGHT)];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTextColor:[UIColor whiteColor]];
        //        [nameLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14]];
        [nameLabel setText:@"Name"];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        
        _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x + nameLabel.frame.size.width, CGRectGetMaxY(doneButtonFrame) + VERTICAL_GAP*1.5, 160, 25)];
        _nameTextField.text = @"newmode";
        _nameTextField.backgroundColor = [UIColor whiteColor];
        _nameTextField.borderStyle = UITextBorderStyleRoundedRect;
        _nameTextField.delegate = self;
        _nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_nameTextField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
        
       
        
        // create label giving credit for colors
        UILabel *colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(nameLabel.frame) + VERTICAL_GAP +5, bounds.size.width, INFO_LABEL_HEIGHT)];
        [colorLabel setBackgroundColor:[UIColor clearColor]];
        [colorLabel setTextColor:[UIColor whiteColor]];
//        [colorLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14]];
        [colorLabel setText:@"Choose a color"];
        [colorLabel setTextAlignment:NSTextAlignmentCenter];
        
        
        
        
        // create color picker
        [self _createThumbScrollViewIfNecessary];
        
        // create a label
        UILabel *setpointLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(thumbScrollView.frame) +  VERTICAL_GAP, bounds.size.width, INFO_LABEL_HEIGHT)];
        [setpointLabel setBackgroundColor:[UIColor clearColor]];
        [setpointLabel setTextColor:[UIColor whiteColor]];
        //        [setpointLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14]];
        [setpointLabel setText:@"Heating   Cooling"];
        [setpointLabel setTextAlignment:NSTextAlignmentCenter]; 
        
        // 设置初始默认选择的行
        _heating = 66;
        _cooling = 74;
        
        
        // create a picker for cooling and heating
        //这里设置了就可以自定义高度了，一般默认是无法修改其216像素的高度
        //There are 3 valid heights for UIDatePicker (and UIPickerView) 162.0, 180.0, and 216.0. 
        //If you set a UIPickerView height to anything else you will see the following in the console when debugging on an iOS device.
        // -[UIPickerView setFrame:]: invalid height value ... pinned to 162.0 
        _setpointPickerView = [[UIPickerView alloc] init];
        _setpointPickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _setpointPickerView.frame = CGRectMake(70, _bottomView.bounds.size.height - 162, 180, 162);
        [_setpointPickerView setDelegate:self];
        [_setpointPickerView setDataSource:self];
        _setpointPickerView.showsSelectionIndicator = YES;

        
        
        
        // add subviews to container view
        [_bottomView addSubview:cancelButton];
        [_bottomView addSubview:self.delButton];
        [_bottomView addSubview:_nameTextField];
        [_bottomView addSubview:nameLabel];
        [_bottomView addSubview:_doneButton];
        [_bottomView addSubview:colorLabel];
        [_bottomView addSubview:setpointLabel];
        [_bottomView addSubview:_setpointPickerView];
        
        [self addSubview:_bottomView];
    }
    return self;
}

#pragma mark -
#pragma mark setter methods
- (void) setModeColor:(UIColor *)color
{
    
    // 添加代码更新color picker
    int colorIndex = [MyEUtil colorIndexInSampleColorArrayForColor:color];
    NSLog(@"color index = %i", colorIndex);
    if (colorIndex > -1 && colorIndex < 16) {//如果在样本颜色数组里面找到了这个颜色
        _modeColor = color;
    }else {//如果在样本颜色数组里面没有找到这个颜色,就用样本颜色数组的第一个颜色作为当前选择的颜色
        if (! _sampleColorArray) {// 如果本类保持的样本颜色数组不存在，就创建它
            _sampleColorArray = [MyEUtil sampleColorArrayForScheduleMode];
        }
        _modeColor = [_sampleColorArray objectAtIndex:0];
        colorIndex = 0;
    }
    // 根据找到的颜色index找到thumbScrollView里面的thumb，并把它高亮显示
    for (MyEThumbColorView *thumb in thumbScrollView.subviews) {
        if([thumb isKindOfClass:[MyEThumbColorView class]]){
            if (colorIndex == thumb.colorIndex) {
                [self _highlightThumbColorView:thumb];
                break;
            }
        }
    }
    
}
- (void) setHeating:(NSInteger)heating
{
    _heating = heating;
    [_setpointPickerView selectRow:heating - 55 inComponent:0 animated:YES];
    [_setpointPickerView setNeedsLayout];
}
- (void) setCooling:(NSInteger)cooling
{
    _cooling = cooling;
    [_setpointPickerView selectRow:cooling - _heating - MINIMUM_HEATING_COOLING_GAP inComponent:1 animated:YES];
    [_setpointPickerView setNeedsLayout];
}
- (void) setModeName:(NSString *)modeName {
    _modeName = modeName;
    _nameTextField.text = modeName;
}
- (void) setRemoteControlEnabled:(BOOL)isEnabled {
    self.delButton.enabled = isEnabled;
    self.delButton.alpha = isEnabled?1:0.439216;
    
    _nameTextField.enabled = isEnabled;
    _nameTextField.alpha = isEnabled?1:0.439216;
    
    _doneButton.enabled = isEnabled;
    _doneButton.alpha = isEnabled?1:0.439216;
    
    _setpointPickerView.userInteractionEnabled = isEnabled;
    _setpointPickerView.alpha = isEnabled?1:0.439216;
}


#pragma mark -
#pragma mark button action methods
- (void) _editingModeCancel
{
    [_nameTextField resignFirstResponder];
    if ([delegate respondsToSelector:@selector(didFinishModeEditingType:modeId: modeName:color:cooling:heating:)])
        [delegate didFinishModeEditingType:ModeEditingViewTypeCancel modeId:self.modeId modeName:self.modeName color:self.modeColor cooling:self.cooling heating:self.heating];
}
- (void) _editingModeDone
{
    [_nameTextField resignFirstResponder];
     
    if ([delegate respondsToSelector:@selector(isModeNameInUse:exceptCurrentModeId:)]) {
        if ([delegate isModeNameInUse:self.modeName  exceptCurrentModeId:self.modeId]) {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Alert" 
                                                          message:@"Sorry, the mode name is taken."
                                                         delegate:self 
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    if ([delegate respondsToSelector:@selector(isModeColorInUse:exceptCurrentModeId:)]) {
        if ([delegate isModeColorInUse:self.modeColor   exceptCurrentModeId:self.modeId]) {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Alert" 
                                                          message:@"Sorry, the mode color is taken."
                                                         delegate:self 
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    
    if ([delegate respondsToSelector:@selector(didFinishModeEditingType:modeId: modeName:color:cooling:heating:)])
        [delegate didFinishModeEditingType:self.typeOfEditing modeId:self.modeId modeName:self.modeName color:self.modeColor cooling:self.cooling heating:self.heating];
}
- (void) _deleteMode {
    [_nameTextField resignFirstResponder];
    if ([delegate respondsToSelector:@selector(didFinishDeletingModeId:)])
        [delegate didFinishDeletingModeId:self.modeId];
}




#pragma mark -
#pragma mark private methods
- (void)_createThumbScrollViewIfNecessary {
    if (! _sampleColorArray) {
        _sampleColorArray = [MyEUtil sampleColorArrayForScheduleMode];
    }
    if (!thumbScrollView) {        
        
        // create a scroll view to contain the custom color picker 
        float scrollViewHeight = THUMB_SIZE + THUMB_V_PADDING * 2;
        float scrollViewWidth  = [self bounds].size.width*0.8;
        thumbScrollView = [[UIScrollView alloc] 
                           initWithFrame:CGRectMake((self.bounds.size.width - scrollViewWidth) / 2.0, 
                                                    (INFO_LABEL_HEIGHT  + VERTICAL_GAP) * 3.9, 
                                                    scrollViewWidth, 
                                                    scrollViewHeight)];
        [thumbScrollView setCanCancelContentTouches:NO];
        [thumbScrollView setClipsToBounds:YES];
        [thumbScrollView setBackgroundColor:[UIColor blackColor]];
        
        [thumbScrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        
        //thumbScrollView设置边框和阴影
        [[thumbScrollView layer] setCornerRadius:0];// 现在扁平化， 不要圆角了
        [[thumbScrollView layer] setShadowOffset:CGSizeMake(2, 2)];
        [[thumbScrollView layer] setShadowRadius:0];// 现在扁平化， 不要圆角了
        [[thumbScrollView layer] setShadowOpacity:1];
        [[thumbScrollView layer] setShadowColor:[UIColor cyanColor].CGColor];
        
        // now place all the thumb views as subviews of the scroll view 
        // and in the course of doing so calculate the content width
        float xPosition = THUMB_H_PADDING;
        int count = [_sampleColorArray count];
        for (int i = 0; i < count; i++) {
            UIColor *color = [_sampleColorArray objectAtIndex:i];
            MyEThumbColorView *thumbView = [[MyEThumbColorView alloc] initWithColor:color];
            [thumbView setColorIndex:i];
            [thumbView setDelegate:self];
            CGRect frame = [thumbView frame];
            frame.origin.y = THUMB_V_PADDING;
            frame.origin.x = xPosition;
            frame.size.width = THUMB_SIZE;
            frame.size.height = THUMB_SIZE;
            [thumbView setFrame:frame];
            [thumbScrollView addSubview:thumbView];
            xPosition += (frame.size.width + THUMB_H_PADDING);

        }
        [thumbScrollView setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
        
        [_bottomView addSubview:thumbScrollView];
    }    
}

- (void)_highlightThumbColorView:(MyEThumbColorView *)tiv {
    for (MyEThumbColorView *thumb in [thumbScrollView subviews]) {
        [[thumb layer] setBorderWidth:0.0];
    }
    [[tiv layer] setBorderWidth:3.0];
    
    //使Scroll View 的视图窗口移动到适当的位置，以便使选中的color view尽量剧中
    float offsetX = (tiv.frame.size.width  + THUMB_H_PADDING)* tiv.colorIndex - (thumbScrollView.frame.size.width - (tiv.frame.size.width  + THUMB_H_PADDING))/2;
    if (offsetX < 0) {
        offsetX = 0;
    }
    if (offsetX + thumbScrollView.frame.size.width > (tiv.frame.size.width  + THUMB_H_PADDING)* 16) {
        offsetX = (tiv.frame.size.width  + THUMB_H_PADDING)* 16 - thumbScrollView.frame.size.width;//一共有16中颜色
    }
    [thumbScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];////////////////
}

#pragma mark -
#pragma mark MyEThumbColorViewDelegate methods

- (void)thumbColorViewWasTapped:(MyEThumbColorView *)tcv {
    if(!self.delegate.isRemoteControl)
        return;
    _modeColor = [tcv color];
    [self _highlightThumbColorView:tcv];
    NSLog(@"selected a color : %@", [self.modeColor description]);
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
        return self.cooling - MINIMUM_HEATING_COOLING_GAP - 55 +1;
    } else {//cooling
        return 90 - (self.heating + MINIMUM_HEATING_COOLING_GAP) +1;
    }
}

#pragma mark -
#pragma mark Picker Delegate Methods 委托方法

//官方的意思是，指定组件中的指定数据，就是每一行所对应的显示字符是什么。
// 有了下面方法, 此方法就没用了
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	//return [NSString stringWithFormat:@"%i", row+55];
    if (component == 0) {//heating
        return [NSString stringWithFormat:@"  %i", row + 55];
    } else {//cooling
        return [NSString stringWithFormat:@"  %i", row + self.heating + MINIMUM_HEATING_COOLING_GAP];
    }
    
}
// 有了此方法, 上面方法就不需要了
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = @"sample title";
    if (component == 0) {//heating
        title= [NSString stringWithFormat:@"  %i", row + 55];
    } else {//cooling
        title= [NSString stringWithFormat:@"  %i", row + self.heating + MINIMUM_HEATING_COOLING_GAP];
    }
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
    
}

//当选取器的行发生改变的时候调用这个方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) { //heating
        self.heating  = row + 55;
        self.cooling = self.cooling;
    }
    if (component == 1) { //cooling
        self.cooling = row + self.heating + MINIMUM_HEATING_COOLING_GAP;
        self.heating = self.heating;
    }
}

// returns width of column and height of row for each component. 
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 60;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 50;
}


#pragma mark -
#pragma mark UITextField Delegate Methods 委托方法
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == _nameTextField) {
        self.modeName = textField.text;
        [textField resignFirstResponder];
    }
    return  YES;
}

// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField == _nameTextField) {
        self.modeName = textField.text;
        [textField resignFirstResponder];
    }
    return  YES;
}
@end
