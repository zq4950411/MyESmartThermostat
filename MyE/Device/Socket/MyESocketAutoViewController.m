//
//  MyESocketAutoViewController.m
//  MyE
//
//  Created by 翟强 on 14-4-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyESocketAutoViewController.h"

@interface MyESocketAutoViewController ()
{
    MBProgressHUD *HUD;
}
@end

@implementation MyESocketAutoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - life Circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?tId=%@",GetRequst(URL_FOR_FIND_SOCKET_AUTO),self.device.tid] andName:@"downloadInfo"];
}
#pragma mark - private methods
-(void)uploadOrDownloadInfoFromServerWithURL:(NSString *)url andName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    }
    [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:url postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"loader is %@",loader.name);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - URL DELEGATE methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    if ([name isEqualToString:@"downloadInfo"]) {
        if (string.intValue == -999) {
            [SVProgressHUD showWithStatus:@"no connection"];
        }else if(![string isEqualToString:@"fail"]){
            MyESocketSchedules *schedules = [[MyESocketSchedules alloc] initWithJSONString:string];
            self.schedules = schedules;
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
}
@end
