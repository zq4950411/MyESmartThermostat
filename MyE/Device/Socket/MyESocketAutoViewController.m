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

#pragma mark - life Circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_FIND_SOCKET_AUTO),MainDelegate.houseData.houseId,self.device.tid] andName:@"downloadInfo"];
}
#pragma mark - IBAction methods
- (IBAction)controlChange:(UISegmentedControl *)sender {
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&autoMode=%i",GetRequst(URL_FOR_SAVE_SOCKET_AUTO),MainDelegate.houseData.houseId,self.device.tid,1-sender.selectedSegmentIndex] andName:@"control"];
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
}

#pragma mark - URL DELEGATE methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    if ([name isEqualToString:@"downloadInfo"]) {
        if (string.intValue == -999) {
            [SVProgressHUD showWithStatus:@"No Connection"];
        }else if(![string isEqualToString:@"fail"]){
            MyESocketSchedules *schedules = [[MyESocketSchedules alloc] initWithJSONString:string];
            self.schedules = schedules;
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
    if ([name isEqualToString:@"control"]) {
        if (string.intValue == -999) {
            [SVProgressHUD showWithStatus:@"No Connection"];
        }else if (string.intValue == -501){
            [SVProgressHUD showWithStatus:@"No Schedule"];
        }else if (![string isEqualToString:@"fail"]){
            
        }else{
            [SVProgressHUD showErrorWithStatus:@"Error!"];
            self.controlSeg.selectedSegmentIndex = 1-self.controlSeg.selectedSegmentIndex;
        }
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    NSLog(@"%@",error);
}
@end
