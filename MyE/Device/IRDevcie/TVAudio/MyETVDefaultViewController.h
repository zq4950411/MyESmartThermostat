//
//  MyETVDefaultViewController.h
//  MyE
//
//  Created by 翟强 on 14-4-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEIrDefaultViewController.h"

@interface MyETVDefaultViewController : MyEIrDefaultViewController

@property (strong, nonatomic) IBOutletCollection(MyEControlBtn) NSArray *controlBtns;
@end
