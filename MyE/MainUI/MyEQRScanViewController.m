//
//  MyEQRScanViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-12-3.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEQRScanViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface MyEQRScanViewController ()
@end

@implementation MyEQRScanViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - life circle
- (void)viewDidLoad
{
    [super viewDidLoad];
    //针对不同设备进行二维码界面的优化
    UIView *top,*left,*right,*bottom;
    if (IS_IPHONE_5) {
        if (IS_IOS6) {
            top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 148)];
            left = [[UIView alloc] initWithFrame:CGRectMake(0, 148, 60, 200)];
            right = [[UIView alloc] initWithFrame:CGRectMake(260, 148, 60, 200)];
            bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 348, 320, 200)];
        }else{
            top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 158)];
            left = [[UIView alloc] initWithFrame:CGRectMake(0, 158, 60, 200)];
            right = [[UIView alloc] initWithFrame:CGRectMake(260, 158, 60, 200)];
            bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 358, 320, 210)];
        }
    }else{
        if (IS_IOS6) {
            top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 104)];
            left = [[UIView alloc] initWithFrame:CGRectMake(0, 104, 60, 200)];
            right = [[UIView alloc] initWithFrame:CGRectMake(260, 104, 60, 200)];
            bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 304, 320, 156)];
        }else{
            top = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 114)];
            left = [[UIView alloc] initWithFrame:CGRectMake(0, 114, 60, 200)];
            right = [[UIView alloc] initWithFrame:CGRectMake(260, 114, 60, 200)];
            bottom = [[UIView alloc] initWithFrame:CGRectMake(0, 314, 320, 166)];
        }
    }
    top.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    left.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    right.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    bottom.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    ZBarReaderView *readerView = [ZBarReaderView new];
    readerView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    readerView.readerDelegate = self;
    readerView.torchMode = 0;
    readerView.trackingColor = [UIColor redColor];
    //扫描区域
    CGRect scanMaskRect = CGRectMake(60, CGRectGetMidY(readerView.frame)-126, 200, 200);
    //处理模拟器
    if (TARGET_IPHONE_SIMULATOR) {
        ZBarCameraSimulator *cameraSimulator
        = [[ZBarCameraSimulator alloc]initWithViewController:self];
        cameraSimulator.readerView = readerView;
    }
    [readerView addSubview:top];
    [readerView addSubview:left];
    [readerView addSubview:right];
    [readerView addSubview:bottom];
    [self.view addSubview:readerView];
    dispatch_async(dispatch_get_main_queue(), ^{
        //扫描区域计算
        readerView.scanCrop = [self getScanCrop:scanMaskRect readerViewBounds:readerView.bounds];
        [readerView start];
    });
    if (!self.jumpFromNav) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setFrame:CGRectMake(0, 0, 50, 30)];
        [btn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        if (!IS_IOS6) {
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        }
        [btn addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - ZBarReaderViewDelegate
//确定扫描区域
-(CGRect)getScanCrop:(CGRect)rect readerViewBounds:(CGRect)readerViewBounds
{
    CGFloat x,y,width,height;
    
    x = rect.origin.x / readerViewBounds.size.width;
    y = rect.origin.y / readerViewBounds.size.height;
    width = rect.size.width / readerViewBounds.size.width;
    height = rect.size.height / readerViewBounds.size.height;
    //    NSLog(@"%f %f",readerViewBounds.size.width,readerViewBounds.size.height);
    //    NSLog(@"%f  %f  %f  %f",x,y,width,height);
    return CGRectMake(x, y, width, height);
}
- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image
{
    NSString *soundPath=[[NSBundle mainBundle] pathForResource:@"beep-beep" ofType:@"aiff"];
    NSURL *soundUrl=[[NSURL alloc] initFileURLWithPath:soundPath];
    AVAudioPlayer *player=[[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    [player play];
    for (ZBarSymbol *symbol in symbols) {
        if (self.isAddCamera) {
            [self.delegate passCameraUID:symbol.data];
            break;
        }
        if ([symbol.data length] == 30) {
            [self.delegate passMID:[symbol.data substringToIndex:23] andPIN:[symbol.data substringFromIndex:24]];
        }else{
            [MyEUtil showMessageOn:nil withMessage:@"please scan the code behind the meditor"];
        }
        break;
    }
    [readerView stop];
    if (self.jumpFromNav) {
        [self.navigationController popViewControllerAnimated:YES];
    }else
        [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - IBAction methods
- (void)dismissView{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
