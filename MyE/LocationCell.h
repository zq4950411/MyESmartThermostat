//
//  LocationCell.h
//  MyE
//
//  Created by space on 13-8-21.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseCustomCell.h"

@interface LocationCell : BaseCustomCell
{
    UITextField *tf;
}

@property (nonatomic,strong) IBOutlet UITextField *tf;

@end
