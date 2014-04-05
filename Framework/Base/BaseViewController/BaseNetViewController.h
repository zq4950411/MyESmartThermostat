//
//  BaseNetViewController.h
//  FinalFantasy
//
//  Created by space bj on 12-4-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"

#import "Services.h"
#import "NetManager.h"

#define  Default_Net_Error_Info @"No Internet Connection"

#define Default_Data_Key @"Data"
#define Default_Error_Key @"Error"
#define Default_ErrorCode_Key @"ErrorCode"

@interface BaseNetViewController : BaseViewController <NetManagerDelegate>
{ 
    
    int currentPage;
    int pageSize;
    int totalNumber;
    
    BOOL isNeedCacheData;
    
    int currentOriention;
}

@property BOOL isNeedCacheData;



-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo;
-(void) netFinish:(id) jsonString withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) url;

-(void) netError:(id) errorMsg withUserInfo:(NSDictionary *) userInfo;
-(void) netError:(id) errorMsg withUserInfo:(NSDictionary *) userInfo andURL:(NSString *) url;

@end
