//
//  MyEStaycationTableViewCell.m
//  MyE
//
//  Created by Ye Yuan on 3/14/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEStaycationTableViewCell.h"

@implementation MyEStaycationTableViewCell
@synthesize nameLabel = _nameLabel,  startDateLabel = _startDateLabel;

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
