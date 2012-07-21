//
//  MyETMyETodayPeriodInforView.h
//  MyE
//
//  Created by Ye Yuan on 4/23/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MyETodayPeriodInforViewDelegate;

@interface MyETodayPeriodInforView : UIView{
    UILabel *_coolingLabel;
    UILabel *_heatingLabel; 
    UILabel *_holdLabel; 
}
@property (nonatomic, retain) id <MyETodayPeriodInforViewDelegate> delegate;
@property (nonatomic, retain) UILabel *coolingLabel;
@property (nonatomic, retain) UILabel *heatingLabel;
@property (nonatomic, copy) UILabel *holdLabel;

- (void)setCooling:(NSInteger)cooling;
- (void)setHeating:(NSInteger)heating;
- (void)setHoldString:(NSString *)holdString;
@end

/*
 Protocol for the MyETodayPeriodInforView's delegate.
 */
@protocol MyETodayPeriodInforViewDelegate <NSObject>
@optional
- (void) didFinishPeriodInforView;
@end