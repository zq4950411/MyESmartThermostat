//
//  MyEEventInfo.h
//  MyE
//
//  Created by 翟强 on 14-5-23.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEEventInfo : NSObject
@property (nonatomic, copy) NSString *sceneName;
@property (nonatomic, assign) NSInteger sceneId;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger timeTriggerFlag;  //时间触发开关
@property (nonatomic, assign) NSInteger conditionTriggerFlag; //条件触发开关

-(MyEEventInfo *)initWithDictionary:(NSDictionary *)dic;
@end

@interface MyEEvents : NSObject
@property (nonatomic, strong) NSMutableArray *scenes;
-(MyEEvents *)initWithJsonString:(NSString *)string;
-(MyEEvents *)initWithArray:(NSArray *)array;
@end