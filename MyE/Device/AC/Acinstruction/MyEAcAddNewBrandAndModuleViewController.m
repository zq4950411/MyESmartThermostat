//
//  MyEAcAddNewBrandAndModuleViewController.m
//  MyEHomeCN2
//
//  Created by 翟强 on 13-11-21.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcAddNewBrandAndModuleViewController.h"

@interface MyEAcAddNewBrandAndModuleViewController ()

@end

@implementation MyEAcAddNewBrandAndModuleViewController
@synthesize jumpFromAddBtn,titleLabel;

#pragma mark - life circle methods 

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self defineTapGestureRecognizer];
    self.brandName.delegate = self;
    self.moduleName.delegate = self;
    
    if ([self.brandName.text length]==0||[self.moduleName.text length] == 0) {
        self.saveBtn.enabled = NO;
    }
    if (!IS_IOS6) {
        for (UIButton *btn in self.view.subviews) {
            if ([btn isKindOfClass:[UIButton class]]) {
                btn.layer.masksToBounds = YES;
                btn.layer.cornerRadius = 5;
                btn.layer.borderColor = btn.tintColor.CGColor;
                btn.layer.borderWidth = 1;
            }
        }
    }
}

#pragma mark - private methods
-(void)defineTapGestureRecognizer{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction methods
- (IBAction)save:(UIButton *)sender {
    if ([self.brandName.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"please enter brand name"];
        return;
    }
    if ([self.moduleName.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"Please enter model name"];
        return;
    }
// 这里需要对输入的名称进行判断，当然，只是对用户新增的内容进行判断
    for (NSString *s in self.modelNameArray) {
        if ([self.moduleName.text isEqualToString:s]) {
            for (NSString *s in self.brandNameArray) {
                if ([self.brandName.text isEqualToString:s]) {
                    [MyEUtil showInstructionStatusWithYes:NO andView:self.navigationController.navigationBar andMessage:@"This Model has existed"];
                    return;
                }
            }
        }
    }
    self.cancelBtnPressed = NO;
    [self addNewBrandAndModuleToServer];
}
- (IBAction)cancel:(UIButton *)sender {
    self.cancelBtnPressed = YES;
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:nil];
}

#pragma mark - URL private methods
-(void) submitEditToServer{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr;
    MyEDataLoader *uploader;
    urlStr= [NSString stringWithFormat:@"%@?&action=1&brandId=%li&moduleId=%li&tId=%@&brandName=%@&moduleName=%@",
             GetRequst(URL_FOR_AC_BRAND_MODEL_EDIT),
             (long)self.brandId,
             (long)self.moduleId,
             self.device.tid,
             self.brandName.text,
             self.moduleName.text];
    uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"editBrandAndModule"  userDataDictionary:nil];
    NSLog(@"%@",uploader.name);

}
- (void)addNewBrandAndModuleToServer
{
    if(HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        HUD.delegate = self;
    } else
        [HUD show:YES];
    
    NSString *urlStr;
    MyEDataLoader *uploader;
    urlStr= [NSString stringWithFormat:@"%@?houseId=%i&action=0&brandId=0&moduleId=0&tId=%@&brandName=%@&moduleName=%@",
             GetRequst(URL_FOR_AC_BRAND_MODEL_EDIT),
             MainDelegate.houseData.houseId,
             self.device.tid,
             self.brandName.text,
             self.moduleName.text];
    uploader = [[MyEDataLoader alloc] initLoadingWithURLString:urlStr postData:nil delegate:self loaderName:@"addNewBrandAndModule"  userDataDictionary:nil];
    NSLog(@"%@",uploader.name);
}

#pragma mark - URL delegate methods 

- (void) didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    if([name isEqualToString:@"addNewBrandAndModule"]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] == -1) {
            [SVProgressHUD showErrorWithStatus:@"fail"];
        } else{
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dic = [parser objectWithString:string];
            self.newBrandId = [dic[@"brandId"] intValue];
            self.newModuleId = [dic[@"moduleId"] intValue];
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            }];
        }
    }
    if([name isEqualToString:@"editBrandAndModule"]) {
        NSLog(@"ajax json = %@", string);
        if ([MyEUtil getResultFromAjaxString:string] != 1) {
            [SVProgressHUD showErrorWithStatus:@"fail"];
        } else{
            [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            }];
        }
    }
}
- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
#pragma mark - textField delegate methods 
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if ([self.brandName.text length]!=0||[self.moduleName.text length]!=0) {
        self.saveBtn.enabled = YES;
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}
@end
