//
//  AddSceneDeviceViewControlerViewController.m
//  MyE
//
//  Created by space on 13-8-24.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "AddSceneDeviceViewControlerViewController.h"
#import "SceneDeviceViewController.h"

#import "DeviceEntity.h"
#import "MyEHouseData.h"
#import "SceneEntity.h"

@implementation AddSceneDeviceViewControlerViewController

@synthesize array;

@synthesize deviceView;
@synthesize statusView;

@synthesize imageNames;
@synthesize numbers;
@synthesize selectedDevice;


-(id) initWithDatas:(NSMutableArray *) a
{
    if (self = [super init])
    {
        self.array = a;
    }
    
    return self;
}

-(id) initWithDevice:(DeviceEntity *)d
{
    if (self = [super init])
    {
        self.selectedDevice = d;
    }
    return self;
}




-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) u
{
    NSString *terminalType = [[userInfo objectForKey:REQUET_PARAMS] objectForKey:@"terminalType"];
    if ([u rangeOfString:URL_FOR_SCENES_FIND_DEVICE].location != NSNotFound)
    {
        NSDictionary *value = [jsonString JSONValue];
        if (value.count > 0)
        {
            if (terminalType.intValue == 0)
            {
                self.statusView = [[[NSBundle mainBundle] loadNibNamed:@"DeviceView" owner:self options:nil] objectAtIndex:1];
                self.statusView.type = 0;
            }
            else if (terminalType.intValue == 1 ||
                     terminalType.intValue == 2 ||
                     terminalType.intValue == 3 ||
                     terminalType.intValue == 6)
            {
                self.statusView = [[[NSBundle mainBundle] loadNibNamed:@"DeviceView" owner:self options:nil] objectAtIndex:2];
                self.statusView.type = terminalType.intValue;
            }
            
            if (self.statusView.superview == nil)
            {
                [self.statusView.okButton addTarget:self action:@selector(ok:) forControlEvents:UIControlEventTouchUpInside];
                self.statusView.value = [NSMutableDictionary dictionaryWithDictionary:value];
                
                [self.view.layer addAnimation:[Utils createAnimatioin:kCATransitionFade duration:0.35 subtype:nil] forKey:nil];
                [self.view addSubview:self.statusView];
            }
        }
    }
    else if([u rangeOfString:URL_FOR_SCENES_SAVE_SCENE_DEVICE].location != NSNotFound)
    {
        if ([@"OK" isEqualToString:jsonString])
        {
            SceneDeviceViewController *tempVc = (SceneDeviceViewController *)parentVC;
            if (selectedDevice != nil)
            {
                [tempVc dimissWithDeviceId:selectedDevice.deviceId];
            }
            else
            {
                DeviceEntity *d = [self.deviceView getSeletedDevice];
                [tempVc dimissWithDeviceId:d.deviceId];
            }
        }
    }
}

-(void) netError:(id)errorMsg withUserInfo:(NSDictionary *)userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:URL_FOR_SCENES_FIND_DEVICE].location != NSNotFound)
    {
        
    }
}





-(void) getSceneDevics
{
    self.isShowLoading = YES;
    
    //DeviceEntity *d = [self.deviceView getSeletedDevice];
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    
//    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
//    [params safeSetObject:@"-1" forKey:@"sceneId"];
//    [params safeSetObject:d.deviceId forKey:@"deviceId"];
//    [params safeSetObject:d.terminalType forKey:@"type"];
//    [params safeSetObject:@"addSceneSub" forKey:@"action"];
//    
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
//    
//    [[NetManager sharedManager] requestWithURL:URL_FOR_SCENES_FIND_DEVICE
//                                      delegate:self
//                                  withUserInfo:dic];
}











-(void) ok:(UIButton *) sender
{
    NSMutableDictionary *params = [self.statusView getSelectedDictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    if (selectedDevice == nil)
    {
        DeviceEntity *d = [self.deviceView getSeletedDevice];
        
        [params safeSetObject:@"-1" forKey:@"sceneSubId"];
        [params safeSetObject:d.deviceId forKey:@"deviceId"];
        [params safeSetObject:@"addSceneSub" forKey:@"action"];
    }
    else
    {
        [params safeSetObject:selectedDevice.sceneSubId forKey:@"sceneSubId"];
        [params safeSetObject:selectedDevice.deviceId forKey:@"deviceId"];
        [params safeSetObject:@"editSceneSub" forKey:@"action"];
    }

    SceneDeviceViewController *tempVc = (SceneDeviceViewController *)parentVC;
    [params safeSetObject:tempVc.scene.sceneId forKey:@"sceneId"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SCENES_SAVE_SCENE_DEVICE)
                                      delegate:self
                                  withUserInfo:dic];
}

-(void) showDeviceInfo:(DeviceEntity *) device
{
    DeviceEntity *d = nil;
    
    if (device == nil)
    {
        d = [self.deviceView getSeletedDevice];
    }
    else
    {
        d = device;
    }
    
    
    int type = 2;
    //0  表示美国温度控制器，1  红外转发器，2 智能插座，3  通用控制器，4 安防设备, 6智能开关。
    if (d.terminalType.intValue == 0)
    {
        self.statusView = [[[NSBundle mainBundle] loadNibNamed:@"DeviceView" owner:self options:nil] objectAtIndex:1];
        self.statusView.type = 0;
        
        type = 1;
    }
    else if (d.terminalType.intValue == 1 || d.terminalType.intValue == 2 ||
             d.terminalType.intValue == 3 || d.terminalType.intValue == 6)
    {
        self.statusView = [[[NSBundle mainBundle] loadNibNamed:@"DeviceView" owner:self options:nil] objectAtIndex:2];
        self.statusView.type = d.terminalType.intValue;
    }
        
    self.isShowLoading = YES;
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params safeSetObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    if (selectedDevice != nil)
    {
        [params safeSetObject:selectedDevice.sceneSubId forKey:@"sceneId"];
        [params safeSetObject:selectedDevice.sceneSubId forKey:@"sceneSubId"];
        [params safeSetObject:@"editSceneSub" forKey:@"action"];
    }
    else
    {
        [params safeSetObject:@"-1" forKey:@"sceneId"];
        [params safeSetObject:@"addSceneSub" forKey:@"action"];
    }
    [params safeSetObject:d.deviceId forKey:@"deviceId"];
    [params safeSetObject:[NSString stringWithFormat:@"%d",type] forKey:@"type"];
    [params safeSetObject:d.deviceId forKey:@"deviceId"];
    [params safeSetObject:d.terminalType forKey:@"terminalType"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_SCENES_FIND_DEVICE)
                                      delegate:self
                                  withUserInfo:dic];
}


-(void) next:(UIButton *) sender
{
    [self showDeviceInfo:nil];
}

-(void) cancel:(UIButton *) sender
{
    SceneDeviceViewController *tempVc = (SceneDeviceViewController *)parentVC;
    [tempVc dimiss];
}








- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.top = 0;
    
    if (self.deviceView == nil)
    {
        if (selectedDevice == nil)
        {
            self.deviceView = [[[NSBundle mainBundle] loadNibNamed:@"DeviceView" owner:self options:nil] objectAtIndex:0];
            
            self.deviceView.datas = self.array;
            [self.view addSubview:self.deviceView];
            
            [self.deviceView.nextButton addTarget:self action:@selector(next:) forControlEvents:UIControlEventTouchUpInside];
            [self.deviceView.cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            [self showDeviceInfo:selectedDevice];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
