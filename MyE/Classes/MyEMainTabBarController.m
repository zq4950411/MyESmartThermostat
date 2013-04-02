//
//  MyEMainTabBarController.m
//  MyE
//
//  Created by Ye Yuan on 2/3/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEMainTabBarController.h"
#import "MyELoginViewController.h"
#import "MyEVacationMasterViewController.h"

@implementation MyEMainTabBarController
@synthesize userId = _userId;
@synthesize houseId = _houseId;
@synthesize houseName = _houseName;
@synthesize tId = _tId;
@synthesize tName = _tName;
@synthesize tCount = _tCount;
@synthesize selectedTabIndex = _selectedTabIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer* tapRecon = [[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(navigationBarDoubleTap:)];
    tapRecon.numberOfTapsRequired = 2;
    [self.navigationController.navigationBar addGestureRecognizer:tapRecon];

    
    // 从navigation stack中移除第一个登录界面的ViewController
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    UIViewController *vc = [allViewControllers objectAtIndex:0];
    if ([vc isKindOfClass:[MyELoginViewController class]]) {
        NSLog(@"remove first view controller");
        [allViewControllers removeObjectAtIndex:0];//移除前一个Staycation detail view controller
        self.navigationController.viewControllers = allViewControllers;  
    }
    
    self.selectedIndex = self.selectedTabIndex;
    
    
    // 把当前选择的t的名字缩短，并设置到Thermostat Switch TabItem的title
    NSString *tName =[NSString stringWithFormat:@"%@", self.tName];
    // define the range you're interested in
    NSRange stringRange = {0, MIN([tName length], 10)};
    
    // adjust the range to include dependent chars
    stringRange = [tName rangeOfComposedCharacterSequencesForRange:stringRange];
    
    // Now you can create the short string
    NSString *shortString = [tName substringWithRange:stringRange];
    
    
    [[self.tabBar.items objectAtIndex:4] setTitle:shortString];
}
//*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// 如果T的数目大于1，才设置Thermostat Switch Tab为enabled. 否则设置为Disabled，
-(void) setTCount:(NSInteger)tCount
{
    _tCount = tCount;
    if (tCount <= 1) {
        [[self.tabBar.items objectAtIndex:4] setEnabled:NO];
    } else {
        [[self.tabBar.items objectAtIndex:4] setEnabled:YES];
    }
}
#pragma mark UITabBarDelegate Methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
//    NSLog(@"%@, index = %i", item.title, item.tag);
//    id vc = [self.viewControllers objectAtIndex:self.selectedIndex];
//    if ([vc isKindOfClass:[MyEVacationMasterViewController class]]) {
//        NSLog(@"1 MyEVacationMasterViewController is selected");
//    }
//    if ([self.selectedViewController isKindOfClass:[MyEVacationMasterViewController class]]) {
//        NSLog(@"2 MyEVacationMasterViewController is selected");
//    }
    switch (item.tag) {
        case MYE_TAB_DASHBOARD:
            item.title = @"Dashboard";
            //            self.title = @"Dashboard";
            self.selectedTabIndex = 0;
            break;
        case MYE_TAB_SHCHEDULE:
            item.title = @"Schedule";
            //           self.title = @"Schedule";
            self.selectedTabIndex = 1;
            break;
        case MYE_TAB_VACATION:
            item.title = @"Vacation";
            //            self.title = @"Vacation";
            self.selectedTabIndex = 2;
            break;
        case MYE_TAB_SETTING:
            item.title = @"Settings";
            //            self.title = @"Settings";
            self.selectedTabIndex = 3;
            break;
        default:
            break;
    }
    self.title = self.houseName;
    
    [self.selectedTabIndexDelegate saveSeletedTabIndex:self.selectedTabIndex];
}

- (void)navigationBarDoubleTap:(UIGestureRecognizer*)recognizer {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Information"
                                                    message:[NSString stringWithFormat:@"House and thermostat being viewed:\n %@ \n %@", self.houseName, self.tId]
                                                   delegate:self 
                                          cancelButtonTitle:@"Ok" 
                                          otherButtonTitles: nil];
    [alert show];
}
@end
