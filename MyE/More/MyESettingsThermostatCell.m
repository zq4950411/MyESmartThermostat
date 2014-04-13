//
//  MyESettingsThermostatCell.m
//  MyE
//
//  Created by Ye Yuan on 3/16/13.
//  Copyright (c) 2013 MyEnergy Domain. All rights reserved.
//

#import "MyESettingsThermostatCell.h"

@implementation MyESettingsThermostatCell

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

#pragma mark 插座方法
- (IBAction)changeKaypadLock:(id)sender {
    [self.delegate didKeypadSwitchChanged:self];
}
@end
