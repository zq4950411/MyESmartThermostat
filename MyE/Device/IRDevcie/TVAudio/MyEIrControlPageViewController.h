//
//  MyEIrControlPageViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-12-17.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SUNSlideSwitchView.h"
#import "MyEAudioDefaultViewController.h"
#import "MyETVDefaultViewController.h"
#import "MyEIrUserKeyViewController.h"


@interface MyEIrControlPageViewController : UIViewController<SUNSlideSwitchViewDelegate>

@property (nonatomic, strong) SUNSlideSwitchView *slideSwitchView;

@property (nonatomic, strong) MyETVDefaultViewController *tvDefaultViewController;
@property (nonatomic, strong) MyEAudioDefaultViewController *audioDefaultViewController;

@property (nonatomic, strong) MyEIrUserKeyViewController *irUserKeyViewController;
@property (nonatomic, weak) MyEDevice *device;

@end
