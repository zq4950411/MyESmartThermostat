//
//  CommonCell.h
//  MyE
//
//  Created by space on 13-8-9.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCustomCell.h"

@interface CommonCell : BaseCustomCell
{
    UITextField *tf;
}

@property (nonatomic,strong) IBOutlet UITextField *tf;

@end
