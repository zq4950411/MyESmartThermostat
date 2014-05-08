//
//  UNRegistHouseViewController.m
//  MyE
//
//  Created by space on 13-8-31.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "UNRegistHouseViewController.h"

#import "MyEAccountData.h"
#import "MyEHouseData.h"

@implementation UNRegistHouseViewController

@synthesize delegate;



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([delegate respondsToSelector:@selector(houseDidSelected:)])
    {
        MyEHouseData *house = [self.datas safeObjectAtIndex:indexPath.row];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
        
        [dic safeSetObject:[NSString stringWithFormat:@"%d",house.houseId] forKey:@"associatedProperty"];
        [dic safeSetObject:house.houseName forKey:@"houseName"];
        
        [delegate houseDidSelected:dic];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    
    MyEHouseData *house = [self.datas safeObjectAtIndex:indexPath.row];
    cell.textLabel.text = house.houseName;
    
    return cell;
}







- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    if (self.datas == nil)
    {
        self.datas = [NSMutableArray arrayWithCapacity:0];
    }
    
    for (int i = 0; i < MainDelegate.accountData.houseList.count; i++)
    {
        MyEHouseData *house = [MainDelegate.accountData.houseList objectAtIndex:i];
        if ([house.mId isBlank] && house.connection == 1)
        {
            [self.datas addObject:house];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
