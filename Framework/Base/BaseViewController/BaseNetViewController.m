//
//  BaseNetViewController.m
//  FinalFantasy
//
//  Created by space bj on 12-4-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "BaseNetViewController.h"
#import "Utils.h"

#import "NSMutableDictionary+Safe.h"

@implementation BaseNetViewController

@synthesize isNeedCacheData;


-(NSString *) validationString:(id) data
{
    NSString *jsonString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    if ([@"" isEqualToString:jsonString])
    {
        //NSLog(@"blank string");
        if (self.isShowLoading)
        {
            [SVProgressHUD showErrorWithStatus:@"server recive blank data"];
        }
        
        return nil;
    }
    
    return jsonString;
}

#pragma -
#pragma 请求开始处理

-(void) requestStartforUrl:(NSString *) url
{
    if (isShowLoading) 
    {
        [self showLoadViewWithMsg:@""];
    }
}

#pragma -
#pragma 请求结束

-(void) requestCancelForUrl:(NSString *) url
{
    [self hideLoading];
}

//- (void) requestDidFinishWithData:(id) retData userInfo:(NSDictionary *) userInfo
//{
//    NSDictionary *dic = [self validationString:retData];
//    if (dic) 
//    {
//        if ([self respondsToSelector:@selector(netFinish:withUserInfo:)])
//        {
//            if (dic == nil)
//            {
//                [self netFinish:nil withUserInfo:userInfo];
//            }
//            
//            else
//            {
//                [self netFinish:dic withUserInfo:userInfo];
//            }
//        }
//        
//        [HUD hide:YES afterDelay:0.5f];
//    }
//    else
//    {
//        if ([self respondsToSelector:@selector(netError:withUserInfo:)])
//        {
//            [self netError:nil withUserInfo:nil];
//        }
//    }
//}

-(void) requestDidFinishWithData:(id) retData userInfo:(NSDictionary *) userInfo forUrl:(NSString *) url
{
    if (self.isShowLoading) 
    {
        [self hideLoading];
    }
    
    NSString *dic = [self validationString:retData];
    if ([self respondsToSelector:@selector(netFinish:withUserInfo:)])
    {
        [self netFinish:dic withUserInfo:userInfo];
    }
    else if ([self respondsToSelector:@selector(netFinish:withUserInfo:andURL:)])
    {
        [self netFinish:dic withUserInfo:userInfo andURL:url];
    }
}

//-(void) requestFailWithError:(NSError *)error userInfo:(NSDictionary *)userInfo
//{
//    NSString *errorMsg = [NSString stringWithFormat:@"访问服务器出错,原因%@",error.localizedDescription];
//    
//    if (YES) 
//    {
//        if (HUD) 
//        {
//            [HUD hide:YES afterDelay:0.0f];
//        }
//        
//        [self showInfoViewWithMsg:@"亲,网络不稳定哟!"];
//    }
//    
//    if ([self respondsToSelector:@selector(netError:withUserInfo:)])
//    {
//        [self netError:errorMsg withUserInfo:userInfo];
//    }
//}

-(void) requestFailWithError:(NSError *) error userInfo:(NSDictionary *)userInfo forUrl:(NSString *)url
{
    NSString *errorString = [error.userInfo objectForKey:@"NSLocalizedDescription"];
    if (self.isShowLoading) 
    {
        [SVProgressHUD showErrorWithStatus:errorString];
        //[SVProgressHUD showErrorWithStatus:@"Network error!"];
    }
    
    if ([self respondsToSelector:@selector(netError:withUserInfo:)])
    {
        [self netError:Default_Net_Error_Info withUserInfo:userInfo];
    }
    else if ([self respondsToSelector:@selector(netError:withUserInfo:andURL:)])
    {
        [self netError:Default_Net_Error_Info withUserInfo:userInfo andURL:url];
    }
}



#pragma -
#pragma 重写以下方法

//-(void) netFinish:(NSDictionary *) jsonString withUserInfo:(NSDictionary *) userInfo
//{
//    
//}
//
//-(void) netFinish:(NSDictionary *) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) url
//{
//    
//}
//
//-(void) netError:(id) errorMsg withUserInfo:(NSDictionary *) userInfo
//{
//    
//}
//
//-(void) netError:(id) errorMsg withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) url
//{
//    
//}


-(void) leftButtonItemClickBackCall
{
    [[NetManager sharedManager] cancelForDelegate:self];
}


-(void) viewDidLoad
{
    [super viewDidLoad];
    currentPage = 1;
}

-(void) dealloc
{    
    [super dealloc];
}

@end
