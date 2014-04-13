//
//  DictionaryTableViewViewController.m
//  MyE
//
//  Created by space on 13-8-9.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "DictionaryTableViewViewController.h"
#import "AddSmartUpTableViewView.h"

#import "MyEHouseData.h"


@implementation DictionaryTableViewViewController

@synthesize type;
@synthesize smartup;
@synthesize delegate;

-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:URL_FOR_FIND_DEVICE].location != NSNotFound)
    {
        NSString *temp = (NSString *)jsonString;
        NSDictionary *tempDic = [temp JSONValue];
        
        NSArray *tempArray = nil;
        if (type == 0)
        {
            tempArray = [tempDic objectForKey:@"typeList"];
        }
        else if (type == 1)
        {
            tempArray = [tempDic objectForKey:@"terminalList"];
        }
        else if (type == 2)
        {
            tempArray = [tempDic objectForKey:@"locationList"];
        }
        
        if ([tempArray isKindOfClass:[NSArray class]])
        {
            self.datas = [NSMutableArray arrayWithArray:tempArray];
            [self.tableView reloadData];
        }
    }
}

-(void) netError:(id)errorMsg withUserInfo:(NSDictionary *)userInfo andURL:(NSString *) u
{
    if ([u rangeOfString:URL_FOR_FIND_DEVICE].location != NSNotFound)
    {
        
    }
}

-(void) sendGetDatas
{
    self.isShowLoading = YES;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:[NSString stringWithFormat:@"%d",MainDelegate.houseData.houseId] forKey:@"houseId"];
    [params setObject:@"addDevice" forKey:@"action"];
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:params,REQUET_PARAMS, nil];
    
    [[NetManager sharedManager] requestWithURL:GetRequst(URL_FOR_FIND_DEVICE)
                                      delegate:self
                                  withUserInfo:dic];
}



-(id) initWithType:(int) t andDatas:(NSMutableArray *) d
{
    if (self = [super init])
    {
        self.datas = d;
        self.type = t;
    }
    
    return self;
}


-(id) initWithDatas:(NSMutableArray *) d
{
    if (self = [super init])
    {
        self.datas = d;
    }
    
    return self;
}

-(id) initWithType:(int) t
{
    if (self = [super init])
    {
        self.type = t;
    }
    
    return self;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas.count;
}

-(UITableViewCell *) tableView:(UITableView *) tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSDictionary *temp = (NSDictionary *)[self.datas objectAtIndex:indexPath.row];
    if (type == 0)
    {
        cell.textLabel.text = [temp objectForKey:@"typeName"];
    }
    else if (type == 1)
    {
        cell.textLabel.text = [temp objectForKey:@"aliasName"];        
    }
    else if (type == 2)
    {
        cell.textLabel.text = [temp objectForKey:@"locationName"];
    }
    else
    {
        cell.textLabel.text = [temp objectForKey:@"zoneName"];
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = (NSDictionary *)[self.datas objectAtIndex:indexPath.row];
    
    if ([delegate respondsToSelector:@selector(rowDidSelected:)])
    {
        [delegate rowDidSelected:dic];
    }
    
    if ([delegate respondsToSelector:@selector(rowDidSelected:withType:)])
    {
        [delegate rowDidSelected:dic withType:self.type];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if (self.datas == nil)
    {
        [self sendGetDatas];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
