//
//  MyEIRDefaultViewController.h
//  MyE
//
//  Created by 翟强 on 14-5-12.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEControlBtn.h"
#import "MyEDevice.h"
#import "MyEInstructions.h"
#import "MyEUtil.h"
#import "MyEHouseData.h"
#import "MyEDataLoader.h"
#import "MBProgressHUD.h"
#import "MZFormSheetController.h"
#import "SVProgressHUD.h"

@interface MyEIrDefaultViewController : UIViewController<MyEDataLoaderDelegate>
{
    MBProgressHUD *HUD;
    NSArray *_keyBtns;
    NSInteger _initNumber; //表示当前模板从什么数字开始
}
@property (nonatomic) BOOL isControlMode;
@property (nonatomic, strong) MyEInstructions *instructions;
@property (nonatomic, strong) MyEDevice *device;

@end
