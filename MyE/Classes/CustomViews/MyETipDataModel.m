//
//  MyETipDataModel.m
//  MyE
//
//  Created by Ye Yuan on 6/26/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyETipDataModel.h"

@implementation MyETipDataModel
@synthesize key = _key, title = _title, message = _message;

+(MyETipDataModel *)tipDataModelWithKey:(NSString *)key title:(NSString *)title message:(NSString *)message {
    MyETipDataModel *tdm = [[MyETipDataModel alloc] init];
    tdm.key = key;
    tdm.title = title;
    tdm.message = message;
    return tdm;
}
@end
