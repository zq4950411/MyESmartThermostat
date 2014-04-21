//
//  AddSceneDeviceViewControlerViewController.h
//  MyE
//
//  Created by space on 13-8-24.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseNetViewController.h"
#import "MyEEventDeviceView.h"

@interface AddSceneDeviceViewControlerViewController : BaseNetViewController
{
    __weak NSMutableArray *array;
    
    MyEEventDeviceView *deviceView;
    DeviceStatusView *statusView;
    
    __weak NSMutableArray *imageNames;
    __weak NSMutableArray *numbers;
    
    __weak MyEEventDeviceEntity *selectedDevice;
}

@property (nonatomic,weak) NSMutableArray *array;

@property (nonatomic,strong) MyEEventDeviceView *deviceView;
@property (nonatomic,strong) DeviceStatusView *statusView;

@property (nonatomic,weak) NSMutableArray *imageNames;
@property (nonatomic,weak) NSMutableArray *numbers;

@property (nonatomic,weak) MyEEventDeviceEntity *selectedDevice;

-(id) initWithDatas:(NSMutableArray *) array;
-(id) initWithDevice:(MyEEventDeviceEntity *) d;

@end
