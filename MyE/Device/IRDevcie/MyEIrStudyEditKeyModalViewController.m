//
//  MyEIrStudyEditKeyModalViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/3/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEIrStudyEditKeyModalViewController.h"

#define IR_DEVICE_DELETE_KEY_UPLOADER_NMAE @"IRDeviceDeleteKeyUploader"
#define IR_DEVICE_STUDY_KEY_LOADER_NMAE @"IRDeviceStudyKeyUploader"
#define IR_DEVICE_QUERY_STUDY_KEY_LOADER_NMAE @"IRDeviceQueryStudyKeyLoader"
#define IR_DEVICE_GET_STATUS_LOADER_NMAE @"IRDeviceStatusoader"
#define IR_DEVICE_SEND_KEY_STUDY_TIMEOUT_LOADER_NMAE @"IRDeviceSendKeyStudyTimeoutLoader"
#define IR_DEVICE_VALIDATE_KEY_LOADER_NMAE @"IRDeviceValidateKeyLoader"


@interface MyEIrStudyEditKeyModalViewController ()

@end

@implementation MyEIrStudyEditKeyModalViewController
@synthesize device = _device;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!IS_IOS6) {
        for (UIButton *btn in self.view.subviews) {
            if ([btn isKindOfClass:[UIButton class]] && btn.tag != 100) {
                [btn.layer setMasksToBounds:YES];
                [btn.layer setCornerRadius:5];
                [btn.layer setBorderWidth:1];
                [btn.layer setBorderColor:btn.tintColor.CGColor];
            }
        }
    }
    [self defineTapGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction methods
- (IBAction)studyKey:(id)sender {
    [self customizedHUD];
    [self uploadInfoToServerWithAction:@"record"];
}
- (IBAction)validateKey:(id)sender {
}
- (IBAction)deleteKey:(id)sender {
}

- (IBAction)closeModal:(id)sender {
}

#pragma mark -
#pragma mark UITextField Delegate Methods 委托方法
// 添加每个textfield的键盘的return按钮的后续动作
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.keyNameTextfield ) {
        [textField resignFirstResponder];
        //        [keyNameTextfield becomeFirstResponder];
    }
    
    return  YES;
}
#pragma mark -
#pragma mark private methods
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}
-(void)customizedHUD{
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.removeFromSuperViewOnHide = YES;
    HUD.userInteractionEnabled = YES;
    HUD.delegate = self;
    //初始化label
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,500)];
    //设置自动行数与字符换行
    [label setNumberOfLines:0];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.text = @"当智控星屏幕显示Lr--时，请按下遥控器按键进行学习。";
    
    UIFont *font = [UIFont fontWithName:@"Arial" size:12];
    //设置一个行高上限
    CGSize size = CGSizeMake(320,2000);
    //计算实际frame大小，并将label的frame变成实际大小
    CGSize labelsize = [label.text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    CGRect newFrame = label.frame;
    newFrame.size.height = labelsize.height;
    label.frame = newFrame;
    [label sizeToFit];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    HUD.customView = label;
    HUD.mode = MBProgressHUDModeCustomView;
}
-(void)uploadInfoToServerWithAction:(NSString *)action{
    if (![action isEqualToString:@"record"]) {
        if(HUD == nil) {
            HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        } else
            [HUD show:YES];
    }
    NSString * urlStr= [NSString stringWithFormat:@"%@?houseId=%i&tId=%@&name=%@&type=%i&instructionId=%i&deviceId=%@&action=%@",GetRequst(URL_FOR_INSTRUCTION_STUDY),MainDelegate.houseData.houseId,self.device.tid,self.instruction.name,self.instruction.type,self.instruction.instructionId,self.device.deviceId,action];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil
                                 delegate:self loaderName:action
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}
- (void) queryStudayProgressTimerFired:(NSTimer *)aTimer
{
    [self queryStudayProgress];
}
#pragma mark - URL private methods
-(void)queryStudayProgress
{
        studyQueryTimes ++;
        
        NSString * urlStr= [NSString stringWithFormat:@"%@?houseId=%i&tId=%@&instructionId=%i",GetRequst(URL_FOR_INSTRUCTION_FIND_RECORD),MainDelegate.houseData.houseId,self.device.tid,self.instruction.instructionId];
        MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                     initLoadingWithURLString:urlStr
                                     postData:nil
                                     delegate:self
                                     loaderName:IR_DEVICE_QUERY_STUDY_KEY_LOADER_NMAE
                                     userDataDictionary:nil];
        NSLog(@"%@",downloader.name);

}
-(void) sendInstructionStudyTimeout
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString * urlStr= [NSString stringWithFormat:@"%@?houseId=%i&tId=%@",GetRequst(URL_FOR_INSTRUCTION_TIME_OUT),MainDelegate.houseData.houseId,self.device.tid];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil
                                 delegate:self
                                 loaderName:IR_DEVICE_SEND_KEY_STUDY_TIMEOUT_LOADER_NMAE
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

