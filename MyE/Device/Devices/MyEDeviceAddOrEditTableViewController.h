//
//  MyEDeviceAddOrEditTableViewController.h
//  MyE
//
//  Created by 翟强 on 14-4-22.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEDevicesViewController.h"
#import "MYEPickerView.h"
#import "EGORefreshTableHeaderView.h"
#import "MyEInstructionManageViewController.h"

@interface MyEDeviceAddOrEditTableViewController : UITableViewController<MyEDataLoaderDelegate,UIAlertViewDelegate,MYEPickerViewDelegate,EGORefreshTableHeaderDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *acTypeLbl;
@property (nonatomic, strong) MyEMainDevice *mainDevice;
@property (nonatomic, strong) MyEDeviceEdit *deviceEdit;
@property (nonatomic, strong) MyEDevice *device;
@property (nonatomic, strong) MyESocketInfo *socketInfo;
@property (nonatomic) BOOL isAddDevice;
@property (weak, nonatomic) IBOutlet UIButton *irCodeBtn;

@end
