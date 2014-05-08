//
//  MyEInstruction.h
//  MyE
//
//  Created by 翟强 on 14-4-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEInstructions : NSObject

@property (nonatomic, strong) NSMutableArray *templateList;
@property (nonatomic, strong) NSMutableArray *customList;
-(MyEInstructions *)initWithJSONString:(NSString *)string;
-(MyEInstructions *)initWithDic:(NSDictionary *)dic;

@end


@interface MyEInstruction : NSObject

@property (nonatomic) NSInteger instructionId;
@property (nonatomic) NSInteger type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSInteger sortId;
@property (nonatomic) NSInteger status;

-(MyEInstruction *)initWithDic:(NSDictionary *)dic;
@end