//
//  TwoDatePicker.m
//  MyE
//
//  Created by space on 13-8-15.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "TwoDatePicker.h"
#import "UIViewExtention.h"

@implementation TwoDatePicker

@synthesize date1;
@synthesize date2;

@synthesize delegate;

-(void) setDate1String:(NSString *) string1 andDate2String:(NSString *) string2
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    self.date1.date = [formatter dateFromString:string1];
    self.date2.date = [formatter dateFromString:string2];
    
    dateString1 = string1;
    dateString2 = string2;
}

-(NSString *) dateToString:(NSDate *) date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH"];
    
    NSString *h = [formatter stringFromDate:date];
    
    [formatter setDateFormat:@"mm"];
    NSString *m = [formatter stringFromDate:date];
    
    if (m.intValue == 0)
    {
        m = @"00";
    }
    else
    {
        m = @"30";
    }
    
    return [NSString stringWithFormat:@"%@:%@",h,m];
}

-(void) awakeFromNib
{
    dateString1 = @"12:00";
    dateString2 = @"12:00";
    
    if ([delegate respondsToSelector:@selector(datePickValue:andTag:)])
    {
        [delegate datePickValue:[NSString stringWithFormat:@"%@-%@",dateString1,dateString2] andTag:self.tag];
    }
}

-(NSString *) getDateString
{
    return nil;
}

-(IBAction) valueChange:(UIDatePicker *) sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    if (sender.tag == 0)
    {
        dateString1 = [formatter stringFromDate:self.date1.date];
        //self.date2.minimumDate = [[NSDate alloc] initWithTimeInterval:30 sinceDate:self.date1.date];
        if ([@"00:00" isEqualToString:dateString2])
        {
            dateString2 = [NSString stringWithFormat:@"%@",@"24:00"];
        }
    }
    else
    {
        dateString2 = [formatter stringFromDate:self.date2.date];
        //self.date1.maximumDate = [[NSDate alloc] initWithTimeInterval:-30 sinceDate:self.date2.date];
        if ([@"00:00" isEqualToString:dateString2])
        {
            dateString2 = [NSString stringWithFormat:@"%@",@"24:00"];
        }
    }
    
//    if (dateString1 == nil)
//    {        
//        dateString1 = [self dateToString:self.date1.date];
//    }
//    
//    if (dateString2 == nil)
//    {
//        
//        dateString2 = [self dateToString:self.date2.date];
//    }
    
    if ([delegate respondsToSelector:@selector(datePickValue:andTag:)])
    {
        [delegate datePickValue:[NSString stringWithFormat:@"%@-%@",dateString1,dateString2] andTag:self.tag];
    }
    
    if ([delegate respondsToSelector:@selector(datePickValueStid:etid:andTag:)])
    {
        [delegate datePickValueStid:dateString1 etid:dateString2 andTag:self.tag];
    }
}

-(void) layoutSubviews
{
    [super layoutSubviews];
}


@end
