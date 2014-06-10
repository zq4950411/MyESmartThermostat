//
//  MyEUCWeatherViewController.m
//  MyE
//
//  Created by 翟强 on 14-6-9.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEUCWeatherViewController.h"

@interface MyEUCWeatherViewController (){
    NSMutableArray *_data;
}

@end

@implementation MyEUCWeatherViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _data = [NSMutableArray array];
    for (int i = 50; i < 91; i++) {
        [_data addObject:[NSString stringWithFormat:@"%i F",i]];
    }
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sequential conditionArray].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [self.sequential conditionArray][indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.row == self.sequential.preConditon) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    if (indexPath.row == 5) {
        if (self.sequential.preConditon == 5)
            cell.textLabel.text = [NSString stringWithFormat:@"If Temperature >= %iF",self.sequential.temperature];
    }
    if (indexPath.row == 6) {
        if (self.sequential.preConditon == 6)
            cell.textLabel.text = [NSString stringWithFormat:@"If Temperature <= %iF",self.sequential.temperature];
    }
    return cell;
}
#pragma mark - Table view delegate methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.sequential.preConditon = indexPath.row;
    [self.tableView reloadData];
    if (indexPath.row == 5 || indexPath.row == 6) {
        MYEPickerView *picker = [[MYEPickerView alloc] initWithView:self.view andTag:100 title:@"Select Tem" dataSource:_data andSelectRow:0];
        picker.delegate = self;
        [picker showInView:self.view];
    }
}
#pragma mark - MYEPickerView delegate methods
-(void)MYEPickerView:(UIView *)pickerView didSelectTitles:(NSString *)title andRow:(NSInteger)row{
    self.sequential.temperature = row + 50;
    [self.tableView reloadData];
}
@end
