//
//  MyECameraTableViewController.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 4/27/14.
//  Copyright (c) 2014 My Energy Domain Inc. All rights reserved.
//

#import "MyECameraTableViewController.h"
#import "MyECamera.h"
#import "MyECameraViewController.h"
#import "SBJson.h"
#import "MyEEditCameraViewController.h"
#import "MyECameraAddOptionViewController.h"
#import "PPPP_API.h"
#import "PPPPDefine.h"
#import "obj_common.h"
#import "MyAudioSession.h"

@interface MyECameraTableViewController ()
{
    NSCondition* _m_PPPPChannelMgtCondition;
    CPPPPChannelManagement* _m_PPPPChannelMgt;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
    NSIndexPath *_selectedIndex;
}
@end

@implementation MyECameraTableViewController

#pragma mark - life circle methods
-(void)viewWillAppear:(BOOL)animated{
    [self.tableView reloadData];
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self getCameraStatus];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.cameraList = [NSMutableArray array];
    // 这里的代码可以被替换成从服务器获取camera数据的代码.
    //    MyECamera *camera = [[MyECamera alloc] init];
    //    camera.UID = @"VSTC134699JBVUB";
    //    camera.name = @"Camera";
    //    camera.username = @"admin";
    //    camera.password = @"888888";
    //    [self.cameraList addObject:camera];
    //    MyECamera *camera1 = [[MyECamera alloc] init];
    //    camera1.UID = @"VSTC323869KTUZJ";
    //    camera1.name = @"MovingCamera";
    //    camera1.username = @"admin";
    //    camera1.password = @"888888";
    //    [self.cameraList addObject:camera1];
    //    [self _loadData];
    
    if (!_refreshHeaderView) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];   //更新最新时间
    
    _m_PPPPChannelMgtCondition = [[NSCondition alloc] init];
    _m_PPPPChannelMgt = new CPPPPChannelManagement();
    _m_PPPPChannelMgt->pCameraViewController = self;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self initialize];
        InitAudioSession();
    });
    [self downloadCameraListFromServer];
    
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(downloadCameraListFromServer)];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCamera:)];
    self.navigationItem.rightBarButtonItems = @[add,refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - data methods
-(void)_loadData{
    NSMutableArray *array = nil;
    NSString *filePath = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        array = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
        for (NSDictionary *d in array) {
            [self.cameraList addObject:[[MyECamera alloc] initWithDictionary:d]];
        }
        NSLog(@"%@",array);
    }else
        array = [NSMutableArray array];
}
-(void)_saveData{
    NSMutableArray *array = [NSMutableArray array];
    for (MyECamera *c in self.cameraList) {
        [array addObject:[c JSONDictionary]];
    }
    [array writeToFile:[self dataFilePath] atomically:YES];
}
-(NSString *)dataFilePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return [documentsDirectory stringByAppendingPathComponent:@"cameras.plist"];
}
#pragma mark - private methods
-(void)endGetCameraStatus{
    if (_isRefreshing) {
        _isRefreshing = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    }
}
-(void)getCameraStatus{
    if (![self.cameraList count]) {
        [self performSelector:@selector(endGetCameraStatus) withObject:nil afterDelay:0.3];
        return;
    }
    for (MyECamera *c in _cameraList) {
        [self ConnectCamWithCamera:c];  //这里不需要截图，只需要获取状态就可以了
        _m_PPPPChannelMgt->SetSnapshotDelegate((char*)[c.UID UTF8String], self);
        _m_PPPPChannelMgt->Snapshot([c.UID UTF8String]);
    }
}
- (void)initialize{
    PPPP_Initialize((char*)[@"EBGBEMBMKGJMGAJPEIGIFKEGHBMCHMJHCKBMBHGFBJNOLCOLCIEBHFOCCHKKJIKPBNMHLHCPPFMFADDFIINOIABFMH" UTF8String]);
    st_PPPP_NetInfo NetInfo;
    PPPP_NetworkDetect(&NetInfo, 0);
}
- (void)ConnectCamWithCamera:(MyECamera *)camera{
    [_m_PPPPChannelMgtCondition lock];
    //    camera.m_PPPPChannelMgt = new CPPPPChannelManagement();
    //    camera.m_PPPPChannelMgt->pCameraViewController = self;
    
    if (_m_PPPPChannelMgt == NULL) {
        [_m_PPPPChannelMgtCondition unlock];
        return;
    }
    _m_PPPPChannelMgt->Start([camera.UID UTF8String], [camera.username UTF8String], [camera.password UTF8String]);
    [_m_PPPPChannelMgtCondition unlock];
}

