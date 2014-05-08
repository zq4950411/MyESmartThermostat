//
//  MyETVDefaultViewController.m
//  MyE
//
//  Created by 翟强 on 14-4-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyETVDefaultViewController.h"

@interface MyETVDefaultViewController ()
{
    MBProgressHUD *HUD;
}
@end

@implementation MyETVDefaultViewController

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
    //给每个button一个tag，这个tag值与他自身的type属性值相对应
    for (MyEControlBtn *btn in self.controlBtns) {
        for (int i = 201; i < [self.controlBtns count]; i++) {
            btn.tag = i;
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&deviceId=%@&tId=%@",GetRequst(URL_FOR_INSTRUCTIONLIST_VIEW),MainDelegate.houseData.houseId,self.device.deviceId,self.device.tid] andName:@"instructionList"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - private methods
-(NSInteger)getInstructionIdByTypeId:(NSInteger)typeId{
    for (MyEInstruction *i in self.instructions.templateList) {
        if (i.type == typeId) {
            return i.instructionId;
        }
    }
    return 0;
}
-(void)btnClicked:(MyEControlBtn *)btn{
    if (self.isControlMode) {
        if (btn.status > 0) {
            [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&instructionId=%i",GetRequst(URL_FOR_INSTRUCTION_CONTROL),MainDelegate.houseData.houseId,[self getInstructionIdByTypeId:btn.tag]] andName:@"control"];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"This Key Has not studied" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }else{
#warning 这里是指令学习
        [self editStudyKey:btn];
        
    }
}
-(void)refreshUI{
    for (MyEControlBtn *btn in self.controlBtns) {
        if (btn.status > 0) {
            [btn setBackgroundImage:[UIImage imageNamed:@"000"] forState:UIControlStateNormal];
        }else
            [btn setBackgroundImage:[UIImage imageNamed:@"111"] forState:UIControlStateNormal];
    }
}
-(void)editStudyKey:(MyEControlBtn *)btn
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Device" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"IRDeviceStudyEditKeyModal"];
    
    MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.presentedFormSheetSize = CGSizeMake(280, 250);
    formSheet.shouldDismissOnBackgroundViewTap = NO;  //点击背景是否关闭
    formSheet.shouldCenterVertically = YES;
    formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsCenterVertically;
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        // Passing data
        UINavigationController *navController = (UINavigationController *)presentedFSViewController;
        navController.topViewController.title = @"按键学习";
        MyEIrStudyEditKeyModalViewController *modalVc = (MyEIrStudyEditKeyModalViewController *)navController.topViewController;
        modalVc.device = self.device;
        
        MyEInstruction *instruction = [[MyEInstruction alloc] init];
        instruction.instructionId = btn.tag - 200;
        instruction.type = btn.tag;
        instruction.name = btn.currentTitle;
        modalVc.instruction = instruction;
        
        modalVc.keyNameTextfield.enabled = NO;
        modalVc.deleteKeyBtn.enabled = NO;
        if (btn.status > 0) {
            [modalVc.learnBtn setTitle:@"再学习" forState:UIControlStateNormal];
        }else
            modalVc.validateKeyBtn.enabled = NO;
    };
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        UINavigationController *navController = (UINavigationController *)formSheetController.presentedFSViewController;
        MyEIrStudyEditKeyModalViewController *vc = (MyEIrStudyEditKeyModalViewController *)(navController.topViewController);
        vc.keyNameTextfield.text = btn.currentTitle;
    }];
    
    formSheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController) {
#warning 这里要更改btn的status属性
        [self refreshUI];
    };
}

#pragma mark - url methods
-(void)uploadOrDownloadInfoFromServerWithURL:(NSString *)string andName:(NSString *)name{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:string postData:nil delegate:self loaderName:name userDataDictionary:nil];
    NSLog(@"%@",loader.name);
}
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    if ([name isEqualToString:@"instructionList"]) {
        if (![string isEqualToString:@"fail"]) {
            MyEInstructions *instructions = [[MyEInstructions alloc] initWithJSONString:string];
            self.instructions = instructions;
            for (MyEInstruction *i in self.instructions.templateList) {
                MyEControlBtn *btn = (MyEControlBtn *)[self.view viewWithTag:i.type];
                btn.status = 1;
            }
            [self refreshUI];
            NSLog(@"self.parentViewController.childViewControllers is %@",self.parentViewController.childViewControllers);
#warning 传值
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
    if ([name isEqualToString:@"control"]) {
        if (string.intValue == -999) {
            [SVProgressHUD showErrorWithStatus:@"No Connection"];
        }else if (![string isEqualToString:@"fail"]){
            
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
}
@end
