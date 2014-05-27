//
//  MyEEventConditionEditViewController.h
//  MyE
//
//  Created by 翟强 on 14-5-14.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEEventConditionEditViewController : UIViewController

@property (nonatomic, weak) MyEEventDetail *eventDetail;
@property (nonatomic, strong) MyEEventConditionCustom *conditionCustom;
@property (nonatomic, assign) BOOL isAdd;

@end
