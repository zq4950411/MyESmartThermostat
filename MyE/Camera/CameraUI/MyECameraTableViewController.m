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
    BOOL _isDetailView; //用于指定大view视图
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _isRefreshing;
}
@end

@implementation MyECameraTableViewController

#pragma mark - life circle methods
-(void)viewWillAppear:(BOOL)animated{
    if (self.needRefresh) {
        self.needRefresh = NO;
        [self _saveData];
        [self getCameraStatus];
    }
    [self.tableView reloadData];
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
    [self _loadData];
    
    if (!_refreshHeaderView) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        view.delegate = self;
        [self.tableView addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];   //更新最新时间
    
    _m_PPPPChannelMgtCondition = [[NSCondition alloc] init];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initialize];
    });
    if ([self.cameraList count]) {
        [self getCameraStatusForTheFirstTime];
    }
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(didEnterBackground)
    //                                                 name:UIApplicationDidEnterBackgroundNotification
    //                                               object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(willEnterForeground)
    //                                                 name:UIApplicationWillEnterForegroundNotification
    //                                               object:nil];
    InitAudioSession();
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCamera:)];
//    UIBarButtonItem *detail = [[UIBarButtonItem alloc] initWithTitle:@"Detail" style:UIBarButtonItemStylePlain target:self action:@selector(cameraDetailInfo:)];
//    self.navigationItem.rightBarButtonItems = @[add,detail];
    self.navigationItem.rightBarButtonItem = add;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
-(void)getCameraStatusForTheFirstTime{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < [self.cameraList count]; i++) {
            MyECamera *c = self.cameraList[i];
            [self ConnectCamWithCamera:c];  //这里不需要截图，只需要获取状态就可以了
        }
    });
}
-(void)getCameraStatus{
    if (![self.cameraList count]) {
        [self endGetCameraStatus];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < [self.cameraList count]; i++) {
            MyECamera *c = self.cameraList[i];
            [self ConnectCamWithCamera:c];
            c.m_PPPPChannelMgt->SetSnapshotDelegate((char*)[c.UID UTF8String], self);
            c.m_PPPPChannelMgt->Snapshot([c.UID UTF8String]);
        }
    });
}
- (void)initialize{
    PPPP_Initialize((char*)[@"EBGBEMBMKGJMGAJPEIGIFKEGHBMCHMJHCKBMBHGFBJNOLCOLCIEBHFOCCHKKJIKPBNMHLHCPPFMFADDFIINOIABFMH" UTF8String]);
    st_PPPP_NetInfo NetInfo;
    PPPP_NetworkDetect(&NetInfo, 0);
}
- (void)ConnectCamWithCamera:(MyECamera *)camera{
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self initialize];
    //    });
    [_m_PPPPChannelMgtCondition lock];
    camera.m_PPPPChannelMgt = new CPPPPChannelManagement();
    camera.m_PPPPChannelMgt->pCameraViewController = self;
    
    if (camera.m_PPPPChannelMgt == NULL) {
        [_m_PPPPChannelMgtCondition unlock];
        return;
    }
    camera.m_PPPPChannelMgt->Start([camera.UID UTF8String], [camera.username UTF8String], [camera.password UTF8String]);
    [_m_PPPPChannelMgtCondition unlock];
}
#pragma mark - IBAction methods
- (IBAction)addCamera:(UIBarButtonItem *)sender {
    MyECameraAddOptionViewController *vc = [[UIStoryboard storyboardWithName:@"Camera" bundle:nil] instantiateViewControllerWithIdentifier:@"cameraAdd"];
    vc.cameraList = self.cameraList;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)cameraDetailInfo:(UIBarButtonItem *)sender {
    _isDetailView = !_isDetailView;
    [self.tableView reloadData];
}
- (IBAction)editCamera:(UIButton *)sender {
    CGPoint hit = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:hit];
    MyECamera *c = self.cameraList[indexPath.row];
    NSLog(@"%i",indexPath.row);
    MyEEditCameraViewController *viewController = [[UIStoryboard storyboardWithName:@"Camera" bundle:nil] instantiateViewControllerWithIdentifier:@"edit"];
    viewController.camera = c;
    viewController.m_PPPPChannelMgt = c.m_PPPPChannelMgt;
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
    [self getCameraStatusForTheFirstTime];
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cameraList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    MyECamera *camera = self.cameraList[indexPath.row];
    //    NSLog(@"%@",camera);
    if (_isDetailView) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cameraDetail" forIndexPath:indexPath];
        UIImageView *image = (UIImageView *)[cell.contentView viewWithTag:100];
        image.image = [UIImage imageWithContentsOfFile:camera.imagePath];
        UILabel *name = (UILabel *)[cell.contentView viewWithTag:101];
        name.text = camera.name;
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"cameracell" forIndexPath:indexPath];
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
    }
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
    [self.navigationController pushViewController:viewController animated:YES];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DXAlertView *alert = [[DXAlertView alloc] initWithTitle:@"Alert" contentText:@"Are you sure to delete this camera?" leftButtonTitle:@"NO" rightButtonTitle:@"YES"];
        alert.rightBlock = ^{
            [self.cameraList removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            NSLog(@"%@",self.cameraList);
            [self _saveData];
        };
        [alert show];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isDetailView) {
        return 186;
    }else
        return 70;
}

