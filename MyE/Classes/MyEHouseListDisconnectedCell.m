//
//  MyEHouseListDisconnectedCell.m
//  MyE
//
//  Created by Ye Yuan on 5/3/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEHouseListDisconnectedCell.h"

@implementation MyEHouseListDisconnectedCell
@synthesize  textLabel, detailTextLabel;
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

@end
