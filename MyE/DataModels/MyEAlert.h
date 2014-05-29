//
//  MyEAlert.h
//  MyE
//
//  Created by Ye Yuan on 5/28/14.
//  Copyright (c) 2014 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyEAlert : NSObject<NSCopying>
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *content;
@property(nonatomic) NSInteger ID;
@property(nonatomic) NSInteger new_flag;
@property(nonatomic, strong) NSString *publish_date;


-(MyEAlert *)initWithString:(NSString *)string;
-(MyEAlert *)initWithDictionary:(NSDictionary *)dic;
-(NSDictionary *)JSONDictionary;
@end
