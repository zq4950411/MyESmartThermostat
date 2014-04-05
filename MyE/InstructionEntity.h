//
//  InstructionEntity.h
//  MyE
//
//  Created by space on 13-8-20.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseObject.h"

@interface InstructionEntity : BaseObject
{
    NSString *instructionId;
    NSString *name;
    NSString *sortId;
    NSString *status;
    NSString *type;
}

@property (nonatomic,strong) NSString *instructionId;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *sortId;
@property (nonatomic,strong) NSString *status;
@property (nonatomic,strong) NSString *type;

+(NSMutableArray *) instructions:(id) json;

@end
