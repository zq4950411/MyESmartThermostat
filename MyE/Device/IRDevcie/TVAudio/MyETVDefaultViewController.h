//
//  MyETVDefaultViewController.h
//  MyE
//
//  Created by 翟强 on 14-4-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEIrStudyEditKeyModalViewController.h"
@interface MyETVDefaultViewController : UIViewController<MyEDataLoaderDelegate>

@property (strong, nonatomic) IBOutletCollection(MyEControlBtn) NSArray *controlBtns;

@property (nonatomic) BOOL isControlMode;
@property (nonatomic, strong) MyEInstructions *instructions;
@property (nonatomic, strong) MyEDevice *device;
@end
