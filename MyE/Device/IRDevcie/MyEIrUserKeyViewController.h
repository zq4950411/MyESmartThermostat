//
//  MyEIrUserKeyViewController.h
//  MyE
//
//  Created by 翟强 on 14-5-10.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEIrUserKeyViewController : UITableViewController<MyEDataLoaderDelegate>

@property (nonatomic) BOOL isControlMode;
@property (nonatomic, strong) MyEDevice *device;
@property (nonatomic, strong) MyEInstructions *instructions;

@end