#pragma mark - PPPPStatus Delegate methods
- (void) PPPPStatus: (NSString*) strDID statusType:(NSInteger) statusType status:(NSInteger) status{
    NSString* strPPPPStatus;
    BOOL isOnline = NO;
    switch (status) {
        case PPPP_STATUS_UNKNOWN:
            strPPPPStatus = @"Unknown";
            [self performSelectorOnMainThread:@selector(endGetCameraStatus) withObject:nil waitUntilDone:YES];
            break;
        case PPPP_STATUS_CONNECTING:
            strPPPPStatus = @"Connecting";
            break;
        case PPPP_STATUS_INITIALING:
            strPPPPStatus = @"Initialing";
            break;
        case PPPP_STATUS_CONNECT_FAILED:
            strPPPPStatus = @"ConnectFailed";
            [self performSelectorOnMainThread:@selector(endGetCameraStatus) withObject:nil waitUntilDone:YES];
            break;
        case PPPP_STATUS_DISCONNECT:
            strPPPPStatus = @"Disconnected";
            [self performSelectorOnMainThread:@selector(endGetCameraStatus) withObject:nil waitUntilDone:YES];
            break;
        case PPPP_STATUS_INVALID_ID:
            strPPPPStatus = @"InvalidID";
            [self performSelectorOnMainThread:@selector(endGetCameraStatus) withObject:nil waitUntilDone:YES];
            break;
        case PPPP_STATUS_ON_LINE:
            strPPPPStatus = @"Online";
            isOnline = YES;
            [self performSelectorOnMainThread:@selector(endGetCameraStatus) withObject:nil waitUntilDone:YES];
            break;
        case PPPP_STATUS_DEVICE_NOT_ON_LINE:
            strPPPPStatus = @"Offline";
            [self performSelectorOnMainThread:@selector(endGetCameraStatus) withObject:nil waitUntilDone:YES];
            break;
        case PPPP_STATUS_CONNECT_TIMEOUT:
            strPPPPStatus = @"ConnectTimeout";
            [self performSelectorOnMainThread:@selector(endGetCameraStatus) withObject:nil waitUntilDone:YES];
            break;
        case PPPP_STATUS_INVALID_USER_PWD:
            strPPPPStatus = @"Invaliduserpwd";
            [self performSelectorOnMainThread:@selector(endGetCameraStatus) withObject:nil waitUntilDone:YES];
            break;
        default:
            strPPPPStatus = @"Unknown";
            [self performSelectorOnMainThread:@selector(endGetCameraStatus) withObject:nil waitUntilDone:YES];
            break;
    }
    NSLog(@"PPPPStatus  %@",strPPPPStatus);
    for (MyECamera *c in self.cameraList) {
        if ([c.UID isEqualToString:strDID]) {
            c.status = strPPPPStatus;
            c.isOnline = isOnline;
        }
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
    [self _saveData];
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

@end
