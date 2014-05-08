//
//  UNRegistHouseViewController.h
//  MyE
//
//  Created by space on 13-8-31.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseTableViewController.h"

@protocol HouseDelegate <NSObject>

-(void) houseDidSelected:(NSDictionary *) dic;

@end

@interface UNRegistHouseViewController : BaseTableViewController <UITableViewDataSource,UITableViewDelegate>
{
    __weak id<HouseDelegate> delegate;
}

@property (nonatomic,weak) id<HouseDelegate> delegate;

@end