#pragma mark - URL method
-(void)downloadCameraListFromServer{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }else
        [HUD show:YES];
    [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?houseId=%i",GetRequst(URL_FOR_CAMERA_LIST),MainDelegate.houseData.houseId] postData:nil delegate:self loaderName:@"download" userDataDictionary:nil];
}
#pragma mark - IBAction methods
- (IBAction)addCamera:(UIBarButtonItem *)sender {
    MyECameraAddOptionViewController *vc = [[UIStoryboard storyboardWithName:@"Camera" bundle:nil] instantiateViewControllerWithIdentifier:@"cameraAdd"];
    vc.cameraList = self.cameraList;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)editCamera:(UIButton *)sender {
    CGPoint hit = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    MyECamera *c = self.cameraList[indexPath.row];
    NSLog(@"%i",indexPath.row);
    MyEEditCameraViewController *viewController = [[UIStoryboard storyboardWithName:@"Camera" bundle:nil] instantiateViewControllerWithIdentifier:@"edit"];
    viewController.camera = c;
    viewController.m_PPPPChannelMgt = _m_PPPPChannelMgt;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Notification methods
- (void) didEnterBackground{
    [_m_PPPPChannelMgtCondition lock];
    if (_m_PPPPChannelMgt == NULL) {
        [_m_PPPPChannelMgtCondition unlock];
        return;
    }
    _m_PPPPChannelMgt->StopAll();
    [_m_PPPPChannelMgtCondition unlock];
}

- (void) willEnterForeground{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initialize];
    });
    [self getCameraStatus];
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cameraList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyECamera *camera = self.cameraList[indexPath.row];
    //    NSLog(@"%@",camera);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cameracell" forIndexPath:indexPath];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:2];
    nameLabel.text = camera.name;
    UIImageView *imgMain = (UIImageView *)[cell.contentView viewWithTag:1];
    imgMain.image = [UIImage imageWithContentsOfFile:camera.imagePath];
    UILabel *lblStatus = (UILabel *)[cell.contentView viewWithTag:3];
    lblStatus.text = camera.status;
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:11];
    if (camera.isOnline) {
        imageView.image = [UIImage imageNamed:@"signal4"];
    }else
        imageView.image = [UIImage imageNamed:@"signal0"];
    
    return cell;
}
#pragma mark - table view delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MyECamera *camera = self.cameraList[indexPath.row];
    if (!camera.isOnline) {
        [MyEUtil showMessageOn:nil withMessage:@"Not online"];
        return;
    }
    MyECameraViewController *viewController = [[UIStoryboard storyboardWithName:@"Camera" bundle:nil] instantiateViewControllerWithIdentifier:@"cameraInfo"];
    viewController.camera = camera;
    viewController.modalPresentationStyle = UIModalPresentationNone;
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:viewController animated:YES completion:nil];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Alert" contentText:@"Are you sure to delete this camera?" leftButtonTitle:@"NO" rightButtonTitle:@"YES"];
        alert.rightBlock = ^{
            _selectedIndex = indexPath;
            MyECamera *_camera = _cameraList[indexPath.row];
            [MyEDataLoader startLoadingWithURLString:[NSString stringWithFormat:@"%@?id=%i&did=%@&user=%@&pwd=%@&name=%@&houseId=%i&action=3",GetRequst(URL_FOR_CAMERA_EDIT),_camera.deviceId,_camera.UID,_camera.username,_camera.password,_camera.name,MainDelegate.houseData.houseId] postData:nil delegate:self loaderName:@"edit" userDataDictionary:nil];
            //            [self.cameraList removeObjectAtIndex:indexPath.row];
            //            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            //            NSLog(@"%@",self.cameraList);
            //            [self _saveData];
        };
        [alert show];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}
