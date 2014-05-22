//
//  MyEPeriodData.h
//  MyE
//
//  Created by Ye Yuan on 2/21/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEPeriodData : NSObject
{
    UIColor *_color;
    NSInteger _stid;
    NSInteger _etid;
    float _cooling;
    float _heating;
    NSString *_hold; // Weekly Schedule 中此字段无用
    NSString *_text; 
    NSString *_modeid; // Today Schedule 中此字段无用
}
@property (retain, nonatomic) UIColor *color;
@property (nonatomic) NSInteger stid;
@property (nonatomic) NSInteger etid;
@property (nonatomic) float cooling;
@property (nonatomic) float heating;
@property (retain, nonatomic) NSString *hold; // Weekly Schedule 中此字段无用
@property (retain, nonatomic) NSString *text; 
@property (retain, nonatomic) NSString *modeid; // Today Schedule 中此字段无用

@end
