//
//  NSMutableArray+NSMutableArray_Safe.h
//  明信片
//
//  Created by space bj on 12-12-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Safe)

-(id) safeObjectAtIndex:(int) index;

-(void) safeReplaceObjectAtIndex:(int) index withObject:(id) object;
-(void) safeRemovetAtIndex:(int) index;

@end
