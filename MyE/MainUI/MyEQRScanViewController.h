//
//  MyEQRScanViewController.h
//  MyEHomeCN2
//
//  Created by 翟强 on 13-12-3.
//  Copyright (c) 2013年 My Energy Domain Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"
@protocol MyEQRScanViewControllerDelegate <NSObject>
@optional
-(void)passMID:(NSString *)mid andPIN:(NSString *)pin;
@end

@interface MyEQRScanViewController : UIViewController<ZBarReaderViewDelegate>

@property (nonatomic, assign) id <MyEQRScanViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL jumpFromNav;

@end
