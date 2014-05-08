//
//  MyEAudioDefaultViewController.h
//  MyE
//
//  Created by 翟强 on 14-4-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEAudioDefaultViewController : UIViewController
@property (strong, nonatomic) IBOutletCollection(MyEControlBtn) NSArray *controlBtns;
@property (nonatomic, strong) MyEDevice *device;
@property (nonatomic) BOOL isControlMode;
@end
