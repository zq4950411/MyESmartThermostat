//
//  ChooseChannelViewController.m
//  MyE
//
//  Created by space on 13-9-4.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "ChooseChannelViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "ControlViewController.h"


@implementation ChooseChannelViewController

@synthesize pickView;

@synthesize channel;
@synthesize duration;
@synthesize value;
@synthesize index;

-(id) initWithValue:(NSDictionary *) d andIndex:(int) i
{
    if (self = [super init])
    {
        self.value = d;
        self.index = i;
    }
    
    return self;
}

-(IBAction) dimss:(UIControl *) sender
{
    [parentVC dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

-(IBAction) buttonClicK:(UIButton *) sender
{
    if ([parentVC isKindOfClass:[ControlViewController class]])
    {
        ControlViewController *cc = (ControlViewController *)parentVC;
        
        NSString *string = [NSString stringWithFormat:@"{\"channel\":%d,\"duration\":%d}",channel,duration];
       
        if (index == -1)
        {
            [cc refreshWithChannel:string];
        }
        else
        {
            [cc refreshWithChannel:string andIndex:index];
        }
    }
    
    [self.parentVC dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}


-(void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0)
    {
        self.channel = row + 1;
    }
    else
    {
        self.duration = row + 1;
    }
}

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
    {
        return 6;
    }
    else
    {
        return 1440;
    }
}

-(NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = nil;
    if (component == 0)
    {
        title = [NSString stringWithFormat:@"channel:%d",(row + 1)];
    }
    else
    {
        title = [NSString stringWithFormat:@"%d",row + 1];
    }
    
    return title;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.channel = 1;
    self.duration = 1;
    
    if (value != nil)
    {
        int selectedChannel = [[value objectForKey:@"channel"] intValue] - 1;
        int selectedDuration = [[value objectForKey:@"duration"] intValue] - 1;
        
        self.channel = selectedChannel + 1;
        self.duration = selectedDuration + 1;
        
        [self.pickView selectRow:selectedChannel inComponent:0 animated:YES];
        [self.pickView selectRow:selectedDuration inComponent:1 animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
