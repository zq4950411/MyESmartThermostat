//
//  SequentialCell.m
//  MyE
//
//  Created by space on 13-8-22.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SequentialCell.h"

@implementation SequentialCell


-(NSString *) getSelectedButtons
{
    NSMutableString *sb = [NSMutableString string];    
    for (int i = 10; i < 16; i++)
    {
        UIButton *tempButton = (UIButton *)[self.contentView viewWithTag:i];;
        if (tempButton.selected)
        {
            [sb appendString:@"1"];
        }
        else
        {
            [sb appendString:@"0"];
        }
    }
    return sb;
}

-(void) awakeFromNib
{
    NSArray *array = self.contentView.subviews;
    for (int i = 0; i < array.count; i++)
    {
        UIButton *tempButton = (UIButton *)[array objectAtIndex:i];
        if ([tempButton isKindOfClass:[UIButton class]])
        {
            [tempButton setBackgroundColor:[UIColor whiteColor]];
            [tempButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            tempButton.layer.shadowColor = [UIColor blackColor].CGColor;
            tempButton.layer.shadowOffset = CGSizeMake(2, 2);
            tempButton.layer.shadowOpacity = 0.5;
            tempButton.layer.shadowRadius = 2.0;
        }
    }
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    if ([object isKindOfClass:[NSString class]])
    {
        NSString *string = (NSString *)object;
        for (int i = 0; i < string.length; i++)
        {
            UIButton *tempButton = (UIButton *)[self.contentView viewWithTag:(i + 10)];
            char c = [string characterAtIndex:i];
            if (c == '0')
            {
                tempButton.selected = NO;
                [tempButton setBackgroundColor:[UIColor whiteColor]];
            }
            else
            {
                tempButton.selected = YES;
                [tempButton setBackgroundColor:[UIColor greenColor]];
            }
        }
    }
//    if ([object isKindOfClass:[NSArray class]])
//    {
//        NSArray *array = (NSArray *)object;
//        for (int i = 0 ; i < array.count; i++)
//        {
//            int tag = [[array objectAtIndex:i] intValue];
//            UIButton *tempButton = (UIButton *)[self.contentView viewWithTag:tag];
//            if (tempButton)
//            {
//                tempButton.selected = YES;
//                if (tempButton.selected)
//                {
//                    tempButton.backgroundColor = [UIColor greenColor];
//                }
//                else
//                {
//                    tempButton.backgroundColor = [UIColor whiteColor];
//                }
//            }
//        }
//    }
}

-(void) buttonClick:(UIButton *) sender
{
    sender.selected = !sender.selected;
    if (sender.selected)
    {
        sender.backgroundColor = [UIColor greenColor];
    }
    else
    {
        sender.backgroundColor = [UIColor whiteColor];
    }
}

@end
