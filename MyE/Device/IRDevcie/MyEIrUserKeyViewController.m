//
//  MyEIrUserKeyViewController.m
//  MyE
//
//  Created by 翟强 on 14-5-10.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEIrUserKeyViewController.h"
#import "MyEIrStudyEditKeyModalViewController.h"

@interface MyEIrUserKeyViewController (){
    MBProgressHUD *HUD;
}

@end

@implementation MyEIrUserKeyViewController

#pragma mark - life circle methods
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isControlMode = YES;
    if (self.device.typeId.intValue == 5) {
        self.navigationItem.title = self.device.deviceName;
        [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&deviceId=%@&tId=%@",GetRequst(URL_FOR_INSTRUCTIONLIST_VIEW),MainDelegate.houseData.houseId,self.device.deviceId,self.device.tid] andName:@"instructionList"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)changeMode:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"Edit"]) {
        sender.title = @"Done";
        self.isControlMode = NO;
        self.view.backgroundColor = [UIColor colorWithRed:0.84 green:0.93 blue:0.95 alpha:1];
    }else{
        sender.title = @"Edit";
        self.isControlMode = YES;
        self.view.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1];
    }
}

- (IBAction)addNewKey:(UIButton *)sender {
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
        navController.topViewController.title = @"Key Study";
        MyEIrStudyEditKeyModalViewController *modalVc = (MyEIrStudyEditKeyModalViewController *)navController.topViewController;
        modalVc.device = self.device;
        modalVc.isAddKey = YES;  //这里表示的新增按键
        modalVc.instruction = [[MyEInstruction alloc] init];
        [modalVc.learnBtn setTitle:@"Study" forState:UIControlStateNormal];
        modalVc.validateKeyBtn.enabled = NO;
        [modalVc viewDidLoad];  //继续执行一遍
    };
    formSheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController) {
        [self.tableView reloadData];
    };
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:nil];
}
- (IBAction)controlKey:(MyEControlBtn *)sender {
    CGPoint hit = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    MyEInstruction *instruction = self.instructions.customList[indexPath.row];
    if (self.isControlMode) {
        if (instruction.status > 0) {
            [self uploadOrDownloadInfoFromServerWithURL:[NSString stringWithFormat:@"%@?houseId=%i&instructionId=%i",GetRequst(URL_FOR_INSTRUCTION_CONTROL),MainDelegate.houseData.houseId,instruction.instructionId] andName:@"control"];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"This Key Has not studied" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }else{
        [self editStudyKey:instruction];
    }
}
#pragma mark - private methods
-(void)editStudyKey:(MyEInstruction *)instruction
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
        navController.topViewController.title = @"Key Study";
        MyEIrStudyEditKeyModalViewController *modalVc = (MyEIrStudyEditKeyModalViewController *)navController.topViewController;
        modalVc.device = self.device;
        
        modalVc.instruction = instruction;
        if (instruction.status > 0) {
            [modalVc.learnBtn setTitle:@"Restudy" forState:UIControlStateNormal];
        }else
            modalVc.validateKeyBtn.enabled = NO;
        [modalVc viewDidLoad];  //继续执行一遍
    };
    formSheet.didDismissCompletionHandler = ^(UIViewController *presentedFSViewController) {
        [self.tableView reloadData];
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
#pragma mark - UITableView dataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.instructions.customList count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    UIButton *controlBtn = (UIButton *)[cell.contentView viewWithTag:100];
    MyEInstruction *instruction = self.instructions.customList[indexPath.row];
    [controlBtn setTitle:instruction.name forState:UIControlStateNormal];
    
    NSString *normalStr = [NSString stringWithFormat:@"control-%@-normal",instruction.status>0?@"enable":@"disable"];
    NSString *highlightStr = [NSString stringWithFormat:@"control-%@-highlight",instruction.status>0?@"enable":@"disable"];
    [controlBtn setBackgroundImage:[[UIImage imageNamed:normalStr] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
    [controlBtn setBackgroundImage:[[UIImage imageNamed:highlightStr] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateHighlighted];
    [controlBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [controlBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    
    return cell;
}
#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"receive string is %@",string);
    [HUD hide:YES];
    if ([name isEqualToString:@"instructionList"]) {
        if (![string isEqualToString:@"fail"]) {
            MyEInstructions *instructions = [[MyEInstructions alloc] initWithJSONString:string];
            self.instructions = instructions;
            [self.tableView reloadData];
        }
    }
}
@end
