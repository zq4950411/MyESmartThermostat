//
//  MyEAcAutoControlViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/17/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAutoControlViewController.h"
#import "MyEAccountData.h"
#import "MyEDevice.h"
#import "MyEAutoControlProcessList.h"
#import "MyEAutoControlProcess.h"
#import "MyEUtil.h"
#import "MyEAutoProcessListViewController.h"
#import "MyEAutoProcessViewController.h"

#define AUTO_CONTROL_PROCESS_DOWNLOADER_NMAE @"AutoControlProcessDownloader"
#define ENABLE_AUTO_PROCESS_UPLOADER_NMAE @"EnableAutoProcessUploader"

@interface MyEAutoControlViewController ()

@end

@implementation MyEAutoControlViewController
@synthesize processList = _processList,device;
#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setFrame:CGRectMake(0, 0, 50, 30)];
    [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    if (!IS_IOS6) {
        [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
    }
    [btn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    if (IS_IOS6) {
        self.enableProcessSegmentedControl.layer.borderColor = MainColor.CGColor;
        self.enableProcessSegmentedControl.layer.borderWidth = 1.0f;
        self.enableProcessSegmentedControl.layer.cornerRadius = 4.0f;
        self.enableProcessSegmentedControl.layer.masksToBounds = YES;
    }
    [self downloadProcessListFromServer];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self resetAddNewButtonWithAvailableDays];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - URL Loading System methods

- (void) downloadProcessListFromServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    if (self.device.typeId.intValue == 1) {
        NSString *urlStr = [NSString stringWithFormat:@"%@?houseId=%i&id=%@",GetRequst(URL_FOR_AC_DOWNLOAD_AC_AUTO_CONTROL_VIEW),MainDelegate.houseData.houseId,self.device.deviceId];
        MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:AUTO_CONTROL_PROCESS_DOWNLOADER_NMAE  userDataDictionary:Nil];
        NSLog(@"%@",downloader.name);
    }
}

#pragma mark - URL delegate Methods
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:AUTO_CONTROL_PROCESS_DOWNLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -1){
            [SVProgressHUD showErrorWithStatus:@"fail"];
        }else if([MyEUtil getResultFromAjaxString:string] == 1){
            MyEAutoControlProcessList *processList = [[MyEAutoControlProcessList alloc] initWithJSONString:string];
            if(processList){
                self.processList = processList;
                //#warning 这里也给出了一个寻找VC的方法
                MyEAutoProcessListViewController *vc = [self.childViewControllers objectAtIndex:0];
                vc.device = self.device;
                vc.processList = processList;//这里的setter重新加载table数据,这一步骤是重要的，用来现实更新后的数据。
                [self resetAddNewButtonWithAvailableDays];
                [self refreshSegmentStatus];
            }
        }
    }
    if([name isEqualToString:ENABLE_AUTO_PROCESS_UPLOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == 1) {
            self.processList.enable = 1-self.enableProcessSegmentedControl.selectedSegmentIndex;
//            if(self.processList.enable)
//                [MyEUtil showSuccessOn:self.view withMessage:@"进程启用成功"];
//            else
//                [MyEUtil showSuccessOn:self.view withMessage:@"进程停用成功"];
//            
        }else{
            [SVProgressHUD showErrorWithStatus:@"fail"];
            [self refreshSegmentStatus];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
#pragma mark - navigation methods
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"AcProcessListToAddProcess"]) {
        MyEAutoProcessViewController *pvc = [segue destinationViewController];
        //        self.processList
        MyEAutoControlProcess *process = [[MyEAutoControlProcess alloc] init];
        pvc.process = process;
        NSInteger day = [self.processList getFirstAvailableDay];
        if (day > 0) {
            [pvc.process.days addObject:[NSNumber numberWithInteger:day]];
        }
        pvc.unavailableDays = [self.processList getUnavailableDaysForProcessWithId:process.pId];
        pvc.delegate = self;
        pvc.isAddNew = YES;
        pvc.device = self.device;
    }
}
#pragma mark - private methods
-(void)refreshSegmentStatus{
    if ([self.processList.mainArray count] == 0) { //当没有进程的时候要禁止用户点击【启用进程】
        [self.enableProcessSegmentedControl setEnabled:NO forSegmentAtIndex:0];
        [self.enableProcessSegmentedControl setSelectedSegmentIndex:1];
    }else{
        [self.enableProcessSegmentedControl setEnabled:YES forSegmentAtIndex:0];
        [self.enableProcessSegmentedControl setSelectedSegmentIndex:1-self.processList.enable];
    }
}
- (void)resetAddNewButtonWithAvailableDays{  //如果进程都添加满了，那么就不允许再添加进程
    NSArray *unavailableDays = [self.processList getUnavailableDaysForProcessWithId:0];// 获取已使用的所有天
    if ([unavailableDays count] == 7) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }else
        self.navigationItem.rightBarButtonItem.enabled = YES;
    
    
    //    if ([unavailableDays count] < 7) {
    //        NSLog(@"9999988888888");
    //        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc]
    //                                          initWithTitle:@"添加进程"
    //                                          style:UIBarButtonItemStylePlain
    //                                          target:self
    //                                          action:@selector(addNewProgress)];
    //        // 注意下面必须用self.parentViewController.navigationItem， 而不是self.navigationItem，似乎因为self是父TabbarVC的第一个子VC，还没经过push等导航，所以self没有导航条
    //        self.parentViewController.navigationItem.rightBarButtonItem = anotherButton;
    //    } else{
    //        //self.parentViewController.navigationItem.rightBarButtonItem = Nil;
    //        self.navigationItem.rightBarButtonItem = nil;
    //    }
}
#pragma mark - method for MyEAcProcessViewControllerDelegate
- (void)didFinishEditProcess:(MyEAutoControlProcess *)process isAddNew:(BOOL)flag
{
    if (!flag) {
        [[NSException exceptionWithName:@"代理类型错误" reason:@"此处应该是添加新的进程，而不应该是编辑进程" userInfo:Nil] raise];
    }
    NSLog(@"新增进程%li",(long)process.pId);
    [self.processList.mainArray addObject:process];
    if ([self.processList.mainArray count] > 0 ) {
        [self.enableProcessSegmentedControl setEnabled:YES forSegmentAtIndex:0];
        [self.enableProcessSegmentedControl setSelectedSegmentIndex:0];  //新增指令后【启用进程】必须是选中状态
    }
    MyEAutoProcessListViewController *plvc = [self.childViewControllers objectAtIndex:0];
    [plvc.processList renameProcessInList ];//进程重新排名和重新命名
    [plvc.tableView reloadData];
}

