//  NSDictionary+JSONNSNull.h
//
//  Created by Matthew McFarling on 12/7/12.
//  Copyright (c) 2012 Matthew McFarling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSONNSNull)

- (id)valueForKeyPathNotNull:(NSString *)path;

@end