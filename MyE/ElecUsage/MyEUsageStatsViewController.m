//
//  MyEUsageStatsViewController.m
//  MyE
//
//  Created by Ye Yuan on 5/22/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import "MyEUsageStatsViewController.h"
#import "SWRevealViewController.h"
#import "MyEThermostatData.h"

@interface MyEUsageStatsViewController ()
-(void)configView;
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
    // Do any additional setup after loading the view.
    
    if(!self.fromHome){
        // Change button color
        _sidebarButton.tintColor = [UIColor colorWithWhite:0.3f alpha:0.82f];
        
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
    
    [self configView];
}
-(void)goHome
{
    [self dismissViewControllerAnimated:YES completion:Nil];
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
#pragma mark private method
-(void)configView
{
    // Create barChart from theme
    barChart = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [barChart applyTheme:theme];
    CPTGraphHostingView *hostingView = (CPTGraphHostingView *)self.view;
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
    NSString *lineOne = @"Graph Title";
    NSString *lineTwo = @"Line 2";
    
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
    
    barChart.titleDisplacement        = CGPointMake(0.0, -20.0);
    barChart.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    
    // Add plot space for horizontal bar charts
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)barChart.defaultPlotSpace;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(300.0f)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(16.0f)];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)barChart.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.axisLineStyle               = nil;
    x.majorTickLineStyle          = nil;
    x.minorTickLineStyle          = nil;
    x.majorIntervalLength         = CPTDecimalFromDouble(5.0);
    x.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    x.title                       = @"X Axis";
    x.titleLocation               = CPTDecimalFromFloat(7.5f);
    x.titleOffset                 = 55.0;
    
    // Define some custom labels for the data elements
    x.labelRotation  = M_PI_4;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    NSArray *customTickLocations = @[@1, @3, @6, @9, @12, @15];
    NSArray *xAxisLabels         = @[@"Label A", @"Label B", @"Label C", @"Label D", @"Label e", @"Label F"];
    NSUInteger labelLocation     = 0;
    NSMutableSet *customLabels   = [NSMutableSet setWithCapacity:[xAxisLabels count]];
    for ( NSNumber *tickLocation in customTickLocations ) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:xAxisLabels[labelLocation++] textStyle:x.labelTextStyle];
        newLabel.tickLocation = [tickLocation decimalValue];
        newLabel.offset       = x.labelOffset + x.majorTickLength;
        newLabel.rotation     = M_PI_4;
        [customLabels addObject:newLabel];
    }
    
    x.axisLabels = customLabels;
    
    CPTXYAxis *y = axisSet.yAxis;
    y.axisLineStyle               = nil;
    y.majorTickLineStyle          = nil;
    y.minorTickLineStyle          = nil;
    y.majorIntervalLength         = CPTDecimalFromDouble(50.0);
    y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0.0);
    y.title                       = @"Y Axis";
    y.titleOffset                 = 45.0;
    y.titleLocation               = CPTDecimalFromFloat(150.0f);
    
    // First bar plot
    CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor] horizontalBars:NO];
    barPlot.baseValue  = CPTDecimalFromDouble(0.0);
    barPlot.dataSource = self;
    barPlot.barOffset  = CPTDecimalFromFloat(-0.25f);
    barPlot.identifier = @"Bar Plot 1";
    [barChart addPlot:barPlot toPlotSpace:plotSpace];
    
    // Second bar plot
    barPlot                 = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:NO];
    barPlot.dataSource      = self;
    barPlot.baseValue       = CPTDecimalFromDouble(0.0);
    barPlot.barOffset       = CPTDecimalFromFloat(0.25f);
    barPlot.barCornerRadius = 2.0;
    barPlot.identifier      = @"Bar Plot 2";
    [barChart addPlot:barPlot toPlotSpace:plotSpace];

}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return 16;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num = nil;
    
    if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                num = @(index);
                break;
                
            case CPTBarPlotFieldBarTip:
                num = @( (index + 1) * (index + 1) );
                if ( [plot.identifier isEqual:@"Bar Plot 2"] ) {
                    num = @(num.integerValue - 10);
                }
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
    NSString *urlStr = [NSString stringWithFormat:
                        @"%@?&houseId=%i&tId=%@&action=%d",GetRequst(URL_FOR_USAGE_STATS_VIEW),
                        MainDelegate.houseData.houseId,
                        MainDelegate.thermostatData.tId,
                        1];
    MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"UsageStatsDownloader"  userDataDictionary:nil];
    NSLog(@"UsageStatsDownloader is %@, url is %@",downloader.name, urlStr);
}

- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    if([name isEqualToString:@"UsageStatsDownloader"]) {
        [HUD hide:YES];
        NSLog(@"UsageStatsDownloader string from server is \n %@", string);
        
        MyEUsageStat *elct = [[MyEUsageStat alloc] initWithString:string];
#warning Todo 转换数据
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


@end
