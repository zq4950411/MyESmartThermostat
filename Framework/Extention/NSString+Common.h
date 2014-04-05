//
//  NSString+Common.h
//  MyE
//
//  Created by space on 13-8-19.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Common)

-(BOOL) nilValue;
-(NSString *) nonBlankString;
-(NSString *) intStringToWeekString;
-(BOOL) isBlank;


-(NSString *) conditiontoString:(int) i;
-(int) stringToCondition:(NSString *) string;
+(NSString *) errorInfo:(NSString *) error;
-(BOOL) isChannel;
-(NSString *) safeReplaceString:(NSString *) s1 atIndex:(int) i;

@end
