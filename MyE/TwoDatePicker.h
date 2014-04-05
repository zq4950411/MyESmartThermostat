//
//  TwoDatePicker.h
//  MyE
//
//  Created by space on 13-8-15.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TwoDatePickerDelegate <NSObject>

@optional
-(void) datePickValue:(NSString *)string andTag:(int) tag;
-(void) datePickValueStid:(NSString *)stid etid:(NSString *) string andTag:(int) tag;

@end

@interface TwoDatePicker : UIView
{
    UIDatePicker *date1;
    UIDatePicker *date2;
    
    NSString *dateString1;
    NSString *dateString2;
    
    __weak id<TwoDatePickerDelegate> delegate;
}

@property (nonatomic,strong) IBOutlet UIDatePicker *date1;
@property (nonatomic,strong) IBOutlet UIDatePicker *date2;

@property (nonatomic,weak) id<TwoDatePickerDelegate> delegate;

-(IBAction) valueChange:(UIDatePicker *) sender;

-(NSString *) getDateString;
-(void) setDate1String:(NSString *) date1 andDate2String:(NSString *) date2;

@end
