//
//  LocationViewController.h
//  MyE
//
//  Created by space on 13-8-21.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseTableViewController.h"

@protocol LocationDelegate <NSObject>

@optional
-(void) locationDidSelect:(NSDictionary *) dic;
-(void) refreshLocalList:(NSMutableArray *) list;
-(void) refreshLocation:(NSDictionary *) dic;

@end

@class LocationInPutView;

@interface LocationViewController : BaseTableViewController <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
{
    LocationInPutView *locationView;
    
    int currentFoucsIndex;
    int currentDeleteIndex;
    
    int actionType;
    
    __weak id<LocationDelegate> delegate;
}

@property (nonatomic,strong) LocationInPutView *locationView;
@property (nonatomic,weak) id<LocationDelegate> delegate;

-(id) initWithLocalList:(NSArray *) locationList;

@end
