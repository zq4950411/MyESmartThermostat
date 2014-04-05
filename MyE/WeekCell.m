//
//  WeekCell.m
//  MyE
//
//  Created by space on 13-8-15.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WeekCell.h"

@implementation WeekCell

@synthesize button1;
@synthesize button2;
@synthesize button3;
@synthesize button4;
@synthesize button5;
@synthesize button6;
@synthesize button7;

@synthesize selectedArray;

-(NSMutableArray *) getSelectedButtons
{
    NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:0];
    NSArray *array = self.contentView.subviews;
    
    for (int i = 0; i < array.count; i++)
    {
        UIButton *tempButton = (UIButton *)[array objectAtIndex:i];
        if ([tempButton isKindOfClass:[UIButton class]])
        {
            if (tempButton.selected)
            {
                [retArray addObject:[NSNumber numberWithInt:tempButton.tag]];
            }
        }
    }
    return retArray;
}

-(void) awakeFromNib
{
    NSArray *array = self.contentView.subviews;
    for (int i = 0; i < array.count; i++)
    {
        UIButton *tempButton = (UIButton *)[array objectAtIndex:i];
        if ([tempButton isKindOfClass:[UIButton class]])
        {
            if (self.tag == 0)
            {
                [tempButton setBackgroundColor:[UIColor clearColor]];
            }
            else
            {
                [tempButton setBackgroundColor:[UIColor whiteColor]];
            }
            
            [tempButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [tempButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [tempButton setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
            
            if (self.tag == 1)
            {
                tempButton.layer.shadowColor = [UIColor blackColor].CGColor;
                tempButton.layer.shadowOffset = CGSizeMake(2, 2);
                tempButton.layer.shadowOpacity = 0.5;
                tempButton.layer.shadowRadius = 2.0;
            }
        }
    }
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    NSArray *array = self.contentView.subviews;
    
    for (int i = 0; i < array.count; i++)
    {
        UIButton *tempButton = (UIButton *)[array objectAtIndex:i];
        if ([tempButton isKindOfClass:[UIButton class]])
        {
            tempButton.selected = NO;
            tempButton.backgroundColor = [UIColor whiteColor];
        }
    }
    
    
    if ([object isKindOfClass:[NSArray class]])
    {
        NSArray *array = (NSArray *)object;
        for (int i = 0 ; i < array.count; i++)
        {
            int tag = [[array objectAtIndex:i] intValue];
            UIButton *tempButton = (UIButton *)[self.contentView viewWithTag:tag];
            if ([tempButton isKindOfClass:[UIButton class]])
            {
                if (tempButton)
                {
                    tempButton.selected = YES;
                }
                if (self.tag == 1)
                {
                    if (tempButton.selected)
                    {
                        tempButton.backgroundColor = [UIColor greenColor];
                    }
                    else
                    {
                        tempButton.backgroundColor = [UIColor whiteColor];
                    }
                }
            }
        }
    }
    
    for (int i = 0; i < self.selectedArray.count; i++)
    {
        int tag = [[self.selectedArray objectAtIndex:i] intValue];
        
        UIButton *tempButton = (UIButton *)[self.contentView viewWithTag:tag];
        if ([tempButton isKindOfClass:[UIButton class]])
        {
            tempButton.enabled = NO;
            [tempButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
    }
}

-(void) buttonClick:(UIButton *) sender
{
    sender.selected = !sender.selected;
    
    if (self.tag == 1)
    {
        if (sender.selected)
        {
            sender.backgroundColor = [UIColor greenColor];
        }
        else
        {
            sender.backgroundColor = [UIColor whiteColor];
        }
    }
    
    self.object = [self getSelectedButtons];
}










@end
