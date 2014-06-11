//
//  RegistGatewayViewController.m
//  MyE
//
//  Created by space on 13-8-31.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "RegistGatewayViewController.h"
#import "ACPButton.h"
#import "DictionaryTableViewViewController.h"
#import "UNRegistHouseViewController.h"
#import "MyEHouseListViewController.h"

#import "UIUtils.h"

@implementation RegistGatewayViewController

-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:SETTING_REGISTER_GATEWAY].location != NSNotFound)
    {
        if ([@"OK" isEqualToString:jsonString])
        {
            [SVProgressHUD showSuccessWithStatus:@"Success"];
            MyEHouseListViewController *houseListVC = (MyEHouseListViewController *)[UIUtils getControllerFromNavViewController:self andClass:[MyEHouseListViewController class]];
            [houseListVC refreshAction];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Error"];
        }
    }
}

-(void) netError:(id)errorMsg withUserInfo:(NSDictionary *)userInfo andURL:(NSString *) u
{

}



-(void) registerGateway:(UIButton *) sender
{
    if ([zoneId isBlank] || zoneId == nil)
    {
        [SVProgressHUD showErrorWithStatus:@"Please specify the time zone"];
        return;
    }
    
    
    if ([houseId isBlank] || houseId == nil)
    {
        [SVProgressHUD showErrorWithStatus:@"Please specify the property where this Gateway is to be used"];
        return;
    }
    
    if ([mid isBlank])
    {
        [SVProgressHUD showErrorWithStatus:@"Please enter the MID"];
        return;
    }
    
    if ([pin isBlank])
    {
        [SVProgressHUD showErrorWithStatus:@"Please enter the PIN"];
    }
    
    if (pin.length != 6)
    {
        [SVProgressHUD showErrorWithStatus:@"PIN is 6 length"];
        return;
    }
    
    self.isShowLoading = YES;
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [params safeSetObject:mid forKey:@"mid"];
    [params safeSetObject:pin forKey:@"pin "];
    [params safeSetObject:houseId forKey:@"associatedProperty"];
    [params safeSetObject:zoneId forKey:@"timeZone"];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(SETTING_REGISTER_GATEWAY)
                                      delegate:self
                                  withUserInfo:dic];
    
}


-(void) rowDidSelected:(NSDictionary *) dic
{
    zoneName = [dic valueToStringForKey:@"zoneName"];
    zoneId = [dic valueToStringForKey:@"zoneId"];
    [self.tableView reloadData];
}


-(void) houseDidSelected:(NSDictionary *) dic
{
    houseName = [dic valueToStringForKey:@"houseName"];
    houseId = [dic valueToStringForKey:@"associatedProperty"];
    [self.tableView reloadData];
}


-(void) dimissScan:(UIButton *) sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


-(void) scan:(UIButton *) sender
{
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    
    reader.showsZBarControls = NO;
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(dimissScan:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(200, 40, 75, 35);
    [button setTitle:@"cancel" forState:UIControlStateNormal];
    [reader.view addSubview:button];
    
    ZBarImageScanner *scanner = reader.scanner;
    
    [scanner setSymbology:ZBAR_I25 config:ZBAR_CFG_ENABLE to:0];
    
    for (int i = 0; i < reader.view.subviews.count; i++)
    {
        NSLog(@"%@",[[reader.view.subviews objectAtIndex:i] description]);
    }
    
    [self presentViewController:reader animated:YES completion:^{

    }];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void) textFieldDidEndEditing:(UITextField *) textField
{
    if (textField.tag == 0)
    {
        mid = textField.text;
    }
    else
    {
        pin = textField.text;
    }
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange) range replacementString:(NSString *) string
{
    if (textField.tag == 1)
    {
        return YES;
    }
    
    NSString *newString = [textField.text stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if (newString.length >= 16 && string.length != 0)
    {
        return NO;
    }
    
    if (string.length == 0)
    {
        return YES;
    }
    
    NSMutableString *sb = [NSMutableString string];
    
    for (int i = 0; i < newString.length; i++)
    {
        [sb appendFormat:@"%c",[newString characterAtIndex:i]];
        if ((i + 1) % 2 == 0 && i != 0)
        {
            [sb appendString:@"-"];
        }
    }
    
    textField.text = sb;
    return YES;
}






-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        UNRegistHouseViewController *unVc = [[UNRegistHouseViewController alloc] init];
        unVc.delegate = self;
        [self.navigationController pushViewController:unVc animated:YES];
    }
    else if(indexPath.section == 1 && indexPath.row == 1)
    {
//        {"zoneName":"EST","zoneId":1},{"zoneName":"CST","zoneId":2},{"zoneName":"MST","zoneId":3},{"zoneName":"PST","zoneId":4},{"zoneName":"AKST","zoneId":5},{"zoneName":"HST","zoneId":6}]}
        
        NSMutableArray *zoneList = [NSMutableArray arrayWithCapacity:0];
        
        [zoneList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"EST",@"zoneName",@"1", @"zoneId",nil]];
        [zoneList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"CST",@"zoneName",@"2",@"zoneId", nil]];
        [zoneList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"MST",@"zoneName",@"3",@"zoneId", nil]];
        [zoneList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"PST",@"zoneName",@"4",@"zoneId", nil]];
        [zoneList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"AKST",@"zoneName",@"5",@"zoneId", nil]];
        [zoneList addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"HST",@"zoneName",@"6",@"zoneId", nil]];
        DictionaryTableViewViewController *vc = [[DictionaryTableViewViewController alloc] initWithDatas:zoneList];
        vc.delegate = self;
        vc.type = -1;
        [self.navigationController pushViewController:vc animated:YES];
    }
}




