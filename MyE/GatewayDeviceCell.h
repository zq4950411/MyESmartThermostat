//
//  GatewayDeviceCell.h
//  MyE
//
//  Created by space on 13-8-30.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseCustomCell.h"

@class GatewayDeviceCell;

@protocol GatewayDelegate <NSObject>

-(void) expand:(GatewayDeviceCell *) cell;
-(void) unexpand:(GatewayDeviceCell *) cell;

@end

@interface GatewayDeviceCell : BaseCustomCell
{
    UIImageView *arrowImageView;
    UITextField *tf;
    UITextField *aliasTf;
    
    UILabel *label11;
    UILabel *label12;
    
    UILabel *label21;
    UILabel *label22;
    
    UILabel *label31;
    UILabel *label32;
    
    UILabel *label41;
    UILabel *label42;
    
    UISwitch *swch;
    
    BOOL isFolder;
    
    __weak id<GatewayDelegate> delegate;
}

@property (nonatomic,strong) IBOutlet UIImageView *arrowImageView;
@property (nonatomic,strong) IBOutlet UITextField *tf;
@property (nonatomic,strong) IBOutlet UITextField *aliasTf;

@property (nonatomic,strong) IBOutlet UILabel *label11;
@property (nonatomic,strong) IBOutlet UILabel *label12;

@property (nonatomic,strong) IBOutlet UILabel *label21;
@property (nonatomic,strong) IBOutlet UILabel *label22;

@property (nonatomic,strong) IBOutlet UILabel *label31;
@property (nonatomic,strong) IBOutlet UILabel *label32;

@property (nonatomic,strong) IBOutlet UILabel *label41;
@property (nonatomic,strong) IBOutlet UILabel *label42;

@property (nonatomic,strong) IBOutlet UISwitch *swch;

@property (nonatomic,weak) IBOutlet id<GatewayDelegate> delegate;
@property (nonatomic,assign) BOOL isFolder;

@end
