//
//  MyEPeriodData.m
//  MyE
//
//  Created by Ye Yuan on 2/21/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEPeriodData.h"

@implementation MyEPeriodData

@synthesize  color = _color, stid = _stid, etid = _etid, cooling = _cooling, heating = _heating;
@synthesize hold = _hold, text = _text, modeid = _modeid;

- (id)init {
    if (self = [super init]) {
        _color = [UIColor blueColor];
        _stid = 0;
        _etid = 10;
        _cooling = 77;
        _heating = 66;
        _hold = @"none";
        _text = @"Period1";
        _modeid = @"13800";
        return self;
    }
    return nil;
}

@end