-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 150;
    }
    else
    {
        return 0;
    }
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 140)];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 280, 60)];
        
        label1.backgroundColor = [UIColor clearColor];
        label1.numberOfLines = 10;
        label1.font = [UIFont systemFontOfSize:14.0f];
        label1.lineBreakMode = NSLineBreakByCharWrapping;
        label1.text = @"You need M-ID and PIN to register a Smart Gateway.You can find them from the label on the bottom of the Gateway.";
        [tempView addSubview:label1];
        
        ACPButton *button = [ACPButton buttonWithType:UIButtonTypeCustom];
        
        [button setStyleType:ACPButtonOK];
        [button setLabelFont:[UIFont systemFontOfSize:14.0f]];
        [button setTitle:@"Scan the 2D bar code to obtain M-ID and PIN" forState:UIControlStateNormal];
        button.frame = CGRectMake(10, 68, 300, 40);
        [tempView addSubview:button];
        [button addTarget:self action:@selector(scan:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 105, 280, 30)];
        
        label2.backgroundColor = [UIColor clearColor];
        label2.font = [UIFont systemFontOfSize:14.0f];
        label2.numberOfLines = 10;
        label2.lineBreakMode = NSLineBreakByCharWrapping;
        label2.text = @"Or you can enter M-ID and PIN manually";
        [tempView addSubview:label2];
        
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(20, 125, 280, 20)];
        
        label3.backgroundColor = [UIColor clearColor];
        label3.textColor = [UIColor blueColor];
        label3.font = [UIFont systemFontOfSize:12.0f];
        label3.numberOfLines = 10;
        label3.lineBreakMode = NSLineBreakByCharWrapping;
        label3.text = @"Leave out *-* in M-ID.Just enter the digits.";
        [tempView addSubview:label3];
        
        return tempView;
    }
    return nil;
}



-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else if(section == 1)
    {
        return 2;
    }
    else
    {
        return 1;
    }
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0)
    {
        UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(100, 15, 200, 25)];
        
        tf.font = [UIFont systemFontOfSize:14.0f];
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"M-ID";
            
            tf.text = mid;
            tf.tag = 0;
            tf.placeholder = @"05-01-00-00-00-00-00-00";
            tf.delegate = self;
        }
        else
        {
            cell.textLabel.text = @"PIN";
            
            tf.text = pin;
            tf.tag = 1;
            tf.placeholder = @"Please Enter Pin";
            tf.delegate = self;
        }
        
        [cell addSubview:tf];
    }
    else if(indexPath.section == 1)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"Associated property";
            cell.detailTextLabel.text = houseName;
        }
        else
        {
            cell.textLabel.text = @"Time zone";
            cell.detailTextLabel.text = zoneName;
        }
    }
    else
    {
        ACPButton *button = [ACPButton buttonWithType:UIButtonTypeCustom];
        
        [button setTitle:@"Register The Gateway" forState:UIControlStateNormal];
        [button setStyleType:ACPButtonOK];
        button.frame = CGRectMake(10, -10, 280, 44);
        [button addTarget:self action:@selector(registerGateway:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:button];
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, cell.height)];
    }
    return cell;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    if ([info count]>2)
    {
        int quality = 0;
        ZBarSymbol *bestResult = nil;
        for(ZBarSymbol *sym in results)
        {
            int q = sym.quality;
            if(quality < q)
            {
                quality = q;
                bestResult = sym;
            }
        }
        [self performSelector: @selector(presentResult:) withObject: bestResult afterDelay: .001];
    }
    else
    {
        ZBarSymbol *symbol = nil;
        for(symbol in results)
            break;
        [self performSelector: @selector(presentResult:) withObject: symbol afterDelay: .001];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void) presentResult: (ZBarSymbol*) sym
{
    if (sym)
    {
        NSString *tempStr = sym.data;
        if ([sym.data canBeConvertedToEncoding:NSShiftJISStringEncoding])
        {
            tempStr = [NSString stringWithCString:[tempStr cStringUsingEncoding:NSShiftJISStringEncoding] encoding:NSUTF8StringEncoding];
        }
        
        NSArray *array = [tempStr componentsSeparatedByString:@","];
        if(array.count == 2)
        {
            mid = [array objectAtIndex:0];
            pin = [array objectAtIndex:1];
            
            [self.tableView reloadData];
        }
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
