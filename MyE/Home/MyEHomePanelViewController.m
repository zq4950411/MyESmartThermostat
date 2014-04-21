//
//  MyEHomePanelViewController.m
//  MyE
//
//  Created by Ye Yuan on 4/14/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import "MyEHomePanelViewController.h"
#import "SWRevealViewController.h"

@interface MyEHomePanelViewController ()

@end

@implementation MyEHomePanelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Change button color
    _sidebarButton.tintColor = [UIColor colorWithWhite:0.3f alpha:0.82f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    
    [self.weatherTile setFlatStyleType:ACPButtonOK];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)TestAction:(id)sender {
    if([self.inflLabel.text isEqualToString:@"1111"])
        self.inflLabel.text = @"2222";
    else
        self.inflLabel.text = @"1111";
}
@end
