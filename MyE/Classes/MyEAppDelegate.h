//
//  MyEAppDelegate.h
//  MyE
//
//  Created by Ye Yuan on 1/19/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyEAccountData;
@class MyEThermostatData;
@class MyEHouseData;


@interface MyEAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MyEAccountData *accountData;
@property (strong, nonatomic) MyEThermostatData *thermostatData;
@property (strong, nonatomic) MyEHouseData *houseData;

-(void) getLoginView;
-(BOOL) isRemember;
-(void) setRemember:(BOOL) b;

-(void) setValue:(NSString *) v withKey:(NSString *) key;

@end