#pragma mark - URL delegate methods
// 响应下载上传
- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    if ([MyEUtil getResultFromAjaxString:string] == -3) {
        [HUD hide:YES];
        [MyEUniversal doThisWhenUserLogOutWithVC:self];
        return;
    }
    
    if([name isEqualToString:IR_DEVICE_DELETE_KEY_UPLOADER_NMAE]) {
        [HUD hide:YES];
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"删除按键时发生错误！"];
        } else if ([MyEUtil getResultFromAjaxString:string] == 1){
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            }];
        }
    }
    if([name isEqualToString:IR_DEVICE_STUDY_KEY_LOADER_NMAE]) {
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"发送按键学习请求时发生错误！"];
            [HUD hide:YES];
        } else if ([MyEUtil getResultFromAjaxString:string] == 1){
            self.instruction.name = self.keyNameTextfield.text;
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            // 把JSON转为字典
            NSDictionary *result_dict = [parser objectWithString:string];
            id keyId = [result_dict objectForKey:@"id"];
            if (keyId) { // 设置此按键的id
                self.instruction.instructionId = [keyId intValue];
            }
            studyQueryTimes = 0;
            [self queryStudayProgress];
        }
    }
    if([name isEqualToString:IR_DEVICE_VALIDATE_KEY_LOADER_NMAE]) {
        [HUD hide:YES];
        if ([MyEUtil getResultFromAjaxString:string] == 1){
            [MyEUtil showInstructionStatusWithYes:YES andView:self.navigationController.navigationBar andMessage:@"校验指令发送成功！"];
        } else if ([MyEUtil getResultFromAjaxString:string] == -1){
            [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"校验指令发送失败！"];
        }
    }

    if([name isEqualToString:IR_DEVICE_QUERY_STUDY_KEY_LOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == 1){
            [HUD hide:YES];
            [MyEUtil showInstructionStatusWithYes:YES andView:self.navigationController.navigationBar andMessage:@"指令学习成功"];
            // 把这个指令的学习成功标志在数据model里面修改了
            self.instruction.status = 1;
            // 把校验按钮enable
            self.validateKeyBtn.enabled = YES;
//            [self.validateKeyBtn setTitleColor:[UIColor colorWithRed:.196 green:0.3098 blue:0.52 alpha:1.0] forState:UIControlStateNormal];
        } else{
            if(studyQueryTimes >= 6){
                [HUD hide:YES];
                [self sendInstructionStudyTimeout];
                studyQueryTimes = 0;
                [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"学习超时，请重新开始!"];
                //[MyEUtil showErrorOn:self.navigationController.view withMessage:@"学习超时，请重新开始!" ];
                self.instruction.status = 0;
            } else {
                NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(queryStudayProgressTimerFired:) userInfo:nil repeats:NO];
                NSLog(@"%@",timer);
            }
        }
    }
    if([name isEqualToString:IR_DEVICE_SEND_KEY_STUDY_TIMEOUT_LOADER_NMAE]) {
        [HUD hide:YES];
        self.instruction.status = 0;
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    
    // inform the user
    NSLog(@"In delegate Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    NSString *msg;
    if ([name isEqualToString:IR_DEVICE_DELETE_KEY_UPLOADER_NMAE])
        msg = @"删除按键通信错误，请稍后重试.";
    else if ([name isEqualToString:IR_DEVICE_STUDY_KEY_LOADER_NMAE])
        msg = @"发送按键学习请求通信错误，请稍后重试.";
    else if ([name isEqualToString:IR_DEVICE_QUERY_STUDY_KEY_LOADER_NMAE])
        msg = @"查询按键学习进度通信错误，请稍后重试.";
    else if ([name isEqualToString:IR_DEVICE_GET_STATUS_LOADER_NMAE])
        msg = @"指令学习通知通信错误.";
    else if ([name isEqualToString:IR_DEVICE_SEND_KEY_STUDY_TIMEOUT_LOADER_NMAE])
        msg = @"指令学习通知超时通信错误.";
    else if ([name isEqualToString:IR_DEVICE_VALIDATE_KEY_LOADER_NMAE])
        msg = @"指令校验超时通信错误.";
    else msg = @"通信错误，请稍后重试.";
    
    [MyEUtil showSuccessOn:self.navigationController.view withMessage:msg];
    [HUD hide:YES];
}

@end
