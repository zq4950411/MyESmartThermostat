//
//  NSMutableDictionary_NSMutableDictionary1_Safe.h
//  明信片
//
//  Created by space bj on 12-11-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSMutableDictionary (Safe)

- (void) safeSetObject:(id)anObject forKey:(id)aKey;

@end
