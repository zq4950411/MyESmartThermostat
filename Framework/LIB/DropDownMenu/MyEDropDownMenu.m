//
//  MyEDropDownMenu.m
//
//  MyE
//  based on :
//  https://github.com/darthpelo/ARNavBar
//  https://github.com/leviathan/NIDropDown
//  https://github.com/BijeshNair/NIDropDown
//
//  Created by Ye Yuan on 5/19/14.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEDropDownMenu.h"
#import "QuartzCore/QuartzCore.h"

#define CELL 44

@interface MyEDropDownMenu ()
@property(nonatomic, strong) UITableView *table;
@property(nonatomic, strong) UIView *viewSender;
@property(nonatomic, retain) NSArray *list;
@property(nonatomic, retain) NSArray *imgList;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, assign) CGFloat tableWidth;
@property(nonatomic, assign) CGFloat tableHeight;
@end

@implementation MyEDropDownMenu
@synthesize table;
@synthesize viewSender;
@synthesize list;
@synthesize imgList;

- (id)showDropDown:(UIView *)view titleList:(NSArray *)titleList imageList:(NSArray *)imageList directionDown:(BOOL)direction
{
    viewSender = view;
    goDownDirection = direction;
    
    
    self.table = (UITableView *)[super init];
    if (self) {
        self.list = [NSArray arrayWithArray:titleList];
        self.imgList = [NSArray arrayWithArray:imageList];
        
        UIView *rootView = view.window.subviews[0];
        CGRect rootFrame = rootView.frame;
        self.width = rootFrame.size.width;
        self.height = rootFrame.size.height;
        
        self.tableWidth = viewSender.frame.size.width;
        self.tableHeight = (self.list.count * CELL);
        if(self.list.count > 5)
            self.tableHeight = 5 * CELL;
        self.frame = CGRectMake(rootFrame.origin.x, rootFrame.origin.y, self.width, self.height);

        
        self.layer.masksToBounds = NO;
        self.layer.shadowRadius = 1;
        self.layer.shadowOpacity = 0.5;
        [view.superview addSubview:self];
        
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(viewSender.frame.origin.x, viewSender.frame.origin.y + viewSender.frame.size.height, self.tableWidth, self.tableHeight)];
        table.delegate = self;
        table.dataSource = self;
        table.backgroundColor = [UIColor clearColor];
        table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [table setScrollEnabled:YES];
        if (!goDownDirection) {
            table.frame = CGRectMake(viewSender.frame.origin.x, viewSender.frame.origin.y + viewSender.frame.size.height, 0, self.tableHeight);
//            table.layer.shadowOffset = CGSizeMake(0, -1);// 现在不想要阴影
        }else {
            table.frame = CGRectMake(viewSender.frame.origin.x, viewSender.frame.origin.y + viewSender.frame.size.height, self.tableWidth, 0);
//            table.layer.shadowOffset = CGSizeMake(0, 1);// 现在不想要阴影
        }
        [UIView animateWithDuration:0.4 animations:^{
            table.frame = CGRectMake(viewSender.frame.origin.x, viewSender.frame.origin.y + viewSender.frame.size.height, self.tableWidth, self.tableHeight);
        }];

        [self addSubview:table];
    }
    return self;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self hideDropDown:viewSender];
    self.releseMenu();
    NSLog(@"触摸在其他位置");
}
- (void)hideDropDown:(UIView *)view
{
    [UIView animateWithDuration:0.5 animations:^{
        if (!goDownDirection)
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 0, self.height);
        else
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.width, 0);
        table.frame = CGRectMake(0, 0, self.tableWidth, 0);
    }];
    [self removeFromSuperview];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.list count];
}

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    // 下面可以添加行图片背景
//    cell.backgroundView = [[UIImageView alloc] init];
//    UIImage *rowBackground = [UIImage imageNamed:@"sfondo_cella_menu.png"];
//    ((UIImageView *)cell.backgroundView).image = rowBackground;
    
    UIView *rv = [[UIView alloc] init];
//    rv.backgroundColor = [UIColor colorWithRed:75.0/255.0 green:190.0/255.0 blue:215.0/255.0 alpha:1.0];
    cell.backgroundView = rv;
    
    UIView *sv = [[UIView alloc] init];
//    sv.backgroundColor = [UIColor colorWithRed:75.0/255.0 green:180.0/255.0 blue:200.0/255.0 alpha:1.0];
    cell.selectedBackgroundView = sv;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self getCellContentView:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
//        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    if ([self.imgList count] == [self.list count]) {
        cell.textLabel.text =[list objectAtIndex:indexPath.row];
        cell.imageView.image = [imgList objectAtIndex:indexPath.row];
    } else if ([self.imgList count] > [self.list count]) {
        cell.textLabel.text =[list objectAtIndex:indexPath.row];
        if (indexPath.row < [imgList count]) {
            cell.imageView.image = [imgList objectAtIndex:indexPath.row];
        }
    } else if ([self.imgList count] < [self.list count]) {
        cell.textLabel.text =[list objectAtIndex:indexPath.row];
        if (indexPath.row < [imgList count]) {
            cell.imageView.image = [imgList objectAtIndex:indexPath.row];
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self hideDropDown:viewSender];
    self.releseMenu();
    NSLog(@"indexPath.row=%d", indexPath.row);
    if(self.function)
        self.function(indexPath.row);
    
}
@end
