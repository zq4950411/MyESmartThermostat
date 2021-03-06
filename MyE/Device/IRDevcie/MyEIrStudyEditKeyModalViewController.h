//
//  MyEIrStudyEditKeyModalViewController.h
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/3/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEIrDefaultViewController.h"
#import "ACPButton.h"

@interface MyEIrStudyEditKeyModalViewController : UIViewController<UITextFieldDelegate,MyEDataLoaderDelegate,MBProgressHUDDelegate>{
    MBProgressHUD *HUD;
    NSInteger studyQueryTimes;
}

@property (nonatomic, strong) MyEInstructions *instructions;
@property (nonatomic, weak) MyEDevice *device;
@property (nonatomic, strong) MyEInstruction *instruction;
@property (nonatomic, assign) BOOL isAddKey;
@property (weak, nonatomic) IBOutlet UITextField *keyNameTextfield;

@property (weak, nonatomic) IBOutlet UIButton *learnBtn;
@property (weak, nonatomic) IBOutlet UIButton *validateKeyBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteKeyBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@end
