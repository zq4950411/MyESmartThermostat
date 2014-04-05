//
//  SmartupCell.m
//  MyE
//
//  Created by space on 13-8-8.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "SmartupCell.h"
#import "SmartUp.h"

@implementation SmartupCell

@synthesize imageView1;
@synthesize imageView2;

@synthesize label1;
@synthesize label2;


-(void) layoutSubviews
{
    [super layoutSubviews];
    
    if ([object isKindOfClass:[SmartUp class]])
    {
        SmartUp *temp = (SmartUp *)object;
        
        label1.text = temp.deviceName;
        label2.text = temp.locationName;
        
        if (temp.rfStatus.intValue == -1)
        {
            imageView1.image = [UIImage imageNamed:@"xh0.png"];
        }
        else if(temp.rfStatus.intValue == 1)
        {
            imageView1.image = [UIImage imageNamed:@"xh1.png"];
        }
        else if(temp.rfStatus.intValue == 2)
        {
            imageView1.image = [UIImage imageNamed:@"xh2.png"];
        }
        else if(temp.rfStatus.intValue == 3)
        {
            imageView1.image = [UIImage imageNamed:@"xh3.png"];
        }
        else if(temp.rfStatus.intValue == 4)
        {
            imageView1.image = [UIImage imageNamed:@"xh4.png"];
        }
        
        //2:TV,  3: Audio, 4:Automated Curtain, 5: Other,  6 智能插座,7:通用控制器
        if (temp.typeId.intValue == 2)
        {
            imageView2.image = [UIImage imageNamed:@"tv.png"];
        }
        else if (temp.typeId.intValue == 3)
        {
            imageView2.image = [UIImage imageNamed:@"box.png"];
        }
        else if (temp.typeId.intValue == 4)
        {
            imageView2.image = [UIImage imageNamed:@"chuanglian.png"];
        }
        else if (temp.typeId.intValue == 5)
        {
            imageView2.image = [UIImage imageNamed:@"tel.png"];
        }
        else if (temp.typeId.intValue == 6)
        {
            if (temp.switchStatus.intValue == 0)
            {
                imageView2.image = [UIImage imageNamed:@"plug_off.png"];
            }
            else
            {
               imageView2.image = [UIImage imageNamed:@"plug_on.png"]; 
            }
        }
        else if (temp.typeId.intValue == 7)
        {
            imageView2.image = [UIImage imageNamed:@"sprinkler.png"];
        }
        else if (temp.typeId.intValue == 8){
            if (temp.switchStatus.intValue == 0) {
                imageView2.image = [UIImage imageNamed:@"switch1-off"];
            }else
                imageView2.image = [UIImage imageNamed:@"switch1-on"];
        }
    }
}


@end
