//
//  MyEInstruction.m
//  MyE
//
//  Created by 翟强 on 14-4-24.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEInstructions.h"

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
        return self;
    }
    return nil;
}
@end

@implementation MyEInstruction
-(id)init{
    if (self = [super init]) {
        self.instructionId = 0;
        self.type = 0;
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
        self.name = dic[@"name"];
        if (dic[@"sortId"]) {
            self.sortId = [dic[@"sortId"] intValue];
        }
        self.status = dic[@"status"] == [NSNull null]?0:[dic[@"status"] intValue];
        return self;
    }
    return nil;
}

@end
