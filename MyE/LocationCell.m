//
//  LocationCell.m
//  MyE
//
//  Created by space on 13-8-21.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "LocationCell.h"
#import "JYTextField.h"

#import "NSDictionary+Convert.h"

@implementation LocationCell

@synthesize tf;

-(void) awakeFromNib
{
    JYTextField *jtf = (JYTextField *)tf;
    
    [jtf setCornerRadio:5
            borderColor:RGB(166, 166, 166)
            borderWidth:2
             lightColor:RGB(55, 154, 255)
              lightSize:8
       ligthBorderColor:RGB(235, 235, 235)
     ];
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dic = (NSDictionary *)object;
        if ([[dic valueToStringForKey:@"locationId"] isEqualToString:@"0"])
        {
            self.headImageView.hidden = YES;
            self.headButton.hidden = YES;
            self.userInteractionEnabled = YES;
        }
        else
        {
            self.userInteractionEnabled = YES;
        }
        self.tf.text = [dic valueToStringForKey:@"locationName"];
    }
}





@end
