//
//  NetManager.m
//  DouMiJie
//
//  Created by space bj on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NetManager.h"

#if NS_BLOCKS_AVAILABLE

typedef void(^SuccessBlock)(id retData);
typedef void(^FailureBlock)(NSError *error);

@interface NetManager ()

@property (nonatomic, copy) SuccessBlock successBlock;
@property (nonatomic, copy) FailureBlock failureBlock;

@end
#endif

static NetManager *instance;

@implementation NetManager

#if NS_BLOCKS_AVAILABLE
@synthesize successBlock;
@synthesize failureBlock;
#endif

+ (id)sharedManager
{
    NSLog(@"instance is %@",instance);
    if (instance == nil)
    {
        instance = [[NetManager alloc] init];
    }
    NSLog(@"instance is %@",instance);
    return instance;
}

- (id)init
{
    if ((self = [super init]))
    {
        requestDelegates = [[NSMutableArray alloc] init];
        requests = [[NSMutableArray alloc] init];
        
        contexts = [[NSMutableArray alloc] init];
        
        requstForURL = [[NSMutableDictionary alloc] init];
        failedURLs = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) requestWithURL:(NSString *) url delegate:(id<NetManagerDelegate>) delegate withUserInfo:(NSDictionary *) userInfo
{
    NSLog(@"%@\n%@\n%@",url,delegate,userInfo);
    WSNet *request = [[WSNet alloc] initWithDelegate:self];
    
    request.userInfo = userInfo;
    [request sendFormAsyRequst:url];
    
    [requestDelegates addObject:delegate];
    [requests addObject:request];
}

- (void) requestWithURL:(NSString *) url delegate:(id<NetManagerDelegate>) delegate
{
    [self requestWithURL:url delegate:delegate withUserInfo:nil];
}

#if NS_BLOCKS_AVAILABLE
- (void) requestWithURL:(NSString *) url delegate:(id)delegate success:(void (^)(id data)) success failure:(void (^)(NSError *error)) failure
{
    self.successBlock = success;
    self.failureBlock = failure;
    
    [self requestWithURL:url delegate:delegate];
}
#endif

- (void)cancelForDelegate:(id<NetManagerDelegate>) delegate
{
    NSUInteger idx;
    
    while ((idx = [requestDelegates indexOfObjectIdenticalTo:delegate]) != NSNotFound)
    {
        WSNet *requestNet = [requests objectAtIndex:idx];
        
//        if (![requests containsObject:requestNet])
//        {
//            requestNet.delegate = nil;
//            [requestNet cancelRequest];
//        }
        [requestNet cancelRequest];
        requestNet.delegate = nil;
        
        [requestDelegates removeObjectAtIndex:idx];
        [requests removeObjectAtIndex:idx];
    }
}


//请求开始
-(void) wsNetRequestStart:(WSNet *) wsRequest
{
    for (NSInteger idx = (NSInteger)[requests count] - 1; idx >= 0; idx--)
    {
        NSUInteger uidx = (NSUInteger)idx;
        WSNet *wsRequest1 = (WSNet *)[requests objectAtIndex:uidx];
        
        if (wsRequest == wsRequest1)
        {
            id<NetManagerDelegate> delegate = [requestDelegates objectAtIndex:uidx];
          
            if ([delegate respondsToSelector:@selector(requestStartforUrl:)]) 
            {
                [delegate requestStartforUrl:wsRequest.requestURLString];
            }
            
            break;
        }
    }
}



//请求取消
-(void) wsNetRequestCancel:(WSNet *) wsRequest
{
    for (NSInteger idx = (NSInteger)[requests count] - 1; idx >= 0; idx--)
    {
        NSUInteger uidx = (NSUInteger)idx;
        WSNet *wsRequest1 = (WSNet *)[requests objectAtIndex:uidx];
        
        if (wsRequest == wsRequest1)
        {
            id<NetManagerDelegate> delegate = [requestDelegates objectAtIndex:uidx];
            if ([delegate respondsToSelector:@selector(requestCancelForUrl:)])
            {
                [delegate requestCancelForUrl:wsRequest.requestURLString];
            }
            
            break;
        }
    }
}


//请求完成
- (void) wsNetRequest:(WSNet *) wsRequest didFinishedWithData:(id) retData
{
    // Notify all the downloadDelegates with this downloader
    for (NSInteger idx = (NSInteger)[requests count] - 1; idx >= 0; idx--)
    {
        NSUInteger uidx = (NSUInteger)idx;
        WSNet *wsRequest1 = (WSNet *)[requests objectAtIndex:uidx];
        
        if (wsRequest == wsRequest1)
        {
            id<NetManagerDelegate> delegate = [requestDelegates objectAtIndex:uidx];
//            if (retData)
//            {
////                if ([delegate respondsToSelector:@selector(requestDidFinishWithData:userInfo:)])
////                {
////                    [delegate requestDidFinishWithData:retData userInfo:wsRequest.userInfo];
////                }
//                if ([delegate respondsToSelector:@selector(requestDidFinishWithData:userInfo:forUrl:)])
//                {
//                    [delegate requestDidFinishWithData:retData userInfo:wsRequest.userInfo forUrl:wsRequest.requestURLString];
//                }
//#if NS_BLOCKS_AVAILABLE
//                if (self.successBlock)
//                {
//                    self.successBlock(retData);
//                }
//            }
//#endif
            if ([delegate respondsToSelector:@selector(requestDidFinishWithData:userInfo:forUrl:)])
            {
                [delegate requestDidFinishWithData:retData userInfo:wsRequest.userInfo forUrl:wsRequest.requestURLString];
            }
#if NS_BLOCKS_AVAILABLE
            if (self.successBlock)
            {
                self.successBlock(retData);
            }
#endif

            [requests removeObjectAtIndex:uidx];
            [requestDelegates removeObjectAtIndex:uidx];
            
            break;
        }
    }
}



//请求失败
- (void) wsNetRequest:(WSNet *) wsRequest error:(NSError *) error
{
    // Notify all the downloadDelegates with this downloader
    for (NSInteger idx = (NSInteger)[requests count] - 1; idx >= 0; idx--)
    {
        NSUInteger uidx = (NSUInteger)idx;
        WSNet *wsRequest1 = (WSNet *)[requests objectAtIndex:uidx];
        
        if (wsRequest == wsRequest1)
        {
            id<NetManagerDelegate> delegate = [requestDelegates objectAtIndex:uidx];
            
//            if ([delegate respondsToSelector:@selector(requestFailWithError:userInfo:)])
//            {
//                [delegate requestFailWithError:error userInfo:wsRequest.userInfo];
//            }
            if ([delegate respondsToSelector:@selector(requestFailWithError:userInfo:forUrl:)])
            {
                [delegate requestFailWithError:error userInfo:wsRequest.userInfo forUrl:wsRequest.requestURLString];
            }
#if NS_BLOCKS_AVAILABLE
            if (self.failureBlock)
            {
                self.failureBlock(error);
            }
#endif
            
            break;
        }
    }
}


@end
