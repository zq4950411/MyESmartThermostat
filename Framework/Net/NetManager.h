//
//  NetManager.h
//  DouMiJie
//
//  Created by space bj on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSNet.h"

@protocol NetManagerDelegate <NSObject>

@optional

-(void) requestStartforUrl:(NSString *) url;
-(void) requestCancelForUrl:(NSString *) url;

- (void) requestDidFinishWithData:(id) retData userInfo:(NSDictionary *) userInfo;
- (void) requestDidFinishWithData:(id) retData userInfo:(NSDictionary *) userInfo forUrl:(NSString *) url;

- (void) requestFailWithError:(NSError *) error userInfo:(NSDictionary *) userInfo;
- (void) requestFailWithError:(NSError *) error userInfo:(NSDictionary *) userInfo forUrl:(NSString *) url;

@end;

@interface NetManager : NSObject <WSNetDelegate>
{
    NSMutableArray *requestDelegates;
    NSMutableArray *requests;
    
    NSMutableArray *failedURLs;
    NSMutableArray *contexts;
    
    NSMutableDictionary *requstForURL;
}

+ (id)sharedManager;

- (void) requestWithURL:(NSString *) urlString delegate:(id<NetManagerDelegate>) delegate;
- (void) requestWithURL:(NSString *) urlString delegate:(id<NetManagerDelegate>) delegate withUserInfo:(NSDictionary *) userInfo;

#if NS_BLOCKS_AVAILABLE
- (void) requestWithURL:(NSString *) url delegate:(id)delegate success:(void (^)(id data)) success failure:(void (^)(NSError *error)) failure;
#endif

- (void)cancelForDelegate:(id<NetManagerDelegate>)delegate;

@end
