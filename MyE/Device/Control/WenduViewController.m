//
//  WenduViewController.m
//  MyE
//
//  Created by space on 13-8-27.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "WenduViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "ControlViewController.h"
#import "Sequential.h"

@implementation WenduViewController


-(NSString *) getSelectedValue
{
    return [self.datas objectAtIndex:currentSelectedIndex];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([parentVC isKindOfClass:[ControlViewController class]])
    {
        ControlViewController *cc = (ControlViewController *)parentVC;
        cc.seq.precondition = [NSString stringWithFormat:@"%d",indexPath.row];
    }
    
    self.currentSelectedIndex = indexPath.row;
    [self.parentVC dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.text = [self.datas safeObjectAtIndex:indexPath.row];
    }
    return cell;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    self.datas = [NSMutableArray array];
    
    [self.datas addObject:@"None"];
    [self.datas addObject:@"If snow"];
    [self.datas addObject:@"If rain"];
    [self.datas addObject:@"If no rain"];
    [self.datas addObject:@"If sunny"];
    [self.datas addObject:@"If the temperature >"];
    [self.datas addObject:@"If the temperature <"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
