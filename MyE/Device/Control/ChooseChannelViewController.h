//
//  ChooseChannelViewController.h
//  MyE
//
//  Created by space on 13-9-4.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseViewController.h"

@interface ChooseChannelViewController : BaseViewController <UIPickerViewDataSource,UIPickerViewDelegate>
{
    UIPickerView *pickView;
    
    int channel;
    int duration;
    
    NSDictionary *value;
    int index;
}

@property (nonatomic,strong) IBOutlet UIPickerView *pickView;
@property (nonatomic,strong) IBOutlet NSDictionary *value;

@property (nonatomic) int channel;
@property (nonatomic) int duration;
@property (nonatomic) int index;

-(IBAction) buttonClicK:(UIButton *) sender;
-(IBAction) dimss:(UIControl *) sender;
-(id) initWithValue:(NSDictionary *) d andIndex:(int) i;

@end
