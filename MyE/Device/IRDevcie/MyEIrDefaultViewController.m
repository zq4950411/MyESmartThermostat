//
//  MyEIRDefaultViewController.m
//  MyE
//
//  Created by 翟强 on 14-5-12.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEIrDefaultViewController.h"
#import "MyEIrStudyEditKeyModalViewController.h"
#import "MyEIrUserKeyViewController.h"
@interface MyEIrDefaultViewController ()

@end

@implementation MyEIrDefaultViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    for (MyEControlBtn *btn in _keyBtns) {
        _initNumber++;
        btn.tag = _initNumber;
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.status = 0;  //这里要对status的值进行初始化
        NSLog(@"%@    %i",btn.currentTitle,btn.tag);
    }
    [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&deviceId=%@&tId=%@",GetRequst(URL_FOR_INSTRUCTIONLIST_VIEW),MainDelegate.houseData.houseId,self.device.deviceId,self.device.tid] andName:@"instructionList"];
}
#pragma mark - memory warning methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
-(MyEInstruction *)getInstructionByTypeId:(NSInteger)typeId{
    for (MyEInstruction *i in self.instructions.templateList) {
        if (i.type == typeId) {
            return i;
        }
    }
    return nil;
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
        [self editStudyKey:btn];
        
    }
}
-(void)refreshUI{
#warning 这里要针对不同的方式做不同的处理
    NSString *normalStr = nil;
    NSString *highlightStr = nil;
    for (MyEControlBtn *btn in _keyBtns) {
        if (btn.tag < 204 || btn.tag > 208) {
            normalStr = [NSString stringWithFormat:@"control-%@-normal",btn.status>0?@"enable":@"disable"];
            highlightStr = [NSString stringWithFormat:@"control-%@-highlight",btn.status>0?@"enable":@"disable"];
        }else{
            //这里要针对不同的btn设计图标
            normalStr = nil;
            highlightStr = nil;
        }
        [btn setBackgroundImage:[[UIImage imageNamed:normalStr] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIImage imageNamed:highlightStr] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
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
        
//        MyEInstruction *instruction = [[MyEInstruction alloc] init];
//        instruction.instructionId = btn.tag - _initNumber; //这里主要是有各种情况，所以这里要这么写
//        instruction.type = btn.tag;
//        instruction.name = btn.currentTitle;
        modalVc.instruction = [self getInstructionByTypeId:btn.tag];
        
        modalVc.keyNameTextfield.enabled = NO;
        modalVc.deleteKeyBtn.enabled = NO;
        if (btn.status > 0) {
            [modalVc.learnBtn setTitle:@"再学习" forState:UIControlStateNormal];
        }else
            modalVc.validateKeyBtn.enabled = NO;
    };
    
//    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
//        UINavigationController *navController = (UINavigationController *)formSheetController.presentedFSViewController;
//        MyEIrStudyEditKeyModalViewController *vc = (MyEIrStudyEditKeyModalViewController *)(navController.topViewController);
//        vc.keyNameTextfield.text = btn.currentTitle;
//    }];
    
    formSheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController) {
        [self refreshUI];
    };
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:nil];
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
#pragma mark - URL delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
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
            NSLog(@"self.parentViewController is %@  self is %@",self.parentViewController,self);
            NSLog(@"%@",self.view.superview.subviews[1]);
            UITableView *view = self.view.superview.subviews[1];
            MyEIrUserKeyViewController *vc = (MyEIrUserKeyViewController *)view.nextResponder;
            vc.instructions = self.instructions;
            [vc.tableView reloadData];
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
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
}
@end
