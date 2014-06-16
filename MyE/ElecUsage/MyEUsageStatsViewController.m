//
//  MyEUsageStatsViewController.m
//  MyE
//
//  Created by Ye Yuan on 5/22/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import "MyEUsageStatsViewController.h"
#import "SWRevealViewController.h"
#import "MyETerminalData.h"
#import "MyEUsageStat.h"
#import "MyEHouseData.h"
#import "MyETerminalData.h"
#import "MyEDropDownMenu.h"

@interface MyEUsageStatsViewController ()
-(void)drawChart;
-(void)goHome;
-(void)refreshAction;
-(void)drawAxisLabels;
-(double)getMaxUsage;

@property (nonatomic, strong) MyEDropDownMenu *dropDown;
@end

@implementation MyEUsageStatsViewController

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
    NSString *imgName = IS_IOS6?@"detailBtn-ios6":@"detailBtn";
    [self.terminalBtn setBackgroundImage:[[UIImage imageNamed:imgName] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
    [self.terminalBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];

    self.validTerminals = [MainDelegate.houseData terminalsForUsageStats];
    self.currentTerminalIdx = 0;
    usageData= Nil;
    if(!self.fromHome){
        // Change button color
//        _sidebarButton.tintColor = [UIColor colorWithWhite:0.3f alpha:0.82f];
        // Set the side bar button action. When it's tapped, it'll show up the sidebar.
        _sidebarButton.target = self.revealViewController;
        _sidebarButton.action = @selector(revealToggle:);
        // Set the gesture
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                       initWithTitle: @"Home"
                                       style:UIBarButtonItemStylePlain
                                       target:self
                                       action:@selector(goHome)];
        self.navigationItem.backBarButtonItem = backButton;
    }
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                      target:self
                                      action:@selector(refreshAction)];
    self.parentViewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:refreshButton, nil];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self downloadModelFromServer];
    
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
#pragma mark -
#pragma mark setter method
-(void) setValidTerminals:(NSArray *)terminals
{
    _validTerminals = terminals;
    self.currentTerminalIdx = 0;
    self.terminalNames = [NSMutableArray array];
    for(MyETerminalData *t in _validTerminals){
        // 下面三句是修改下面描述的异常的， 该异常折腾了我三天。
        if ([t.tName isEqual:[NSNull null]]) {
            t.tName = @"-";
        }
        [self.terminalNames addObject:t.tName];
    }
    /* 2014-6-12
     在三天前的调试中， 碰到一个bug， myenergydomain.com服务器， xyk2或liup两个账号， 共享了同一个房间House623，进入用电统计面板， 一进入就报错误：-[NSNull length]: unrecognized selector sent to instance 0x3b6d1a60。 一进入该面板， 我的app要获取数据， 并且在启动下载的函数打断点， 发现已经启动登录下载downloadModelFromServer()，而在  didReceiveString函数打断点，但抛出异常前还没进入这个函数。有鉴于启动下载但没获得下载字符串就异常了，于是我一直以为是数据下载出问题了， 所以一直在DataLoader类里的各个函数打断点， 想找到数据下载各函数过程有没有什么问题， 一直没结果， 还用Chrome测试那个请求用电数据的url有没有问题， 发现没问题。 昨天要夏文帮忙， 还是没太多结果， 不过发现此异常和账号有关系， 就只有xyk2或liup两个账号的同一个房间House623进入用电统计有问题，其他没问题。 今天继续请夏文帮忙调试，比如吧异常账号的用电数据房子宜春服务器试图重现， 但仍然没结果。 后来夏文在后台帮我比较该房子的用电数据和其他房子用电数据区别时，还是没发现区别，只是他看那个房子的第一个智能开关设备的信息是，发现其tName是Nul， 此时我才意识到有可能是这个Null值出问题。检查发现登录后下来的数据里面有：{"aliasName":null,"thermostat":0,"deviceType":6,"tId":"06-30-00-00-00-00-00-14"}， 让他修改那个tName给一个值， 再次测试，此异常就没了。 至此确定tName的问题， 并且意识到， 不是数据加载过程DagaLoader类里的异常，而是其他地方用到此NSNull值的tName时发生的异常， 并且碰巧发生在数据加载过程执行之中， 中断了数据加载过程， 使我误以为是数据加载的问题。最后检查发现， tName为NSNull实例并调用其length方法产生异常的地方就行hi下面这一句。
         解决办法就是把上面准备self.terminalNames数组时， 检查tName， 如果是NSNull， 就用空字符串代替。
     */
    [self.terminalBtn setTitle:_terminalNames[self.currentTerminalIdx] forState:UIControlStateNormal];
}
#pragma mark -
#pragma mark private method
-(void)drawChart
{
    float xMax = 0.;
    float yMax = [self getMaxUsage];
    // Create barChart from theme
    barChart = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [barChart applyTheme:theme];
    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.chartView;
    hostingView.hostedGraph = barChart;
    
    // Border
    barChart.plotAreaFrame.borderLineStyle = nil;
    barChart.plotAreaFrame.cornerRadius    = 0.0;
    barChart.plotAreaFrame.masksToBorder   = NO;
    
    // Paddings
    barChart.paddingLeft   = 0.0;
    barChart.paddingRight  = 0.0;
    barChart.paddingTop    = 0.0;
    barChart.paddingBottom = 0.0;
    
    barChart.plotAreaFrame.paddingLeft   = 70.0;
    barChart.plotAreaFrame.paddingTop    = 20.0;
    barChart.plotAreaFrame.paddingRight  = 20.0;
    barChart.plotAreaFrame.paddingBottom = 80.0;
    
    // Graph title
    NSString *lineOne = @"Usage Statistics";
    NSString *lineTwo = @"Line 2";
    if(self.timeRangeSegment.selectedSegmentIndex == 0) {
        lineTwo = @"Past 24 Hours";
        xMax = 24;
    } else if(self.timeRangeSegment.selectedSegmentIndex == 1){
        lineTwo = @"Past 7 Days";
        xMax = 7;
    } else {
        lineTwo = @"Past 12 Months";
        xMax = 12;
    }
    
    BOOL hasAttributedStringAdditions = (&NSFontAttributeName != NULL) &&
    (&NSForegroundColorAttributeName != NULL) &&
    (&NSParagraphStyleAttributeName != NULL);
    
    if ( hasAttributedStringAdditions ) {
        NSMutableAttributedString *graphTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", lineOne, lineTwo]];
        [graphTitle addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, lineOne.length)];
        [graphTitle addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(lineOne.length + 1, lineTwo.length)];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = CPTTextAlignmentCenter;
        [graphTitle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, graphTitle.length)];
        UIFont *titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
        [graphTitle addAttribute:NSFontAttributeName value:titleFont range:NSMakeRange(0, lineOne.length)];
        titleFont = [UIFont fontWithName:@"Helvetica" size:12.0];
        [graphTitle addAttribute:NSFontAttributeName value:titleFont range:NSMakeRange(lineOne.length + 1, lineTwo.length)];
        
        barChart.attributedTitle = graphTitle;
    }
    else {
        CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
        titleStyle.color         = [CPTColor whiteColor];
        titleStyle.fontName      = @"Helvetica-Bold";
        titleStyle.fontSize      = 16.0;
        titleStyle.textAlignment = CPTTextAlignmentCenter;
        
        barChart.title          = [NSString stringWithFormat:@"%@\n%@", lineOne, lineTwo];
        barChart.titleTextStyle = titleStyle;
    }
    
    barChart.titleDisplacement        = CGPointMake(0.0, 0.0);
    barChart.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    
    // Add plot space for horizontal bar charts
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)barChart.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(yMax*1.1)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(xMax)];
    
    [self drawAxisLabels];
    
    
    // First bar plot
