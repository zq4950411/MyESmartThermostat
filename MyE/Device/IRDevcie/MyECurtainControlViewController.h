//
//  MyECurtainControlViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-12-11.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEIRDefaultViewController.h"
@interface MyECurtainControlViewController : MyEIRDefaultViewController

@property (strong, nonatomic) IBOutletCollection(MyEControlBtn) NSArray *controlBtns;

@end
