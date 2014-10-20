//
//  MyEUniversal.h
//  MyEHomeCN2
//
//  Created by 翟强 on 14-2-14.
//  Copyright (c) 2014年 My Energy Domain Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyELoginViewController.h"

@interface MyEUniversal : NSObject<UIActionSheetDelegate>

+(void)doThisWhenUserLogOutWithVC:(UIViewController*)vc;

+(void)doThisToCloseKeyboardWithVC:(UIViewController*)vc;

+(void)dothisWhenTableViewIsEmptyWithMessage:(NSString *)message andFrame:(CGRect)frame andVC:(UIViewController *)vc;
+(void)doThisWhenNeedTellUserToSaveWhenExitWithLeftBtnAction:(void (^)(void))lAction andRightBtnAction:(void (^)(void))rAction;

+(BOOL)requstString:(NSString *)mainString hasURLString:(NSString *)url;

@end