#pragma mark - PPPPStatus Delegate methods
- (void) PPPPStatus: (NSString*) strDID statusType:(NSInteger) statusType status:(NSInteger) status{
    NSString* strPPPPStatus;
    BOOL isOnline = NO;
    switch (status) {
        case PPPP_STATUS_UNKNOWN:
            strPPPPStatus = @"Unknown";
            break;
        case PPPP_STATUS_CONNECTING:
            strPPPPStatus = @"Connecting";
            break;
        case PPPP_STATUS_INITIALING:
            strPPPPStatus = @"Initialing";
            break;
        case PPPP_STATUS_CONNECT_FAILED:
            strPPPPStatus = @"ConnectFailed";
            break;
        case PPPP_STATUS_DISCONNECT:
            strPPPPStatus = @"Disconnected";
            break;
        case PPPP_STATUS_INVALID_ID:
            strPPPPStatus = @"InvalidID";
            break;
        case PPPP_STATUS_ON_LINE:
            strPPPPStatus = @"Online";
            isOnline = YES;
            break;
        case PPPP_STATUS_DEVICE_NOT_ON_LINE:
            strPPPPStatus = @"Offline";
            break;
        case PPPP_STATUS_CONNECT_TIMEOUT:
            strPPPPStatus = @"ConnectTimeout";
            break;
        case PPPP_STATUS_INVALID_USER_PWD:
            strPPPPStatus = @"Invaliduserpwd";
            break;
        default:
            strPPPPStatus = @"Unknown";
            break;
    }
    NSLog(@"PPPPStatus  %@",strPPPPStatus);
    for (MyECamera *c in self.cameraList) {
        if ([c.UID isEqualToString:strDID]) {
            c.status = strPPPPStatus;
            c.isOnline = isOnline;
        }
    }
    if (_isRefreshing) {
        [self performSelectorOnMainThread:@selector(endGetCameraStatus) withObject:nil waitUntilDone:YES];
    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}
-(void)SnapshotNotify:(NSString *)strDID data:(char *)data length:(int)length{
    NSLog(@"receive image");
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory=[paths objectAtIndex:0];
    for (MyECamera *c in self.cameraList) {
        if ([c.UID isEqualToString:strDID]) {
			NSString *savedImagePath=[documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",c.UID]];
			[[NSData dataWithBytes:data length:length] writeToFile:savedImagePath atomically:YES];
            c.imagePath = savedImagePath;
        }
    }
    //    [self _saveData];
    if (_isRefreshing) {
        [self performSelectorOnMainThread:@selector(endGetCameraStatus) withObject:nil waitUntilDone:YES];
    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}
#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}
#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    _isRefreshing = YES;
    [self getCameraStatus];
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];
}

#pragma mark - URL Delegate method
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    NSLog(@"recevie string is %@",string);
    [HUD hide:YES];
    if ([name isEqualToString:@"download"]) {
        if (![string isEqualToString:@"fail"]) {
            NSArray *array = [string JSONValue];
            _cameraList = [NSMutableArray array];
            for (NSDictionary *d in array) {
                [_cameraList addObject:[[MyECamera alloc] initWithDictionary:d]];
            }
            if (_cameraList.count) {
                [self getCameraStatus];
            }
        }
    }
    if ([name isEqualToString:@"edit"]) {
        if ([string isEqualToString:@"OK"]) {
            [_cameraList removeObjectAtIndex:_selectedIndex.row];
            [self.tableView deleteRowsAtIndexPaths:@[_selectedIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else
            [SVProgressHUD showErrorWithStatus:@"Fail"];
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
@end
