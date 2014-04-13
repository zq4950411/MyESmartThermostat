//
//  AddSceneDeviceViewControlerViewController.h
//  MyE
//
//  Created by space on 13-8-24.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseNetViewController.h"
#import "DeviceView.h"

@interface AddSceneDeviceViewControlerViewController : BaseNetViewController
{
    __weak NSMutableArray *array;
    
    DeviceView *deviceView;
    DeviceStatusView *statusView;
    
    __weak NSMutableArray *imageNames;
    __weak NSMutableArray *numbers;
    
    __weak DeviceEntity *selectedDevice;
}

@property (nonatomic,weak) NSMutableArray *array;

@property (nonatomic,strong) DeviceView *deviceView;
@property (nonatomic,strong) DeviceStatusView *statusView;

@property (nonatomic,weak) NSMutableArray *imageNames;
@property (nonatomic,weak) NSMutableArray *numbers;

@property (nonatomic,weak) DeviceEntity *selectedDevice;

-(id) initWithDatas:(NSMutableArray *) array;
-(id) initWithDevice:(DeviceEntity *) d;

@end
