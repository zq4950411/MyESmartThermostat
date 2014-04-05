//
//  SceneEntity.m
//  MyE
//
//  Created by space on 13-8-23.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "SceneEntity.h"

@implementation SceneEntity

@synthesize sceneId;
@synthesize sceneName;
@synthesize type;

+(NSMutableArray *) scenes:(NSString *) json
{
    NSArray *tempArray = [json JSONValue];
    NSMutableArray *retArray = [NSMutableArray arrayWithCapacity:0];
    
    for (int i = 0; i < tempArray.count; i++)
    {
        NSDictionary *tempDic2 = [tempArray objectAtIndex:i];
        SceneEntity *temp = [[SceneEntity alloc] init];
        
        temp.sceneId = [tempDic2 objectForKey:@"sceneId"];
        temp.sceneName = [tempDic2 objectForKey:@"sceneName"];
        temp.type = [tempDic2 objectForKey:@"type"];
        
        [retArray addObject:temp];
    }
    return retArray;
}

@end
