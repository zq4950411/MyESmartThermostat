//
//  MyEIrUserKeyViewController.m
//  MyE
//
//  Created by 翟强 on 14-5-10.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEIrUserKeyViewController.h"

@interface MyEIrUserKeyViewController ()

@end

@implementation MyEIrUserKeyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (IBAction)addNewKey:(UIButton *)sender {
}
- (IBAction)controlKey:(MyEControlBtn *)sender {
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    return cell;
}
@end