//    CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor colorWithCGColor:DEFAULT_UI_COLOR.CGColor] horizontalBars:NO]; // use this get a regular grandient bar
    CPTBarPlot *barPlot = [[CPTBarPlot alloc] init];
    
    // set file color, now change default grandient, use our customized grandient
//    barPlot.fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:DEFAULT_UI_COLOR.CGColor]]; // use this get a flat bar
    CPTGradient *fillGradient = [CPTGradient gradientWithBeginningColor:[CPTColor colorWithCGColor:DEFAULT_LIGHT_UI_COLOR.CGColor] endingColor:[CPTColor colorWithCGColor:DEFAULT_DARK_UI_COLOR.CGColor]];
    barPlot.fill = [CPTFill fillWithGradient:fillGradient];
    
    // change line width and color
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 1;
    lineStyle.lineColor = [CPTColor whiteColor];
    barPlot.lineStyle = lineStyle;
    
    
    
    barPlot.dataSource = self;
    barPlot.baseValue  = CPTDecimalFromDouble(0.0);
    barPlot.barOffset  = CPTDecimalFromFloat(-0.25f);
    barPlot.barCornerRadius = 0.0;
    barPlot.identifier = @"Bar Plot 1";
    [barChart addPlot:barPlot toPlotSpace:plotSpace];
}
-(double)getMaxUsage
{
    double yMax = 0.0;
    for (int i = 0; i < usageData.powerRecordList.count; i++) {
        MyEUsageRecord *r = usageData.powerRecordList[i];
        if (yMax < r.totalPower / 1000.) {
            yMax = r.totalPower / 1000.;
        }
    }
    if (yMax < 1.0) {
        yMax = 1.0;
    }else{
        yMax = ceil(yMax / 10.0) * 10.0;
    }
    return yMax;
}
-(void)drawAxisLabels
{
    double yMax = [self getMaxUsage];
    float title_xPosition = 12.0f;
    if(self.timeRangeSegment.selectedSegmentIndex == 0) {
        title_xPosition = 12.0f;
    }
    else if(self.timeRangeSegment.selectedSegmentIndex == 1) {
        title_xPosition = 3.5f;
    }
    else {
        title_xPosition = 6.0f;
    }
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)barChart.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.axisLineStyle               = nil;
    x.majorTickLineStyle          = nil;
    x.minorTickLineStyle          = nil;
    x.majorIntervalLength         = CPTDecimalFromDouble(1.0);
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    x.title                       = @"Time";
    x.titleLocation               = CPTDecimalFromFloat(title_xPosition);
    x.titleOffset                 = 55.0;
    
    // Define some custom labels for the data elements
    x.labelRotation  = M_PI_4;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    NSArray *customTickLocations = Nil;
    NSMutableArray *xAxisLabels         = [NSMutableArray array];
    
    if(self.timeRangeSegment.selectedSegmentIndex == 0) {
        customTickLocations = @[@3, @6, @9, @12, @15, @18, @21, @24];
        for (int i = 0; i < usageData.powerRecordList.count; i++) {
            if (i > 0 && (i + 1) % 3 == 0) {
                MyEUsageRecord *r = usageData.powerRecordList[i];
                [xAxisLabels addObject:r.date];
            }
            
        }
    }
    else if(self.timeRangeSegment.selectedSegmentIndex == 1) {
        customTickLocations = @[@1, @2, @3, @4, @5, @6, @7];
        for (int i = 0; i < usageData.powerRecordList.count; i++) {
            MyEUsageRecord *r = usageData.powerRecordList[i];
            [xAxisLabels addObject:r.date];
        }
    }
    else {
        customTickLocations = @[@2, @4, @6, @8, @10, @12];
        for (int i = 0; i < usageData.powerRecordList.count; i++) {
            if ( i > 0 && (i + 1) % 2 == 0) {
                MyEUsageRecord *r = usageData.powerRecordList[i];
                [xAxisLabels addObject:r.date];
            }
        }
    }
    
    
    
    NSUInteger labelLocation     = 0;
    NSMutableSet *customLabels   = [NSMutableSet setWithCapacity:[xAxisLabels count]];
    for ( NSNumber *tickLocation in customTickLocations ) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:xAxisLabels[labelLocation++] textStyle:x.labelTextStyle];
        newLabel.tickLocation = [tickLocation decimalValue];
        newLabel.offset       = x.labelOffset;// + x.majorTickLength;
        newLabel.rotation     = M_PI_4;
        [customLabels addObject:newLabel];
    }
    
    x.axisLabels = customLabels;
    
    CPTXYAxis *y = axisSet.yAxis;
    y.axisLineStyle               = nil;
    y.majorTickLineStyle          = nil;
    y.minorTickLineStyle          = nil;
    y.majorIntervalLength         = CPTDecimalFromDouble(yMax / 5.0);
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    y.title                       = @"Usage (kWh)";
    y.titleOffset                 = 50.0;
    y.titleLocation               = CPTDecimalFromFloat(yMax/2);
    
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    
    if (usageData) {
        return usageData.powerRecordList.count;
    }else
        return 0;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;
    MyEUsageRecord *ur = usageData.powerRecordList[index];
    
    if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                num = @(index + 1);
                break;
            case CPTBarPlotFieldBarTip:
                num = @( ur.totalPower/1000. );
                break;
        }
    }
    
    return num;
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
    MyETerminalData *t = self.validTerminals[self.currentTerminalIdx];
    NSInteger timeRangeType = self.timeRangeSegment.selectedSegmentIndex + 1;
    
    NSString *urlStr = [NSString stringWithFormat:
                        @"%@?&houseId=%i&tId=%@&action=%d",GetRequst(URL_FOR_USAGE_STATS_VIEW),
                        MainDelegate.houseData.houseId,
                        t.tId,
                        timeRangeType];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"UsageStatsDownloader"  userDataDictionary:nil];
    NSLog(@"UsageStatsDownloader is %@, url is %@",downloader.name, urlStr);
}

- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if([name isEqualToString:@"UsageStatsDownloader"]) {
        [HUD hide:YES];
        NSLog(@"UsageStatsDownloader string from server is \n %@", string);
        if([string isEqualToString:@"fail"]){
            [MyEUtil showErrorOn:self.view withMessage:@"Data is not available currently."];
        }else{
            usageData = [[MyEUsageStat alloc] initWithString:string];
            NSLog(@"当前功率=%f (w), 本期用电量=%f (kWh)", usageData.currentPower * 110.0, usageData.totalPower/1000.0);
            for (MyEUsageRecord *r in usageData.powerRecordList) {
                NSLog(@"dateTime=%@, totalPower=%f W", r.date, r.totalPower/1000.0);
            }
            self.currentPowerLabel.text = [NSString stringWithFormat:@"Current Power: %.1f (W)",usageData.currentPower * 110];
            [self drawChart];
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


- (IBAction)changeTerminal:(id)sender {
    if ([sender isSelected]) {
        [self closeMenu];
        [sender setSelected:NO];
    } else{
        [sender setSelected:YES];
        if(self.dropDown == nil) {
            //            NSArray *arr = [NSArray arrayWithObjects:@"Add tag's comment", @"Tag info", @"Help", @"Languages", @"Home22", @"home33", @"Home32", nil];
            //            NSArray *arrImage = [NSArray arrayWithObjects:[UIImage imageNamed:@"bookmark.png"],
            //                                 [UIImage imageNamed:@"map.png"],
            //                                 [UIImage imageNamed:@"news.png"],
            //                                 [UIImage imageNamed:@"photo.png"], nil];
            self.dropDown = [[MyEDropDownMenu alloc] showDropDown:sender
                                                        titleList:_terminalNames
                                                        imageList:nil
                                                    directionDown:YES];
            __weak MyEUsageStatsViewController *bSelf = self;
            self.dropDown.function = ^(NSInteger index){
                NSLog(@"you chose : %d", index);
                bSelf.currentTerminalIdx = index;
                [bSelf.terminalBtn setTitle:bSelf.terminalNames[bSelf.currentTerminalIdx] forState:UIControlStateNormal];
                [bSelf downloadModelFromServer];
            };
            self.dropDown.releseMenu = ^{
                [bSelf closeMenu];
                [bSelf.terminalBtn setSelected:NO];
            };
        }
    }
}

- (IBAction)changeTimaeRange:(id)sender {
    [self downloadModelFromServer];
}

#pragma mark 
#pragma mark private methods
-(void)goHome
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}
- (void)refreshAction
{
    [self downloadModelFromServer];
}
- (void)closeMenu
{
    [self.dropDown hideDropDown:self.view];
    self.dropDown = nil;
}
@end
