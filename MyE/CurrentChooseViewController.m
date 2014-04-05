//
//  CurrentChooseViewController.m
//  MyE
//
//  Created by space on 13-9-9.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "CurrentChooseViewController.h"
#import "PlugControlViewController.h"
#import "UIViewController+MJPopupViewController.h"

@implementation CurrentChooseViewController




-(id) initWithIndex:(int) index
{
    if (self = [super init])
    {
        t = index;
    }
    
    return self;
}


-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([parentVC isKindOfClass:[PlugControlViewController class]])
    {
        PlugControlViewController *cc = (PlugControlViewController *)parentVC;
        [cc resetCurrent:[NSString stringWithFormat:@"%d",row + 1]];
    }
    
    [self.parentVC dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 12;
}

-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%d",(row + 1)];
}





- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIPickerView *pick = (UIPickerView *)self.view;
    [pick selectRow:t - 1 inComponent:0 animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
