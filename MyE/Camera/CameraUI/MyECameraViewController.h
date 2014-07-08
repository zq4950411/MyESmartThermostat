//
//  MyECameraViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 4/23/14.
//  Copyright (c) 2014 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "PPPP_API.h"
#include "PPPPChannelManagement.h"
#import "ImageNotifyProtocol.h"
#import "SearchCameraResultProtocol.h"
#import "SearchDVS.h"
#import "ParamNotifyProtocol.h"
#import "MyECamera.h"
#import "SnapshotProtocol.h"

@interface MyECameraViewController : UIViewController
<ImageNotifyProtocol,ParamNotifyProtocol,DateTimeProtocol,SdcardScheduleProtocol,WifiParamsProtocol> {
    CSearchDVS* dvs;
    /*镜像参数*/
    int flip;
}
@property CPPPPChannelManagement* m_PPPPChannelMgt;
@property (nonatomic, weak) MyECamera *camera;
@property (nonatomic, strong) UIView *mainPortraitView;
@property (nonatomic, strong) UIView *mainLandscapeView;
/*----------------info view---------------------*/
@property (weak, nonatomic) IBOutlet UIView *infoView;
/*-------------actionView--------------*/
@property (weak, nonatomic) IBOutlet UIView *actionView;

@property (nonatomic, weak) IBOutlet UIImageView* playView;
@property (nonatomic, strong) UIImageView *landscapePlayView;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *infoLabels;

@end
