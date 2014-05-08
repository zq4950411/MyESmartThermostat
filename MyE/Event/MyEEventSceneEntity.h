//
//  SceneEntity.h
//  MyE
//
//  Created by space on 13-8-23.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseObject.h"

@interface MyEEventSceneEntity : BaseObject
{
    NSString *sceneName;
    NSString *sceneId;
    NSString *type;//0:不可应用 1:可应用 2:全关场景,类型为0时不能应用场景，apply按钮禁用
}

@property (nonatomic,strong) NSString *sceneName;
@property (nonatomic,strong) NSString *sceneId;
@property (nonatomic,strong) NSString *type;

+(NSMutableArray *) scenes:(NSString *) json;

@end