#pragma mark - IBAction methods
- (IBAction)enableProcessAction:(id)sender {
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    if (self.device.typeId.intValue == 1) { //空调设备
        NSString *urlStr = [NSString stringWithFormat:@"%@?houseId=%i&deviceId=%@&enable=%ld",
                            GetRequst(URL_FOR_AC_ENABLE_AC_AUTO_PROCESS_SAVE),
                            MainDelegate.houseData.houseId,
                            self.device.deviceId,
                            1-(long)self.enableProcessSegmentedControl.selectedSegmentIndex];
        MyEDataLoader *downloader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:ENABLE_AUTO_PROCESS_UPLOADER_NMAE  userDataDictionary:Nil];
        NSLog(@"%@",downloader.name);
    }
}
- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}
//-(BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
//#warning 我擦这个问题终于解决了,这也算是解决了一个世纪难题啊
//    //首先要知道当前的visibleViewController
////    NSLog(@"%@",self.navigationController.visibleViewController);
//    //然后要明白根据什么来区分跳转过来的页面判断
//    UIViewController *vc = self.navigationController.visibleViewController;
//    NSLog(@"%@  %@",vc,self.navigationController.topViewController);
//        if ([vc isKindOfClass:[MyEAutoControlViewController class]]) {
//            NSLog(@"MyEAutoControlViewController");
//    //这里必须要添加一个BOOL变量来区分当前页面的行为和跳转到当前页面的行为
//            if (self.isSelf) {
//                [self dismissViewControllerAnimated:YES completion:nil];
//                return NO;
//            }else{
//                self.isSelf = YES; //此时navbar还停留在上一页面
//                return YES;
//            }
//        }
//        if ([vc isKindOfClass:[MyEAutoPeriodViewController class]]) {
//            NSLog(@"MyEAutoPeriodViewController");
//            [self.navigationController popViewControllerAnimated:YES];
//            return YES;
//        }
//        if ([vc isKindOfClass:[MyEAutoProcessViewController class]]) {
//            NSLog(@"MyEAutoProcessViewController");
//            MyEAutoProcessViewController *autoVC = (MyEAutoProcessViewController *)vc;
//            if (autoVC.isSelf) {
//                if (!autoVC.saveProcessBtn.hidden) {
//                    [MyEUniversal doThisWhenNeedTellUserToSaveWhenExitWithLeftBtnAction:^{
//                        self.isSelf = NO;  //这里必须要注意赋值问题
//                        [self.navigationController popViewControllerAnimated:YES];
//                    } andRightBtnAction:^{
//                        [autoVC saveProcessAction:nil]; //这个方法完成后一定要修改isSelf的值，这里需要注意
//                    }];
//                    return NO;
//                }else{
//                    [self.navigationController popViewControllerAnimated:YES];
//                    return YES;
//                }
//            }else{
//                autoVC.isSelf = YES;
//                return YES;
//            }
//        }
//    return NO;
//}
@end
