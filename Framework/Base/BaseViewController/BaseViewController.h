//
//  BaseViewController.h
//  FinalFantasy
//
//  Created by space bj on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum 
{
    UIPresentUsePush,
    UIPresentUsePresent
} UIPresentUseType;


@interface BaseViewController : UIViewController
{
    NSString *titleText;
    
    BOOL isShowLoading;
    BOOL isLoadingData;
    BOOL isEnterBackground;//是否是不在显示
    
    NSOperationQueue *queue;
    
    UIPresentUseType presentType;
    
    UIViewController *parentVC;
    
    UIView *loadingView;
    
    BOOL isFirstLaunch;
    BOOL isNeedRefresh;
}

@property BOOL isShowLoading;
@property BOOL isLoadingData;
@property BOOL isEnterBackground;
@property BOOL isNeedRefresh;

@property (nonatomic,retain) NSString *titleText;

@property (nonatomic,retain) NSOperationQueue *queue;
@property (nonatomic,assign) UIViewController *parentVC;

@property UIPresentUseType presentType;


#pragma 前往个人主页
-(void) goToUserProfile:(UIButton *) sender;

-(void) addLoadingView:(UIView *) parentView;

-(void) removeLoadingView:(UIView *) parentView;

-(void) initLeftButtonItemWithTitle:(NSString *) title atTarget:(id) target andSelector:(SEL) selctor;
-(void) initRightButtonItemWithTitle:(NSString *) title atTarget:(id) target andSelector:(SEL) selctor;
-(void) initWithCustomView:(UIView *) customView type:(int) type;

-(void) leftButtonItemClick;
//返回按钮回调函数
-(void) leftButtonItemClickBackCall;

//设置导航栏标题
-(void) setTitleLabelText:(NSString *) text;

-(void) showLoadViewWithMsg:(NSString *) msg;
-(void) showInfoViewWithMsg:(NSString *) msg;
-(void) hideLoading;

//不在前端显示
-(void) enterBackgroundAction;
//在前端显示
-(void) enterForegroundAction;

//后台执行任务
-(void) executeTaskInBackground;

//开始执行任务 重写
//-(void) executeTask;

//任务执行  重写
//-(void) executeEndTask;

@end
