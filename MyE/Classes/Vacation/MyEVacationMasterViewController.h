//
//  MyEVacationMasterViewController.h
//  MyE
//
//  Created by Ye Yuan on 2/23/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyEDataLoader.h"
#import "MyEVacationDetailViewController.h"
#import "MyEStaycationDetailViewController.h"
#import "MBProgressHUD.h"
@class MyEVacationListData;
@class MyETipViewController;

@interface MyEVacationMasterViewController : UITableViewController <MyEDataLoaderDelegate, MyEVacationDetailViewControllerDelegate, MyEStaycationDetailViewControllerDelegate, MBProgressHUDDelegate>{
    MyEVacationListData *_vacationsModel;

    
    MBProgressHUD *HUD;
    MyETipViewController *_tipViewController;
    
    // 下面变量纯粹用于要删除或修改Vacation item前显示AlertView时，要把下一步具体删除修改动作的所需变量保存下来，等AlertView点击YES后才执行真正的删除修改
    NSString *_uploadString;
    NSString *_actionString;
    NSDictionary *_userDataDictionary;

    // 下面两个变量用于在detail面板删除条目时，返回本MyEVacationMasterView后进行删除，需要记录表格中对应的项目的位置，以便更新表格
    // 每次用户点击一个条目时、进入detail之前，就要记录下面两个变量
    UITableView *_tableView;//这个其实不用记录，就是本VC中惟一的tableView
    NSIndexPath *_indexPath;
}
@property (copy, nonatomic) NSString *userId;
@property (nonatomic) NSInteger houseId;
@property (nonatomic,copy) NSString *houseName;
@property (nonatomic, copy) NSString *tId;
@property (nonatomic) BOOL isRemoteControl;


@property (strong, nonatomic) MyEVacationListData *vacationsModel;
- (void) downloadModelFromServer;
- (void) uploadToServerWithString:(NSString *)string action:(NSString *)action userDataDictionary:(NSDictionary *)dict;
@end
