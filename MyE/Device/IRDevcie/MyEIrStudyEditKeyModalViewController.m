//
//  MyEIrStudyEditKeyModalViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 11/3/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEIrStudyEditKeyModalViewController.h"

#define IR_DEVICE_QUERY_STUDY_KEY_LOADER_NMAE @"IRDeviceQueryStudyKeyLoader"
#define IR_DEVICE_SEND_KEY_STUDY_TIMEOUT_LOADER_NMAE @"IRDeviceSendKeyStudyTimeoutLoader"


@interface MyEIrStudyEditKeyModalViewController (){
    NSTimer *_timer;
}

@end

@implementation MyEIrStudyEditKeyModalViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@",self.instruction);
    if (!IS_IOS6) {
        for (UIButton *btn in self.view.subviews) {
            if ([btn isKindOfClass:[UIButton class]]) {
                [btn.layer setMasksToBounds:YES];
                [btn.layer setCornerRadius:4];
                [btn.layer setBorderWidth:1];
                [btn.layer setBorderColor:btn.tintColor.CGColor];
            }
        }
    }
    self.keyNameTextfield.text = self.instruction.name;  //这里更改名称
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction methods
- (IBAction)studyKey:(id)sender {
    if (_isAddKey) {
        self.instruction.name = self.keyNameTextfield.text;
    }
    [self customizedHUD];
    [self uploadInfoToServerWithAction:@"record"];
}
- (IBAction)validateKey:(id)sender {
    [self uploadInfoToServerWithAction:@"verify"];
}
- (IBAction)deleteKey:(id)sender {
    [self uploadInfoToServerWithAction:@"delete"];
}

- (IBAction)closeModal:(id)sender {
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

#pragma mark -
#pragma mark UITextField Delegate Methods 委托方法
// 添加每个textfield的键盘的return按钮的后续动作
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.keyNameTextfield ) {
        [textField resignFirstResponder];
    }
    
    return  YES;
}
#pragma mark -
#pragma mark private methods
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
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
    label.text = @"Press the button on your remote control to record when the smart remote's screen shows Lr- -";
    UIFont *font = [UIFont systemFontOfSize:9];
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
    HUD.minSize = CGSizeMake(220, 100);
    HUD.customView = label;
    HUD.margin = 5;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.opacity = 0.8f;
}

#pragma mark - URL private methods
-(void)uploadInfoToServerWithAction:(NSString *)action{
    if (![action isEqualToString:@"record"]) {
        if(HUD == nil) {
            HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        } else{
            HUD.mode = MBProgressHUDModeDeterminate;
            [HUD show:YES];
        }
    }
    NSString * urlStr= [NSString stringWithFormat:@"%@?houseId=%i&tId=%@&name=%@&type=%i&instructionId=%i&deviceId=%@&action=%@",GetRequst(URL_FOR_INSTRUCTION_STUDY),MainDelegate.houseData.houseId,self.device.tid,self.instruction.name,self.instruction.type,self.instruction.instructionId,self.device.deviceId,action];
    MyEDataLoader *downloader = [[MyEDataLoader alloc]
                                 initLoadingWithURLString:urlStr
                                 postData:nil
                                 delegate:self loaderName:action
                                 userDataDictionary:nil];
    NSLog(@"%@",downloader.name);
}

-(void)queryStudayProgress  //进度查询
{
    NSLog(@"query time is %i",studyQueryTimes);
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
-(void) sendInstructionStudyTimeout //学习超时
{
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
    if (string.intValue == -999) {
        [SVProgressHUD showErrorWithStatus:@"No Connection"];
    }
    if ([name isEqualToString:@"record"]) {
        if (![string isEqualToString:@"fail"]) {
            if (string.intValue > 0) {
                self.instruction.instructionId = string.intValue;
                if (_isAddKey) {
                    if (![self.instructions.customList containsObject:self.instruction]) {
                        [self.instructions.customList addObject:self.instruction];  //这时候服务器默认已经添加了这个按键，不管这个按键有没有学习成功
                    }
                }
                [self queryStudayProgress];
            }else if (string.intValue == -500){
                [HUD hide:YES];
                [MyEUtil showInstructionStatusWithYes:YES andView:self.navigationController.navigationBar andMessage:@"name is existed"];
            }
        }
    }
    if ([name isEqualToString:@"verify"]) {
        [HUD hide:YES];
        if ([string isEqualToString:@"OK"]) {
            [MyEUtil showInstructionStatusWithYes:YES andView:self.navigationController.navigationBar andMessage:@"success"];
        }else
            [MyEUtil showInstructionStatusWithYes:YES andView:self.navigationController.navigationBar andMessage:@"fail"];
    }
    if ([name isEqualToString:@"delete"]) {
        [HUD hide:YES];
        if ([string isEqualToString:@"OK"]) {
            [SVProgressHUD showSuccessWithStatus:@"sucess"];
            if ([self.instructions.customList containsObject:self.instruction]) {
                [self.instructions.customList removeObject:self.instruction];
            }
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
        }else
            [SVProgressHUD showErrorWithStatus:@"fail"];
    }
    if([name isEqualToString:IR_DEVICE_QUERY_STUDY_KEY_LOADER_NMAE]) {
        NSLog(@"ajax json = %@", string);
        if ([string isEqualToString:@"fail"]) {
            [HUD hide:YES];
            [SVProgressHUD showErrorWithStatus:@"Error!"];
        }else if ([string isEqualToString:@"1"]){
            [HUD hide:YES];
            [MyEUtil showInstructionStatusWithYes:YES andView:self.navigationController.navigationBar andMessage:@"success"];
            // 把这个指令的学习成功标志在数据model里面修改了
            self.instruction.status = 1;
            // 把校验按钮enable
            self.validateKeyBtn.enabled = YES;
        } else{
            if(studyQueryTimes >= 6){
                [HUD hide:YES];
                [_timer invalidate];  //这里要将定时器清空
                [self sendInstructionStudyTimeout];
                studyQueryTimes = 0;
                [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"Time out! Please re-record"];
                self.instruction.status = 0;
            } else {
                _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(queryStudayProgress) userInfo:nil repeats:NO];
            }
        }
    }
    if([name isEqualToString:IR_DEVICE_SEND_KEY_STUDY_TIMEOUT_LOADER_NMAE]) {
        [HUD hide:YES];
        self.instruction.status = 0;
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
@end
