//
//  Sequential.h
//  MyE
//
//  Created by space on 13-8-26.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseObject.h"

@interface Sequential : BaseObject
{
    NSString *seqName;
    NSString *locationId;
    
    NSString *startTime;
    NSString *precondition;
    NSString *weather_temperature;
    
    NSArray *repeatDays;
    NSMutableArray *sequentialOrder;
    NSArray *locationList;
}

@property (nonatomic,strong) NSString *seqName;
@property (nonatomic,strong) NSString *locationId;

@property (nonatomic,strong) NSString *startTime;
@property (nonatomic,strong) NSString *precondition;
@property (nonatomic,strong) NSString *weather_temperature;

@property (nonatomic,strong) NSArray *repeatDays;
@property (nonatomic,strong) NSMutableArray *sequentialOrder;
@property (nonatomic,strong) NSArray *locationList;

+(Sequential *) getSequential:(id) json;

@end
