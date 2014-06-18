//
//  MyETerminalEditViewController.m
//  MyE
//
//  Created by 翟强 on 14-6-16.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyETerminalEditViewController.h"

@interface MyETerminalEditViewController (){
    MBProgressHUD *HUD;
}

@end

@implementation MyETerminalEditViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshUI];
    [self defineTapGestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - IBAction methods
- (IBAction)save:(UIBarButtonItem *)sender {
    [self.nameTxt resignFirstResponder];
    if ([self.nameTxt.text length] == 0 || [self.nameTxt.text length] > 10) {
        [MyEUtil showMessageOn:nil withMessage:@"name error!"];
        return;
    }
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?houseId=%i&tId=%@&aliasName=%@&controlState=%i",GetRequst(SETTING_EDITT),MainDelegate.houseData.houseId,self.terminal.tid,self.nameTxt.text,self.controlState.isOn] postData:nil delegate:self loaderName:@"edit" userDataDictionary:nil];
    NSLog(@"loader name is %@",loader.name);
}

#pragma mark - private methods
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGesture];
}

-(void)hideKeyboard{
    [self.nameTxt endEditing:YES];
}

-(void)refreshUI{
    self.nameTxt.text = self.terminal.name;
    self.signalImg.image = [self.terminal changeSignalToImage];
    self.TypeLbl.text = [self.terminal changeTypeToString];
    self.tidLbl.text = self.terminal.tid;
    self.controlLbl.text = self.terminal.type==0?@"LOCK":@"PowerSave Mode";
    [self.controlState setOn:self.terminal.controlState==1?YES:NO animated:YES];
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.terminal.type == 0 || self.terminal.type == 1) {
        return 5;
    }else
        return 4;
}

#pragma mark - MYEDataloader delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    NSLog(@"receive string is %@",string);
    if ([string isEqualToString:@"OK"]) {
        self.terminal.name = self.nameTxt.text;
        self.terminal.controlState = 1 - self.terminal.controlState;
        [self.navigationController popViewControllerAnimated:YES];
    }else
        [SVProgressHUD showErrorWithStatus:@"fail"];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
@end
