//
//  WSNet.m
//  WisTeam
//
//  Created by Mark on 11-2-9.
//  Copyright 2011 Wisdomin Co., Ltd. All rights reserved.
//

#import "WSNet.h"

@implementation WSNet

@synthesize delegate;
@synthesize requestURLString;
@synthesize userInfo;

-(id) initWithDelegate:(id<WSNetDelegate>) d
{
    self.delegate = d;
    return [self initWithDelegate:d withUserInfo:nil];
}

-(id) initWithDelegate:(id<WSNetDelegate>) d withUserInfo:(NSDictionary *) userDic
{
   	if (self == [super init]) 
	{
		self.delegate = d;
        self.userInfo = userDic;
	}
	
	return self; 
}

#pragma -
#pragma 发送请求

-(NSString *) sendFormAsyRequst:(NSString *) urlString
{    
    NSDictionary *dic = [self.userInfo objectForKey:REQUET_PARAMS];
    NSMutableDictionary *params = nil;
    
    if (dic != nil) 
    {
        params = [NSMutableDictionary dictionaryWithDictionary:dic];
    }
    else
    {
        params = [NSMutableDictionary dictionary];
        

    }    
//	NSString *pageSize = [params objectForKey:@"PageSize"];
//    if (pageSize == nil)
//    {
//        [params setObject:@"20" forKey:@"PageSize"];
//    }
//    
//	NSString *page = [dic objectForKey:@"Page"];
//    if (page == nil) 
//    {
//        [params setObject:@"1" forKey:@"Page"];
//    }
	
    NSMutableString *sb = [NSMutableString stringWithString:urlString];
    
    //urlString  = [urlString stringByAppendingFormat:@"?PageSize=%@&Page=%@",pageSize,page];
    //[sb appendFormat:@"&PageSize=%@&Page=%@",pageSize,page];
	//[sb appendFormat:@"&date=%@",[Utils getNowDate]];
	//[sb appendFormat:@"&md5=%@",[sb md5]];
	
    self.requestURLString = sb;
    
    request = [[ASIFormDataRequest requestWithURL:[NSURL URLWithString:sb]] retain];
    
    [request setTimeOutSeconds:15.0];
    [request setAllowCompressedResponse:NO];
    [request setUseCookiePersistence:YES];
	[request setRequestMethod:@"POST"];
	request.delegate = self;
    [(ASIFormDataRequest *)request setPostFormat:ASIMultipartFormDataPostFormat];
	
	id value = nil;
	
	if (params !=nil)
    {
		NSArray *keys = [params allKeys];
		
		NSString *key = nil;	
		
		for (int i =0; i<[keys count]; i++) 
        {
			key = [keys objectAtIndex:i];
			value = [params objectForKey:key];
			
			if ([value isKindOfClass:[NSData class]]) 
			{
				[(ASIFormDataRequest *)request setData:value forKey:key];
			}
			
			else
			{
				[(ASIFormDataRequest *)request setPostValue:value forKey:key];
                NSLog(@"提交数据Key:%@ , Value: %@", key,value);
			}
		}
	}
	[request startAsynchronous];
	
	return nil;
}


#pragma -
#pragma ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *) request
{		
	if ([delegate respondsToSelector:@selector(wsNetRequestStart:)]) 
	{
		[delegate wsNetRequestStart:self];
	}
}

- (void) requestFinished:(ASIHTTPRequest *) asiRequest
{
//    NSString *retString = [request responseString];
//    CLog(@"异步返回数据%@",retString);

    if ([delegate respondsToSelector:@selector(wsNetRequest:didFinishedWithData:)]) 
    {
        [delegate wsNetRequest:self didFinishedWithData:asiRequest.responseData];
    }
}

- (void)requestFailed:(ASIHTTPRequest *) asiHTTPRequest
{		
	NSError *error = [asiHTTPRequest error];
    if ([delegate respondsToSelector:@selector(wsNetRequest:error:)]) 
    {
        [delegate wsNetRequest:self error:error];
    }
}

//-(BOOL) showHttpStatusCode:(int) code
//{
//	NSLog(@"状态码：%d",code);
//	if (code == 0) 
//	{
//		if (isShowError) 
//		{
//			[Utils alertWithMessage:@"网络未连接或者超时"];		
//		}
//		return FALSE;
//	}
//	else if (code == 404) 
//	{
//		if (isShowError) 
//		{
//			[Utils alertWithMessage:@"未找到服务"];
//		}
//		
//		return FALSE;
//	}	
//	else if(code >= 500)
//	{
//		if (isShowError) 
//		{
//			[Utils alertWithMessage:@"服务器错误"];
//		}
//		
//		return NO;
//	}
//	return YES;
//}

#pragma -
#pragma 请求取消

-(void) cancelRequest
{
    request.delegate = nil;
    [request cancel];
    
//    if ([delegate respondsToSelector:@selector(wsNetRequestCancel:)]) 
//    {
//        [delegate wsNetRequestCancel:self];
//    }
}

-(void) dealloc
{
	CLog(@"释放WSNET内存");
    [request release];
    request = nil;
    
	[requestURLString release];
    [userInfo release];
	[super dealloc];
}


@end
