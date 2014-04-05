//
//  InstructionEntity.m
//  MyE
//
//  Created by space on 13-8-20.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "InstructionEntity.h"

@implementation InstructionEntity

@synthesize instructionId;
@synthesize name;
@synthesize sortId;
@synthesize status;
@synthesize type;

+(NSMutableArray *) instructions:(id) json
{
    NSArray *array = (NSArray *)[(NSString *)json JSONValue];
    if ([array isKindOfClass:[NSArray class]])
    {
        NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < array.count;i++)
        {
            NSDictionary *tempDic = (NSDictionary *)[array objectAtIndex:i];
            
            InstructionEntity *temp = [[InstructionEntity alloc] init];
            
            temp.instructionId = [tempDic valueToStringForKey:@"instructionId"];
            temp.name = [tempDic valueForKeyPathNotNull:@"name"];
            temp.sortId = [tempDic valueToStringForKey:@"sortId"];
            temp.status = [tempDic valueToStringForKey:@"status"];
            temp.type = [tempDic valueToStringForKey:@"type"];
            
            [retArray addObject:temp];
        }
        return retArray;
    }
    else
    {
        return nil;
    }
}

- (NSComparisonResult) compareSort:(InstructionEntity *) entity
{
	return [self.sortId compare:entity.sortId];
}

@end
