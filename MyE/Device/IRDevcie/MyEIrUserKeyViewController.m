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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)addNewKey:(UIButton *)sender {
    
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
        navController.topViewController.title = @"按键学习";
        MyEIrStudyEditKeyModalViewController *modalVc = (MyEIrStudyEditKeyModalViewController *)navController.topViewController;
        modalVc.device = self.device;
        
        modalVc.instruction = instruction;
        if (instruction.status > 0) {
            [modalVc.learnBtn setTitle:@"再学习" forState:UIControlStateNormal];
        }else
            modalVc.validateKeyBtn.enabled = NO;
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
@end
