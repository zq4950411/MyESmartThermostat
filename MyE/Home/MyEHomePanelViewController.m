//
//  MyEHomePanelViewController.m
//  MyE
//
//  Created by Ye Yuan on 4/14/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import "MyEHomePanelViewController.h"
#import "SWRevealViewController.h"
#import "MyEHouseListViewController.h"
#import "MyEAccountData.h"
#import "MyEThermostatData.h"
#import "MyEDashboardData.h"
#import "MyENext24HrsScheduleViewController.h"
#import "MyEWeeklyScheduleViewController.h"
#import "MyEVacationMasterViewController.h"

@interface MyEHomePanelViewController ()
- (void)configureView;

// 判定是否服务器相应正常，如果正常返回YES，如果服务器相应为-999/-998，
// 那么函数迫使Navigation View Controller跳转到Houselist view，并返回NO。
// 如果要中断外层函数执行，必须捕捉此函数返回的NO值，并中断外层函数。
- (BOOL)_processHttpRespondForString:(NSString *)respondText;
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
    
    [self.elecUsageTile setFlatStyleType:ACPButtonOK];
    [self.elecUsageTile setFlatStyle:[UIColor blueColor] andHighlightedColor:[UIColor grayColor]];
    [self.elecUsageTile setBorderStyle:[UIColor clearColor] andInnerColor:[UIColor clearColor] ];
    [self.thermostatTile setFlatStyleType:ACPButtonOK];
    [self.thermostatTile setFlatStyle:[UIColor blueColor] andHighlightedColor:[UIColor grayColor]];
    [self.thermostatTile setBorderStyle:[UIColor clearColor] andInnerColor:[UIColor clearColor] ];
    [self.faultInfoTile setFlatStyleType:ACPButtonOK];
    [self.faultInfoTile setFlatStyle:[UIColor blueColor] andHighlightedColor:[UIColor grayColor]];
    [self.faultInfoTile setBorderStyle:[UIColor clearColor] andInnerColor:[UIColor clearColor] ];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self downloadModelFromServer];
    
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

- (IBAction)goElecUsage:(id)sender {
    [MyEUtil showMessageOn:self.view withMessage:@"Click Electricity Usage"];
}

- (IBAction)goFaultInfo:(id)sender {
    [MyEUtil showMessageOn:self.view withMessage:@"Click FaultInfo"];
    NSLog(@"FaultInfo");
}

- (IBAction)goThermostat:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"thermostat" bundle:nil];
    UITabBarController *vc = [storyboard instantiateViewControllerWithIdentifier:@"tab_bar_controller"];
    
    // 	温控器所有二级控制页面（Dashboard, Next24, Weekly, etc），标题都采用该温控器的别名。
    self.title = MainDelegate.thermostatData.tName;
    NSLog(@"MainDelegate.thermostatData.tName = %@", MainDelegate.thermostatData.tName);

    [self.navigationController pushViewController:vc animated:YES];
    
    
}

#pragma mark -
#pragma mark URL Loading System methods

- (void) downloadModelFromServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        HUD.delegate = self;
    } else
        [HUD show:YES];
    NSString *urlStr = [NSString stringWithFormat:
                        @"%@?userId=%@&houseId=%i&tId=%@",GetRequst(URL_FOR_DASHBOARD_VIEW),
                        MainDelegate.accountData.userId,
                        MainDelegate.houseData.houseId,
                        MainDelegate.thermostatData.tId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"DashboardDownloader"  userDataDictionary:nil];
    NSLog(@"DashboardDownloader is %@, url is %@",downloader.name, urlStr);
}

- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if([name isEqualToString:@"DashboardDownloader"]) {
        [HUD hide:YES];
        NSLog(@"DashboardDownloader string from server is \n %@", string);
        
        // 判定是否服务器相应正常，如果服务器相应为-999/-998，那么_processHttpRespondForString函数会迫使
        // Navigation View Controller跳转到Houselist view。
        // 如果要中断本层函数执行，必须捕捉_processHttpRespondForString函数返回的NO值，并中断本层函数。
        if (![self _processHttpRespondForString:string])
            return;
        
        MyEDashboardData *dashboardData = [[MyEDashboardData alloc] initWithJSONString:string];
        if (dashboardData) {
            [self setDashboardData:dashboardData];
            [self configureView];
        } else {
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error"
                                                          message:@"Communication error. Please try again."
                                                         delegate:self
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
            [alert show];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"Error"
                                                  message:@"Communication error. Please try again."
                                                 delegate:self
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
    [alert show];
    
    // inform the user
    NSLog(@"Connection of %@ failed! Error - %@ %@",name,
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    [HUD hide:YES];
}


#pragma mark
#pragma mark private methods
- (void)configureView
{
    // Update the user interface for the detail item.
    MyEDashboardData *theDashboardData = self.dashboardData;
    
    if (theDashboardData) {
        NSString *imgFileName = [NSString stringWithFormat:@"%@.png",self.dashboardData.weather];
        UIImage *image = [UIImage imageNamed: imgFileName];
        self.weatherImageView.image = image;
        
        self.weatherTemperatureLabel.text = [NSString stringWithFormat:@"%.0f\u00B0F", self.dashboardData.weatherTemp];
        self.weatherTemperatureRangeLabel.text = [NSString stringWithFormat:@"%.0f~%.0f\u00B0F", self.dashboardData.lowTemp, self.dashboardData.highTemp];
        self.humidityLabel.text = [NSString stringWithFormat:@"%i%%RH",self.dashboardData.humidity];
        self.indoorTemperatureLabel.text = [NSString stringWithFormat:@"%.0f\u00B0F", self.dashboardData.temperature];
    }
}
// 判定是否服务器相应正常，如果正常返回一些字符串，如果服务器相应为-999/-998，
// 那么函数迫使Navigation View Controller跳转到Houselist view，并返回NO。
// 如果要中断外层函数执行，必须捕捉此函数返回的NO值，并中断外层函数。
- (BOOL)_processHttpRespondForString:(NSString *)respondText {
    NSInteger respondInt = [respondText intValue];// 从字符串开始寻找整数，如果碰到字母就结束，如果字符串不能转换成整数，那么此转换结果就是0
    if (respondInt == -999 || respondInt == -998) {
        
        //首先获取Houselist view controller
        NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        MyEHouseListViewController *hlvc = [allViewControllers objectAtIndex:0];
        
        //下面代码返回到Houselist viiew
        [self.navigationController popViewControllerAnimated:YES];
        
        // Houselist view controller 从服务器获取最新数据。
        [hlvc downloadModelFromServer ];
        
        //获取当前正在操作的house的name
        NSString *currentHouseName = [hlvc.accountData getHouseNameByHouseId:MainDelegate.houseData.houseId];
        NSString *message;
        
        if (respondInt == -999) {
            message = [NSString stringWithFormat:@"The thermostat of hosue %@ was disconnected.", currentHouseName];
        } else if (respondInt == -998) {
            message = [NSString stringWithFormat:@"The thermostat of hosue %@ was set to Remote Control Disabled.", currentHouseName];
        }
        
        [hlvc showAutoDisappearAlertWithTile:@"Alert" message:message delay:10.0f];
        return NO;
    }
    return YES;
    
}

@end
