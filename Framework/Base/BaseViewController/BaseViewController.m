//
//  BaseViewController.m
//  FinalFantasy
//
//  Created by space bj on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseViewController.h"
#import "Utils.h"

#import "LoadMoreTableFooterView.h"
#import "EGORefreshTableHeaderView.h"

#define Left_Button_Item_Normal_Image_Name @"back_button.png"
#define Left_Button_Item_HighLight_Image_Name @"anniu_zuo_xuanzhong.png"

#define Right_Button_Item_Normal_Image_Name @"rightButton.png"
#define Right_Button_Item_HighLight_Image_Name @"anniu_you_xuanzhong.png"




//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0
//
//@implementation UINavigationBar(BgImage)
//
//-(void) drawRect:(CGRect)rect
//{
//	UIImage *image = [UIImage imageNamed:@"navbg.png"];
//    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
//	
//	//self.tintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1f];
//}
//@end
//
//#endif

@implementation BaseViewController

@synthesize isLoadingData;
@synthesize titleText;
@synthesize isEnterBackground;
@synthesize queue;
@synthesize presentType;
@synthesize parentVC;
@synthesize isShowLoading;
@synthesize isNeedRefresh;



-(void) executeTaskInBackground
{    
    if (self.queue == nil)
    {
        self.queue = [[[NSOperationQueue alloc] init] autorelease];
        self.queue.maxConcurrentOperationCount = 1;
    }
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(beginTask)
                                                                              object:nil];
    [queue addOperation:operation];
    [operation release];
}

-(void) beginTask
{
    id object = nil;
    if ([self respondsToSelector:@selector(executeTask)]) 
    {
        object = [self performSelector:@selector(executeTask)];
    }
    [self performSelectorOnMainThread:@selector(endTask:) withObject:object waitUntilDone:NO];
}

//任务执行
-(void) endTask:(id) object
{
    if ([self respondsToSelector:@selector(executeEndTask:)]) 
    {
        [self performSelector:@selector(executeEndTask:) withObject:object];
    }
}


//不在前端显示 子类重写
-(void) enterBackgroundAction
{
    
}
//在前端显示 子类重写
-(void) enterForegroundAction
{
    
}


-(void) showLoadViewWithMsg:(NSString *) msg
{
    [SVProgressHUD showWithStatus:@"loading" maskType:SVProgressHUDMaskTypeGradient];
}

-(void) hideLoading
{
    [SVProgressHUD dismiss];
    //[self performSelector:@selector(doHide) withObject:nil afterDelay:0.0f];
}

-(void) showInfoViewWithMsg:(NSString *) msg
{

}

#pragma -
#pragma 返回

-(void) leftButtonItemClick
{    
    if ([self respondsToSelector:@selector(leftButtonItemClickBackCall)]) 
    {
        [self leftButtonItemClickBackCall];
    }
    if (self.queue) 
    {
        [self.queue cancelAllOperations];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) leftButtonItemClickBackCall
{
    
}

-(void) initWithCustomView:(UIView *) customView type:(int) type
{
    UIBarButtonItem *buttonItem = [[[UIBarButtonItem alloc] initWithCustomView:customView] autorelease];
    
    if (type == 0) 
    {
        self.navigationItem.leftBarButtonItem = buttonItem;    
    }
    else
    {
        self.navigationItem.rightBarButtonItem = buttonItem;
    }
}

-(void) initButtonItemWithTitle:(NSString *) text atTarget:(id) target andSelector:(SEL) selctor type:(int) type
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

    button.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [button setFrame:CGRectMake(0, 5, 65, 30)];

    [button setTitle:text forState:UIControlStateNormal];    
    
    if (type == 0) 
    {
        [button setBackgroundImage:[UIImage imageNamed:Left_Button_Item_Normal_Image_Name] forState:UIControlStateNormal];
        //[button setBackgroundImage:[UIImage imageNamed:Left_Button_Item_HighLight_Image_Name] forState:UIControlStateHighlighted];
    }
    else
    {
        [button setBackgroundImage:[UIImage imageNamed:Right_Button_Item_Normal_Image_Name] forState:UIControlStateNormal];
        //[button setBackgroundImage:[UIImage imageNamed:Right_Button_Item_HighLight_Image_Name] forState:UIControlStateHighlighted];
    }
    
    [button addTarget:target action:selctor forControlEvents:UIControlEventTouchUpInside];
    
    [self initWithCustomView:button type:type];
}

-(void) initLeftButtonItemWithTitle:(NSString *) text atTarget:(id) target andSelector:(SEL) selctor
{
    if (selctor == nil) 
    {
        [self initButtonItemWithTitle:text atTarget:target andSelector:@selector(leftButtonItemClick) type:0];
    }
    else
    {
        [self initButtonItemWithTitle:text atTarget:target andSelector:selctor type:0];
    }
}

-(void) initRightButtonItemWithTitle:(NSString *) text atTarget:(id) target andSelector:(SEL) selctor
{
    [self initButtonItemWithTitle:text atTarget:target andSelector:selctor type:1];    
}

#pragma -
#pragma 进入用户主页

-(void) goToUserProfile:(UIButton *) sender
{
    
}

#pragma -
#pragma 添加等待试图

-(void) addLoadingView:(UIView *) parentView
{
    isLoadingData = YES;
    
    UIView *tempView = [[UIView alloc] initWithFrame:parentView.bounds];
    
    tempView.backgroundColor = [UIColor whiteColor];
    tempView.tag = -100;
    [parentView addSubview:tempView];
    [tempView release];
    
    UIActivityIndicatorView *ac = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    ac.center = CGPointMake(parentView.bounds.size.width / 2 - ac.bounds.size.width / 2, 25);
    ac.tag = -101;
    [ac startAnimating];
    [parentView addSubview:ac];
    [ac release];
}

-(void) removeLoadingView:(UIView *) parentView
{
    isLoadingData = NO;
    for (UIView *temp in parentView.subviews) 
    {
        if (temp.tag == -100 || temp.tag == -101) 
        {
            [temp removeFromSuperview];
        }
    }
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}









-(void) viewDidLoad
{
    [super viewDidLoad];
    
//    if (isShowLoading)
//    {
//        if (loadingView == nil)
//        {
//            [self initLoadingView];
//        }
//    }
    //self.navigationController.navigationBar.tintColor = RGB(5, 39, 175);
}


-(void) setTitleLabelText:(NSString *) text
{
    self.titleText = text;
    UILabel *label = (UILabel *)[self.navigationController.navigationBar viewWithTag:100];
    label.text = text;
}



- (void) viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) dealloc
{
    CLog(@"内存释放 Class = %@",[[self class] description]);
    [titleText release];
    self.queue = nil;
    
    [super dealloc];
}

@end
