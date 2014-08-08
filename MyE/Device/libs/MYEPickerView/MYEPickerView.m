//
//  MYEPickerView.m
//  textView
//
//  Created by 翟强 on 14-5-27.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYEPickerView.h"

#define SIZEDetail(frame) NSLog(@"x:%.0f y:%.0f width:%0.f height:%.0f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height)

@implementation MYEPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
-(MYEPickerView *)initWithView:(UIView *)view andTag:(NSInteger)tag title:(NSString *)title dataSource:(NSArray *)data andSelectRow:(NSInteger)row{
    if (self = [super initWithFrame:view.bounds]) {
        //传值，以便进行全局使用
        self.data = data;
        self.selectRow = row;
        //定制背景view
        self.frame = view.window.bounds;
        self.backgroundColor = [UIColor clearColor];  //这里背景要设定颜色，选定透明色
        self.tag = tag;
        //topView 主要接收点击事件，并且半透明，可以看到遮盖的背景
        _topView = [[UIView alloc] initWithFrame:self.bounds];
        _topView.backgroundColor = [UIColor colorWithWhite:0.667 alpha:0.5];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [_topView addGestureRecognizer:tap];
        [self addSubview:_topView];
        
        //content View
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, view.window.bounds.size.height, 320, [[UIDevice currentDevice].systemVersion intValue] < 7 ?280:260)];
        _contentView.backgroundColor = [UIColor whiteColor];

        //ToolBar
        UIToolbar *tool = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        tool.barStyle = UIBarStyleBlackOpaque;
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(hide)];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStyleBordered target:self action:@selector(pickerDoneClicked)];
        [tool setItems:[NSArray arrayWithObjects:cancelButton,flexSpace,doneBtn, nil] animated:YES];
        [_contentView addSubview:tool];
        
        //titleLabel
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 200, 44)];
        titleLabel.text = title;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        [tool addSubview:titleLabel];
        
        //pickerView
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tool.frame) , 320, 0)];
        [_pickerView sizeToFit];
        [_pickerView setShowsSelectionIndicator:YES];
        [_pickerView setDelegate:self];
        [_pickerView setDataSource:self];
        _pickerView.backgroundColor = [UIColor whiteColor]; //加了这句代码之后两边就没有view的背景色了，这样显得好看些
        [_contentView addSubview:_pickerView];
        
        [_contentView sizeToFit];
        [self addSubview:_contentView];
        SIZEDetail(_pickerView.frame);
        SIZEDetail(_contentView.frame);
    }
    return self;
}

#pragma mark - animate methods
-(void)showInView:(UIView *)view{
    [view.window addSubview:self];
    [_pickerView reloadAllComponents];
    [_pickerView selectRow:_selectRow inComponent:0 animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect newFrame = self.contentView.frame;
        newFrame.origin.y -= newFrame.size.height;
        _contentView.frame = newFrame;
    }];
}
-(void)hide{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect newFrame = self.contentView.frame;
        newFrame.origin.y += newFrame.size.height;
        _contentView.frame = newFrame;
    }completion:^(BOOL finish){
        [self removeFromSuperview];
    }];
}
-(void)pickerDoneClicked{
    NSInteger i = [_pickerView selectedRowInComponent:0];
    NSString *string = _data[i];
    if ([self.delegate respondsToSelector:@selector(MYEPickerView:didSelectTitles:andRow:)]) {
        [self.delegate MYEPickerView:self didSelectTitles:string andRow:i];
    }
    [self hide];
}
#pragma mark - UIPickerView dataSource methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _data.count;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [pickerView rowSizeForComponent:0].width, [pickerView rowSizeForComponent:0].height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    label.text = _data[row];
    NSInteger i = label.text.length;
    if (i > 80) {
        label.font = [UIFont systemFontOfSize:11];
    }else if(i > 25){
        label.font = [UIFont systemFontOfSize:13];
    }else
        label.font = [UIFont boldSystemFontOfSize:20];
    return label;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    if (_isHigh) {
        return 44;
    }else
        return 33;
}
#pragma mark - UIPickerView delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
}
@end
