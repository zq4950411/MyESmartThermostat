//
//  DeviceCell.m
//  MyE
//
//  Created by space on 13-8-24.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "DeviceCell.h"
#import "DeviceEntity.h"

@implementation DeviceCell

-(void) layoutSubviews
{
    [super layoutSubviews];
    if ([object isKindOfClass:[DeviceEntity class]])
    {
        DeviceEntity *device = (DeviceEntity *)object;
        self.userLabel.text = device.deviceName;
        
        if (device.terminalType.intValue == 0)
        {
            self.dateLabel.text = device.point;
            if (device.controlMode.intValue == 1)
            {
                self.headImageView.image = [UIImage imageNamed:@"Tb_Heating01.png"];
            }
            else if (device.controlMode.intValue == 2)
            {
                self.headImageView.image = [UIImage imageNamed:@"Tb_Cooling01.png"];
            }
            else if (device.controlMode.intValue == 3)
            {
                self.headImageView.image = [UIImage imageNamed:@"Tb_AutoRun.png"];
            }
            else if (device.controlMode.intValue == 4)
            {
                self.headImageView.image = [UIImage imageNamed:@"Tb_EmgH01.png"];
            }
            else if (device.controlMode.intValue == 5)
            {
                self.headImageView.image = [UIImage imageNamed:@"Tb_Off.png"];
            }
            
            
            
            self.headImageView.hidden = NO;
        }
        else if(device.terminalType.intValue == 1)
        {
            self.headImageView.hidden = YES;
            self.dateLabel.text = device.instructionName;
        }
        else if(device.terminalType.intValue == 2)
        {
            self.headImageView.hidden = YES;
            self.dateLabel.text = device.instructionName;
        }
        else if(device.terminalType.intValue == 3)
        {
            self.headImageView.hidden = YES;
            self.dateLabel.text = nil;
        }
    }
}

@end
