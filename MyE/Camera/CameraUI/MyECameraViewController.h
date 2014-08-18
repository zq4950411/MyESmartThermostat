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
#import "ParamNotifyProtocol.h"

#import "MyECamera.h"

#import "SnapshotProtocol.h"

@interface MyECameraViewController : UIViewController
<ImageNotifyProtocol,DateTimeProtocol,SdcardScheduleProtocol,ParamNotifyProtocol,SnapshotProtocol> {
}
@property CPPPPChannelManagement* m_PPPPChannelMgt;
@property (nonatomic, weak) MyECamera *camera;
@property (nonatomic, strong) MyECameraParam *cameraParam;

@property (nonatomic, strong) UIView *mainPortraitView;
@property (nonatomic, strong) UIView *mainLandscapeView;
/*----------------info view---------------------*/
@property (weak, nonatomic) IBOutlet UIView *infoView;
/*-------------actionView--------------*/
@property (weak, nonatomic) IBOutlet UIView *actionView;

@property (nonatomic, weak) IBOutlet UIImageView* playView;
@property (nonatomic, strong) UIImageView *landscapePlayView;

@property (weak, nonatomic) IBOutlet UIButton *talkBtn;
@property (weak, nonatomic) IBOutlet UIButton *listenBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *actionSeg;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *infoLabels;

@end
