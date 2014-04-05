//
//  WeekCell.h
//  MyE
//
//  Created by space on 13-8-15.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseCustomCell.h"

@interface WeekCell : BaseCustomCell
{
    UIButton *button1;
    UIButton *button2;
    UIButton *button3;
    UIButton *button4;
    UIButton *button5;
    UIButton *button6;
    UIButton *button7;
    
    NSMutableArray *selectedArray;
}

@property (nonatomic,strong) IBOutlet UIButton *button1;
@property (nonatomic,strong) IBOutlet UIButton *button2;
@property (nonatomic,strong) IBOutlet UIButton *button3;
@property (nonatomic,strong) IBOutlet UIButton *button4;
@property (nonatomic,strong) IBOutlet UIButton *button5;
@property (nonatomic,strong) IBOutlet UIButton *button6;
@property (nonatomic,strong) IBOutlet UIButton *button7;

@property (nonatomic,strong) NSMutableArray *selectedArray;

-(NSMutableArray *) getSelectedButtons;

@end
