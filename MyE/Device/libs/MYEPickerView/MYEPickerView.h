//
//  MYEPickerView.h
//  textView
//
//  Created by 翟强 on 14-5-27.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MYEPickerViewDelegate <NSObject>

-(void)MYEPickerView:(UIView *)pickerView didSelectTitles:(NSString *)title andRow:(NSInteger)row;

@end

@interface MYEPickerView : UIView<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, weak) id <MYEPickerViewDelegate> delegate;
@property (nonatomic, strong) UIView *contentView; //内容视图
@property (nonatomic, strong) UIView *topView;  //顶部view
@property (nonatomic, assign) NSInteger selectRow;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, assign) BOOL isHigh;
-(MYEPickerView *)initWithView:(UIView *)view andTag:(NSInteger)tag title:(NSString *)title dataSource:(NSArray *)data andSelectRow:(NSInteger)row;

-(void)showInView:(UIView *)view;
@end
