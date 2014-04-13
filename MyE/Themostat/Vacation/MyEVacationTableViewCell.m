//
//  MyEVacationTableViewCell.m
//  MyE
//
//  Created by Ye Yuan on 3/14/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEVacationTableViewCell.h"

@implementation MyEVacationTableViewCell
@synthesize nameLabel = _nameLabel, leaveDateLabel = _leaveDateLabel;

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
