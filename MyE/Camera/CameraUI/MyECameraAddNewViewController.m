//
//  MyECameraAddNewViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 14-4-30.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraAddNewViewController.h"
@interface MyECameraAddNewViewController (){
    NSCondition* _m_PPPPChannelMgtCondition;
    CPPPPChannelManagement* _m_PPPPChannelMgt;
    MBProgressHUD *HUD;
    BOOL _canAddNew;
    NSTimer *_timer;
}

@end

@implementation MyECameraAddNewViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.txtName.text = _camera.name;
    self.txtUsername.text = _camera.username;
    self.txtUID.text = self.camera.UID;
    
    if (self.jumpFromWhere == 1) {
        self.lblTitle.text = @"New Camera in WIFI";
    }else if (self.jumpFromWhere == 2){
        self.lblTitle.text = @"New Camera";
    }else{
        self.lblTitle.text = @"Enter Info below";
    }
    
    for (UIButton *btn in self.view.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            if (btn.tag == 101) {
                [btn setBackgroundImage:[[UIImage imageNamed:@"control-enable-normal"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:@"control-enable-highlight"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateHighlighted];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor colorWithRed:69/255 green:220/255 blue:200/255 alpha:1] forState:UIControlStateHighlighted];
            }else{
                [btn setBackgroundImage:[[UIImage imageNamed:@"control-disable-normal"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
                [btn setBackgroundImage:[[UIImage imageNamed:@"control-disable-highlight"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateHighlighted];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor colorWithRed:69/255 green:220/255 blue:200/255 alpha:1] forState:UIControlStateHighlighted];
            }
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - private methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (void)initialize{
    PPPP_Initialize((char*)[@"EBGBEMBMKGJMGAJPEIGIFKEGHBMCHMJHCKBMBHGFBJNOLCOLCIEBHFOCCHKKJIKPBNMHLHCPPFMFADDFIINOIABFMH" UTF8String]);
    st_PPPP_NetInfo NetInfo;
    PPPP_NetworkDetect(&NetInfo, 0);
}
- (void)ConnectCam{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initialize];
    });
    
    [_m_PPPPChannelMgtCondition lock];
    _m_PPPPChannelMgt = new CPPPPChannelManagement();
    _m_PPPPChannelMgt->pCameraViewController = self;
    
    if (_m_PPPPChannelMgt == NULL) {
        [_m_PPPPChannelMgtCondition unlock];
        return;
    }
    _m_PPPPChannelMgt->StopAll();
    _m_PPPPChannelMgt->Start([self.camera.UID UTF8String], [self.camera.username UTF8String], [self.camera.password UTF8String]);
    [_m_PPPPChannelMgtCondition unlock];
}
-(void)handelTimer{
    [_timer invalidate];
    [HUD hide:YES];
    if (_canAddNew) {
        BOOL isNew = NO;
        if ([self.cameraList count]) {
            for (MyECamera *c in self.cameraList) {
                if (![_camera.UID isEqualToString:c.UID]) {
                    isNew = YES;
                }
            }
        }else
            isNew = YES;
        if (isNew) {
            [MyEUtil showThingsSuccessOn:self.navigationController.view WithMessage:@"Success" andTag:YES];
            NSLog(@"%@",self.camera);
            [self.cameraList addObject:self.camera];
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
        }else
            [MyEUtil showThingsSuccessOn:self.navigationController.view WithMessage:@"This camera has existed" andTag:NO];
    }else{
        [MyEUtil showThingsSuccessOn:self.navigationController.view WithMessage:@"Fail" andTag:NO];
    }
}
-(void)addCameraToList{
    [HUD hide:YES];
    if (_canAddNew) {
        [MyEUtil showThingsSuccessOn:self.navigationController.view WithMessage:@"Success" andTag:YES];
        [self.cameraList addObject:self.camera];
        [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
    }else
        [MyEUtil showThingsSuccessOn:self.navigationController.view WithMessage:@"Fail" andTag:NO];
}

#pragma mark - IBAction methods
- (IBAction)dissmissVC:(UIButton *)sender {
    self.cancelBtnClicked = YES;
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}
- (IBAction)saveEditor:(UIButton *)sender {
    self.camera.username = self.txtUsername.text;
    self.camera.password = self.txtPassword.text;
    self.camera.name = self.txtName.text;
    self.camera.UID = self.txtUID.text;
    NSLog(@"%@",self.camera);
    BOOL isNew = YES;
    for (MyECamera *c in self.cameraList) {
        if ([c.UID isEqualToString:self.camera.UID]) {
            isNew = NO;
            break;
        }
    }
    if (isNew) {
        if (HUD == nil) {
            HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        }
        [HUD show:YES];
        HUD.labelText = @"Connecting...";
        _timer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(handelTimer) userInfo:nil repeats:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self ConnectCam];
        });
    }else
        [MyEUtil showThingsSuccessOn:self.navigationController.view WithMessage:@"设备已存在" andTag:NO];
}
#pragma mark - PPPPStatusDelegate methods
- (void) PPPPStatus: (NSString*) strDID statusType:(NSInteger) statusType status:(NSInteger) status{
    NSString* strPPPPStatus = nil;
    switch (status) {
        case PPPP_STATUS_UNKNOWN:
            strPPPPStatus = @"Unknown";
            break;
        case PPPP_STATUS_CONNECTING:
            strPPPPStatus = @"Connecting";
            break;
        case PPPP_STATUS_INITIALING:
            strPPPPStatus = @"Initialing";
            break;
        case PPPP_STATUS_CONNECT_FAILED:
            strPPPPStatus = @"ConnectFailed";
            break;
        case PPPP_STATUS_DISCONNECT:
            strPPPPStatus = @"Disconnected";
            _canAddNew = YES;
            break;
        case PPPP_STATUS_INVALID_ID:
            strPPPPStatus = @"InvalidID";
            _canAddNew = NO;
            break;
        case PPPP_STATUS_ON_LINE:
            strPPPPStatus = @"Online";
            _canAddNew = YES;
            break;
        case PPPP_STATUS_DEVICE_NOT_ON_LINE:
            strPPPPStatus = @"Offline";
            _canAddNew = YES;
            break;
        case PPPP_STATUS_CONNECT_TIMEOUT:
            strPPPPStatus = @"ConnectTimeout";
            _canAddNew = NO;
            break;
        case PPPP_STATUS_INVALID_USER_PWD:
            strPPPPStatus = @"Invaliduserpwd";
            _canAddNew = NO;
            break;
        default:
            strPPPPStatus = @"Unknown";
            _canAddNew = NO;
            break;
    }
    NSLog(@"PPPPStatus  %@",strPPPPStatus);
    HUD.labelText = strPPPPStatus;
}

@end