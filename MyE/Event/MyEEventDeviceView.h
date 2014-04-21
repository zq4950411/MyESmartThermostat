//
//  DeviceView.h
//  MyE
//
//  Created by space on 13-8-24.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseView.h"

@class MyEEventDeviceEntity;
@interface MyEEventDeviceView : BaseView
{
    UIButton *nextButton;
    UIButton *cancelButton;
    UIPickerView *pickView;
    
    NSMutableArray *datas;
}

@property (nonatomic,strong) IBOutlet UIButton *nextButton;
@property (nonatomic,strong) IBOutlet UIButton *cancelButton;
@property (nonatomic,strong) IBOutlet UIPickerView *pickView;

@property (nonatomic,strong) NSMutableArray *datas;

-(MyEEventDeviceEntity *) getSeletedDevice;

@end


@interface DeviceStatusView : BaseView <UIPickerViewDataSource,UIPickerViewDelegate>
{
    UIPickerView *pickView;
    UISwitch *fanSwitch;
    
    NSMutableArray *imagesDics;
    NSMutableArray *numbers;
    NSMutableArray *instructions;
    
    NSMutableDictionary *value;
    
    UIButton *okButton;
    
    int type;//0:温控器 1:职控星 2:智能插座 3:通用控制器
}

-(NSMutableDictionary *) getSelectedDictionary;

@property (nonatomic,strong) IBOutlet UIPickerView *pickView;
@property (nonatomic,strong) IBOutlet UISwitch *fanSwitch;

@property (nonatomic,strong) IBOutlet UIButton *okButton;

@property (nonatomic,strong) NSMutableArray *imagesDics;
@property (nonatomic,strong) NSMutableArray *numbers;
@property (nonatomic,strong) NSMutableArray *instructions;

@property (nonatomic,strong) NSDictionary *value;

@property int type;

@end






