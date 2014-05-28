//
//  MYEWeekButtons.h
//  weekBtn
//
//  Created by 翟强 on 14-5-20.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MYEWeekButtonsDelegate;

@protocol MYEWeekButtonsDelegate <NSObject>
-(void)weekButtons:(UIView *)weekButtons selectedButtonTag:(NSArray *)buttonTags;
@end

@interface MYEWeekButtons : UIView

@property (nonatomic, strong) NSMutableArray *selectedButtons;  //外部传进来的选定的btn
@property (nonatomic, weak) id <MYEWeekButtonsDelegate> delegate;

@end
