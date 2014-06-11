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
#import "MyEUsageStatsViewController.h"
#import "MyEAccountData.h"
#import "MyETerminalData.h"
#import "MyEHomePanelData.h"
#import "MyEDevicesViewController.h"

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
    
    self.title = MainDelegate.houseData.houseName;

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
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    MyEUsageStatsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ElecUsageStat"];
    vc.fromHome = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goAlerts:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    MyEUsageStatsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Alerts"];
    vc.fromHome = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goToDeviceList:(id)sender {
    MyEDevicesViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"devices"];
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
                        @"%@?houseId=%i",GetRequst(URL_FOR_HOMEPANEL_VIEW),
                        MainDelegate.houseData.houseId];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"DashboardDownloader"  userDataDictionary:nil];
    NSLog(@"DashboardDownloader is %@, url is %@",downloader.name, urlStr);
}

- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if([name isEqualToString:@"DashboardDownloader"]) {
        [HUD hide:YES];
        NSLog(@"DashboardDownloader string from server is \n %@", string);
        MyEHomePanelData *homeData = [[MyEHomePanelData alloc] initWithJSONString:string];
        if (homeData) {
            [self setHomeData:homeData];
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
    if (self.homeData) {
        NSString *imgFileName = [NSString stringWithFormat:@"%@.png",self.homeData.weather];
        UIImage *image = [UIImage imageNamed: imgFileName];
        self.weatherImageView.image = image;
        
        self.weatherTemperatureLabel.text = [NSString stringWithFormat:@"%.0f\u00B0F", self.homeData.weatherTemp];
        self.weatherTemperatureRangeLabel.text = [NSString stringWithFormat:@"%.0f~%.0f\u00B0F", self.homeData.lowTemp, self.homeData.highTemp];
        self.humidityLabel.text = [NSString stringWithFormat:@"%.0f%%RH",self.homeData.indoorHumidity];
        self.indoorTemperatureLabel.text = [NSString stringWithFormat:@"%.0f\u00B0F", self.homeData.temperature];
        if (self.homeData.numDetected > 0) {
            self.alertsTileLabel.text = [NSString stringWithFormat:@"%i New Alerts", (int)self.homeData.numDetected];
            self.alertsTileImageView.image = [UIImage imageNamed:@"NewAlertTile"];
        } else{
            self.alertsTileLabel.text = @"No New Alerts";
            self.alertsTileImageView.image = [UIImage imageNamed:@"AlertTile"];
        }
    }
}


@end
