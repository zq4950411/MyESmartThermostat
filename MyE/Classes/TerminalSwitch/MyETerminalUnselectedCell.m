//
//  MyETerminalUnselectedCell.m
//  MyE
//
//  Created by Ye Yuan on 3/3/13.
//  Copyright (c) 2013 MyEnergy Domain. All rights reserved.
//

#import "MyETerminalUnselectedCell.h"

@implementation MyETerminalUnselectedCell

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
