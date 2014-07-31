//
//  MyEAcInstructionListCell.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-23.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcInstructionListCell.h"

@implementation MyEAcInstructionListCell
@synthesize order,power,mode,windLevel,temperature,status,orderLabel,powerLabel,modeLabel,windLevelLabel,temperatureLabel,studyLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark - setter methods 
-(void)setOrder:(NSInteger)o{
    orderLabel.text = [NSString stringWithFormat:@"%li",(long)o];
}
-(void)setPower:(NSInteger)p{
    switch (p) {
        case 0:
            powerLabel.text = @"ON";
            break;
        default:
            powerLabel.text = @"OFF";
            break;
    }
}
-(void)setMode:(NSInteger)m{
    switch (m) {
        case 1:
            modeLabel.text = @"Auto";
            break;
        case 2:
            modeLabel.text = @"Heating";
            break;
        case 3:
            modeLabel.text = @"Cooling";
            break;
        case 4:
            modeLabel.text = @"Dehumidify";
            break;
        default:
            modeLabel.text = @"Fan Only";
            break;
    }
}
-(void)setWindLevel:(NSInteger)w{
    switch (w) {
        case 0:
            windLevelLabel.text = @"Auto";
            break;
        case 1:
            windLevelLabel.text = @"Lv1";
            break;
        case 2:
            windLevelLabel.text = @"Lv2";
            break;
        default:
            windLevelLabel.text = @"Lv3";
            break;
    }
}
-(void)setTemperature:(NSInteger)t{
    temperatureLabel.text = [NSString stringWithFormat:@"%li℃",(long)t];
}
-(void)setStatus:(NSInteger)s{
    switch (s) {
        case 0:
            studyLabel.text = @"unstudied";
            break;
        case 1:
            studyLabel.text = @"Studied";
            break;
        default:
            studyLabel.text = @"download";
            break;
    }
}
@end
