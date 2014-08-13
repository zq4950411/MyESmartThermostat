//
//  MyEInstruction.m
//  MyE
//
//  Created by 翟强 on 14-4-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEInstructions.h"
#import "SBJson.h"
@implementation MyEInstructions
-(MyEInstructions *)initWithJSONString:(NSString *)string{
    NSDictionary *dic = [string JSONValue];
    MyEInstructions *instructions = [[MyEInstructions alloc] initWithDic:dic];
    return instructions;
}
-(MyEInstructions *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.templateList = [NSMutableArray array];
        self.customList = [NSMutableArray array];
        for (NSDictionary *d in dic[@"instructionTemplateList"]) {
            [self.templateList addObject:[[MyEInstruction alloc] initWithDic:d]];
        }
        for (NSDictionary *d in dic[@"customOrderList"]) {
            [self.customList addObject:[[MyEInstruction alloc] initWithDic:d]];
        }
        for (int i=0;i < 40; i++) {
            [self.customList addObject:[[MyEInstruction alloc] init]];
        }
        return self;
    }
    return nil;
}
@end

@implementation MyEInstruction
-(id)init{
    if (self = [super init]) {
        self.instructionId = -1;  //由接口决定,表示新学习的，(没有则为-1)
        self.type = 2;  //由接口决定
        self.name = @"";
        self.sortId = 0;
        self.status = 0;
        return self;
    }
    return nil;
}

-(MyEInstruction *)initWithDic:(NSDictionary *)dic{
    if (self = [super init]) {
        self.instructionId = [dic[@"instructionId"] intValue];
        self.type = [dic[@"type"] intValue];
        self.name = dic[@"name"]?dic[@"name"]:dic[@"instructionName"];
        if (dic[@"sortId"]) {
            self.sortId = [dic[@"sortId"] intValue];
        }
        self.status = dic[@"status"] == [NSNull null]?0:[dic[@"status"] intValue];
        return self;
    }
    return nil;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"name:%@  instructionId:%i status:%i  type:%i",self.name,self.instructionId,self.status,self.type];
}
@end
