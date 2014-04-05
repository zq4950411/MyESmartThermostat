//
//  AddSmartUpTableViewView.h
//  MyE
//
//  Created by space on 13-8-9.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseTableViewController.h"
#import "DictionaryTableViewViewController.h"
#import "LocationViewController.h"

@class CommonCell;
@class SmartUp;

@interface AddSmartUpTableViewView : BaseTableViewController <UITableViewDataSource,UITableViewDelegate,DictionaryDelegate,LocationDelegate>
{
    NSDictionary *typeDic;
    NSDictionary *locationDic;
    NSDictionary *tDic;
    
    SmartUp *smartup;
    
    CommonCell *typeCell;
    
    int type;
    
    NSMutableDictionary *dataDic;
}

@property (nonatomic,strong) SmartUp *smartup;

@property (nonatomic,strong) NSDictionary *typeDic;
@property (nonatomic,strong) NSDictionary *locationDic;
@property (nonatomic,strong) NSDictionary *tDic;

@property (nonatomic,strong) NSMutableDictionary *dataDic;

@property (nonatomic,strong) CommonCell *typeCell;

-(void) reloadWithDic:(NSDictionary *) dic;

@end
