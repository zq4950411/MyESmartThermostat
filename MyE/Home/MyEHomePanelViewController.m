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
#import "KxMenu.h"

@interface MyEHomePanelViewController ()
- (void)configureView;

- (void)chooseThermostat:(KxMenuItem *) sender;
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
//    _sidebarButton.tintColor = [UIColor colorWithWhite:0.3f alpha:0.82f];
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [self.indoorInforTile setFlatStyleType:ACPButtonOK];
    [self.indoorInforTile setFlatStyle:[UIColor lightGrayColor] andHighlightedColor:[UIColor grayColor]];
    [self.indoorInforTile setBorderStyle:[UIColor clearColor] andInnerColor:[UIColor clearColor] ];
    [self.elecUsageTile setFlatStyleType:ACPButtonOK];
    [self.elecUsageTile setFlatStyle:[UIColor lightGrayColor] andHighlightedColor:[UIColor grayColor]];
    [self.elecUsageTile setBorderStyle:[UIColor clearColor] andInnerColor:[UIColor clearColor] ];
    [self.thermostatTile setFlatStyleType:ACPButtonOK];
    [self.thermostatTile setFlatStyle:[UIColor lightGrayColor] andHighlightedColor:[UIColor grayColor]];
    [self.thermostatTile setBorderStyle:[UIColor clearColor] andInnerColor:[UIColor clearColor] ];
    [self.faultInfoTile setFlatStyleType:ACPButtonOK];
    [self.faultInfoTile setFlatStyle:[UIColor lightGrayColor] andHighlightedColor:[UIColor grayColor]];
    [self.faultInfoTile setBorderStyle:[UIColor clearColor] andInnerColor:[UIColor clearColor] ];
    
    self.title = MainDelegate.houseData.houseName;
    self.navigationItem.rightBarButtonItems = nil;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                      target:self
                                      action:@selector(refreshAction)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:refreshButton, nil];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 处理tId
    //在NSDefaults里面寻找上次记录的tId， 如果找到，并且在thermostat list里面找到， 就是用它。
    // 否则从thermostat list里面取得第一个有链接的thermostat
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *tId = [prefs objectForKey:KEY_FOR_THERMOSTATID_HOME_INDOOR_TH];
    NSInteger index = [MainDelegate.houseData indexInConnectedThermostatListFortId:tId];
    if(index > -1){
        self.thermostatId_for_indoor_th = tId;
        MainDelegate.terminalData = [MainDelegate.houseData getTerminalDataBytId:tId];
    }
    else{
        MainDelegate.terminalData = [MainDelegate.houseData firstConnectedThermostat];
        self.thermostatId_for_indoor_th = MainDelegate.terminalData.tId;
        [prefs setObject:self.thermostatId_for_indoor_th forKey:KEY_FOR_THERMOSTATID_HOME_INDOOR_TH];
        [prefs synchronize];
    }
#warning 这里修改了
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
- (void)chooseThermostat:(KxMenuItem *) sender
{
    NSArray *ctl = [MainDelegate.houseData connectedThermostatList];
    MyETerminalData *the = [ctl objectAtIndex:sender.tag];
    if (![the.tId isEqualToString:self.thermostatId_for_indoor_th])
    {
        MainDelegate.terminalData = the;
        self.thermostatId_for_indoor_th = MainDelegate.terminalData.tId;
         NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:self.thermostatId_for_indoor_th forKey:KEY_FOR_THERMOSTATID_HOME_INDOOR_TH];
        [prefs synchronize];
        [self refreshAction];
    }
}

- (IBAction)selectThermostatForIndoorInformation:(id)sender {
    NSArray *ctl = [MainDelegate.houseData connectedThermostatList];
    
    NSMutableArray *items = [NSMutableArray array];
    for (int i = 0; i < ctl.count; i++)
    {
        MyETerminalData *t = ctl[i];
        NSString *tname = t.tName;
        if (tname.length < 15 ) {
            tname = [NSString stringWithFormat:@"        %@        ", t.tName];
        }
        KxMenuItem *item = [KxMenuItem menuItem:tname
                                          image:nil
                                         target:self
                                         action:@selector(chooseThermostat:)];
        
        if ([t.tId isEqualToString:self.thermostatId_for_indoor_th])
        {
            item.foreColor = [UIColor redColor];
        }
        else
        {
            item.foreColor = [UIColor whiteColor];
        }
        
        item.tag = i;
        [items addObject:item];
    }
    UIView *tile = (UIView *)sender;
    if (items.count > 0)
    {
        [KxMenu showMenuInView:self.view
                      fromRect:tile.frame
                     menuItems:items];
    }
}

- (IBAction)goElecUsage:(id)sender {
    if([MainDelegate.houseData terminalsForUsageStats].count == 0)
    {
        [SVProgressHUD showSuccessWithStatus:@"No devcie with electricity usage stats."];
        return;
    }
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

- (void)refreshAction
{
    [self downloadModelFromServer];
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
                        @"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_HOMEPANEL_VIEW),
                        MainDelegate.houseData.houseId, self.thermostatId_for_indoor_th];
    [MyEDataLoader startLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"HomeDataDownloader"  userDataDictionary:nil];
}

- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if([name isEqualToString:@"HomeDataDownloader"]) {
        [HUD hide:YES];
        NSLog(@"HomeDataDownloader string from server is \n %@", string);
        MyEHomePanelData *homeData = [[MyEHomePanelData alloc] initWithJSONString:string];
        [self setHomeData:homeData];
        [self configureView];
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [SVProgressHUD showErrorWithStatus:@"Communication error. Please try again."];
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
        if(MainDelegate.terminalData)
            self.indoorTemperatureLabel.text = [NSString stringWithFormat:@"%.0f\u00B0F", self.homeData.temperature];
        if (self.homeData.numDetected > 0) {
            self.alertsTileLabel.text = [NSString stringWithFormat:@"%i New Alerts", (int)self.homeData.numDetected];
            self.alertsTileImageView.image = [UIImage imageNamed:@"Alerts-01"];
        } else{
            self.alertsTileLabel.text = @"No New Alerts";
            self.alertsTileImageView.image = [UIImage imageNamed:@"AlertTile"];
        }
    }
}


@end
