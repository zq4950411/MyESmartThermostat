//
//  MyERoomsTableViewController.m
//  MyE
//
//  Created by 翟强 on 14-4-23.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyERoomsTableViewController.h"

@interface MyERoomsTableViewController ()
{
    MBProgressHUD *HUD;
    NSIndexPath *_selectedIndex;
    NSString *_roomName;
    NSMutableArray *_datas;
}
@end

@implementation MyERoomsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = view;
    //这里要将roomName是ALL的房间移除掉，因为这个房间不能编辑
    NSMutableArray *roomArray = [self.mainDevice.rooms mutableCopy];
    for (MyERoom *r in self.mainDevice.rooms) {
        if (r.roomId == -1) {
            [roomArray removeObject:r];
        }
    }
    _datas = roomArray;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - private methods
-(void)editRoomWithAction:(NSString *)action andRoomId:(NSInteger)roomId andRoomName:(NSString *)name andLoaderName:(NSString *)string{
    if (HUD == nil) {
        HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [HUD show:YES];
    MyEDataLoader *loader = [[MyEDataLoader alloc] initLoadingWithURLString:[NSString stringWithFormat:@"%@?houseId=%i&LocationId=%i&name=%@&action=%@",GetRequst(URL_FOR_LOCATION_EDIT),MainDelegate.houseData.houseId,roomId,name,action] postData:nil delegate:self loaderName:string userDataDictionary:nil];
    NSLog(@"%@",loader.name);
}
-(void)doThisWhenNeedAlertViewWithTag:(NSInteger)tag placeHold:(NSString *)text{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please enter room name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.text = text;
    textField.textAlignment = NSTextAlignmentCenter;
    alert.tag = tag;
    [alert show];
}
- (IBAction)addRoom:(UIBarButtonItem *)sender {
    if ([_datas count] > 10) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You have enough rooms,so can not add new room!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [self doThisWhenNeedAlertViewWithTag:100 placeHold:@""];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_datas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"roomCell" forIndexPath:indexPath];
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *countLabel = (UILabel*)[cell.contentView viewWithTag:102];
    MyERoom *room = _datas[indexPath.row];
    nameLabel.text = room.roomName;
    NSInteger i = 0;
    if ([self.mainDic.allKeys containsObject:room.roomName]) {
        NSArray *array = self.mainDic[room.roomName];
        i = [array count];
    }
    countLabel.text = [NSString stringWithFormat:@"%li",(long)i];
    UIView *bgview = (UIView *)[cell.contentView viewWithTag:1024];
    bgview.layer.cornerRadius = 4;
    return cell;
}

#pragma mark - table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectedIndex = indexPath;
    MyERoom *room = _datas[indexPath.row];
    if (room.roomId == 0) {  //这个房间类型名称不能修改
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"This room does not allow rename!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [self doThisWhenNeedAlertViewWithTag:101 placeHold:room.roomName];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        _selectedIndex = indexPath;
        MyERoom *room = _datas[indexPath.row];
        [self editRoomWithAction:@"deteleLocation" andRoomId:room.roomId andRoomName:room.roomName andLoaderName:@"delete"];
    }
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    MyERoom *room = _datas[indexPath.row];
    if (room.roomId == 0) {
        return NO;
    }
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UILabel *countLabel = (UILabel *)[cell.contentView viewWithTag:102];
    if (countLabel.text.integerValue > 0) {
        return NO;
    }
    return YES;
}
#pragma mark - URL Delegate methods
-(void)didReceiveString:(NSString *)string loaderName:(NSString *)name userDataDictionary:(NSDictionary *)dict{
    [HUD hide:YES];
    NSLog(@"receive string is %@",string);
    if ([name isEqualToString:@"delete"]) {
        if (![string isEqualToString:@"fail"]) {
            [_datas removeObjectAtIndex:_selectedIndex.row];
            [self.tableView deleteRowsAtIndexPaths:@[_selectedIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
    if ([name isEqualToString:@"add"]) {
        if (string.intValue == 502) {
            [SVProgressHUD showWithStatus:@"room count above 30"];
        }else if (![string isEqualToString:@"fail"]){
            MyERoom *room = [[MyERoom alloc] init];
            room.roomName = _roomName;
            room.roomId = string.intValue;
            [_datas addObject:room];
            [self.tableView reloadData];
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
    if ([name isEqualToString:@"edit"]) {
        if (![name isEqualToString:@"fail"]) {
            MyERoom *room = _datas[_selectedIndex.row];
            
            // 首先更新词典的key name
            NSArray *devices = self.mainDic[room.roomName];
            [self.mainDic removeObjectForKey:room.roomName];
            self.mainDic[_roomName] = devices;
            
            room.roomName = _roomName;
            [self.tableView reloadData];
        }else
            [SVProgressHUD showErrorWithStatus:@"Error!"];
    }
    MyEDevicesViewController *vc = self.navigationController.childViewControllers[[self.navigationController.childViewControllers indexOfObject:self] - 1];  //这里这么做是为了以防万一
    vc.needRefresh = YES;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error loaderName:(NSString *)name{
    [HUD hide:YES];
    [SVProgressHUD showErrorWithStatus:@"Connection Fail"];
}
#pragma mark - UIAlertView Delegate methods
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%@",alertView.subviews);
    UITextField *textField = [alertView textFieldAtIndex:0];
    _roomName = textField.text;
    if (buttonIndex == 1) {
        if (alertView.tag == 100) {
            [self editRoomWithAction:@"addLocation" andRoomId:-1 andRoomName:_roomName andLoaderName:@"add"];
        }else{
            MyERoom *room = _datas[_selectedIndex.row];
            [self editRoomWithAction:@"editLocation" andRoomId:room.roomId andRoomName:_roomName andLoaderName:@"edit"];
        }
    }
}
@end
