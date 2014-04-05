//
//  DictionaryTableViewViewController.h
//  MyE
//
//  Created by space on 13-8-9.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseTableViewController.h"

#import "SmartUp.h"

@protocol DictionaryDelegate <NSObject>

@optional
-(void) rowDidSelected:(NSDictionary *) dic;
-(void) rowDidSelected:(NSDictionary *) dic withType:(int) t;

@end

@interface DictionaryTableViewViewController : BaseTableViewController <UITableViewDataSource,UITableViewDelegate>
{
    int type;
    __weak SmartUp *smartup;
    __weak id<DictionaryDelegate> delegate;
}

@property int type;
@property (nonatomic,weak) SmartUp *smartup;
@property (nonatomic,weak) id<DictionaryDelegate> delegate;


-(id) initWithDatas:(NSMutableArray *) datas;
-(id) initWithType:(int) type;
-(id) initWithType:(int)type andDatas:(NSMutableArray *) datas;

@end
