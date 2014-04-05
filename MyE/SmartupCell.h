//
//  SmartupCell.h
//  MyE
//
//  Created by space on 13-8-8.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCustomCell.h"

@interface SmartupCell : BaseCustomCell
{
    UIImageView *imageView1;
    UIImageView *imageView2;
    
    UILabel *label1;
    UILabel *label2;
}

@property (nonatomic,strong) IBOutlet UIImageView *imageView1;
@property (nonatomic,strong) IBOutlet UIImageView *imageView2;

@property (nonatomic,strong) IBOutlet UILabel *label1;
@property (nonatomic,strong) IBOutlet UILabel *label2;



@end
