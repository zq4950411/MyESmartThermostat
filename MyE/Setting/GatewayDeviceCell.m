//
//  GatewayDeviceCell.m
//  MyE
//
//  Created by space on 13-8-30.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "GatewayDeviceCell.h"
#import "MyEDevice.h"

@implementation GatewayDeviceCell

@synthesize arrowImageView;
@synthesize tf;
@synthesize aliasTf;

@synthesize label11;
@synthesize label12;
@synthesize label21;
@synthesize label22;
@synthesize label31;
@synthesize label32;
@synthesize label41;
@synthesize label42;

@synthesize swch;

@synthesize isFolder;

@synthesize delegate;

-(void) click:(UIButton *) sender
{
    if ([object isKindOfClass:[MyEDevice class]])
    {
        MyEDevice *smart = (MyEDevice *)object;
        if (smart.isExpand)
        {
            self.arrowImageView.image = [UIImage imageNamed:@"DownAccessory.png"];
            if ([delegate respondsToSelector:@selector(unexpand:)])
            {
                [delegate unexpand:self];
            }
        }
        else
        {
            self.arrowImageView.image = [UIImage imageNamed:@"UpAccessory.png"];
            if ([delegate respondsToSelector:@selector(expand:)])
            {
                [delegate expand:self];
            }
        }
    }
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    if ([object isKindOfClass:[MyEDevice class]])
    {
        MyEDevice *smart = (MyEDevice *)object;
        
        if (smart.rfStatus.intValue == -1)
        {
            headImageView.image = [UIImage imageNamed:@"noconnection"];
        }
        else if(smart.rfStatus.intValue == 1)
        {
            headImageView.image = [UIImage imageNamed:@"signal1"];
        }
        else if(smart.rfStatus.intValue == 2)
        {
            headImageView.image = [UIImage imageNamed:@"signal2"];
        }
        else if(smart.rfStatus.intValue == 3)
        {
            headImageView.image = [UIImage imageNamed:@"signal3"];
        }
        else if(smart.rfStatus.intValue == 4)
        {
            headImageView.image = [UIImage imageNamed:@"signal4"];
        }
        
        if (!smart.isExpand)
        {
            self.arrowImageView.image = [UIImage imageNamed:@"DownAccessory.png"];
        }
        else
        {
            self.arrowImageView.image = [UIImage imageNamed:@"UpAccessory.png"];
        }
        
        label11.text = smart.deviceName;
        label22.text = smart.tid;
        aliasTf.text = smart.deviceName;
        
        //0表示美国温度控制器，1  红外转发器，2 智能插座，3  通用控制器，4 安防设备，6智能开关
        if (smart.typeId.intValue == 0)
        {
            self.label41.text = @"Key pad lock";
            self.tf.text = @"Thermostat";
        }
        else if(smart.typeId.intValue == 1)
        {
            self.label41.text = @"Battert stretch mode";
            self.tf.text = @"Smart Remote";
        }
        else if(smart.typeId.intValue == 2)
        {
            self.tf.text = @"Smart Plug";
        }
        else if(smart.typeId.intValue == 3)
        {
            self.tf.text = @"Sprinkler";
        }else if (smart.typeId.intValue == 6)
            self.tf.text = @"Smart Switch";
        
        [self.swch setOn:![smart.switchStatus boolValue]];
        
        if (smart.rfStatus.intValue == -1)
        {
            self.swch.enabled = NO;
        }
        else
        {
            self.swch.enabled = YES;
        }
    }
    
    [self.headButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
}


@end
