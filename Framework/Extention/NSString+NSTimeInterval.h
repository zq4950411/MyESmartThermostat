//
//  NSString+NSTimeInterval.h
//  CustomVideoPlayer
//
//  Created by penghui on 11-8-17.
//  Copyright 2011 #. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (TimeCategory) 
+ (NSString *)stringWithTime:(NSTimeInterval)time;
- (NSTimeInterval)timeValue;
@end