//
// IQActionSheetPickerView.h
// Created by Mohd Iftekhar Qurashi on 11/5/13.
// Copyright (c) 2013 Iftekhar. All rights reserved.

#import <Foundation/Foundation.h>

typedef enum IQActionSheetPickerStyle
{
    IQActionSheetPickerStyleTextPicker,
    IQActionSheetPickerStyleDatePicker
}IQActionSheetPickerStyle;

@class IQActionSheetPickerView;

@protocol IQActionSheetPickerView <UIActionSheetDelegate>
@optional
- (void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray*)titles;
- (void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didDismissWithButtonIndex:(NSInteger)index;
@end

@interface IQActionSheetPickerView : UIActionSheet<UIPickerViewDataSource,UIPickerViewDelegate>
{
@private
    UIPickerView    *_pickerView;
    UIDatePicker    *_datePicker;
    UIToolbar       *_actionToolbar;
}

@property(nonatomic,assign) id<IQActionSheetPickerView> delegate; // weak reference
@property(nonatomic, assign) IQActionSheetPickerStyle actionSheetPickerStyle;   //Default is IQActionSheetPickerStyleTextPicker;

/*for IQActionSheetPickerStyleTextPicker*/
@property(nonatomic,assign) BOOL isRangePickerView;
@property(nonatomic, strong) NSArray *titlesForComponenets;
@property(nonatomic, strong) NSArray *widthsForComponents;

/*for IQActionSheetPickerStyleDatePicker*/
@property(nonatomic, assign) NSDateFormatterStyle dateStyle;    //returning date string style.
@property(nonatomic, assign) NSDate *date; //get/set date.
@property(nonatomic, strong) UIPickerView *pickerView;
@property(nonatomic, strong) UIToolbar *actionToolbar;

@end