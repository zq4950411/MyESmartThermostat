//
//  MyEDropDownMenu.h
//
//  MyE
//  based on :
//  https://github.com/darthpelo/ARNavBar
//  https://github.com/leviathan/NIDropDown
//  https://github.com/BijeshNair/NIDropDown
//
//  Created by Ye Yuan on 5/20/14.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface MyEDropDownMenu : UIView <UITableViewDelegate, UITableViewDataSource> {
    BOOL goDownDirection;
}

@property (nonatomic, copy) void (^function)(NSInteger index);
@property (nonatomic, copy) void (^releseMenu)();

- (void)hideDropDown:(UIView *)view;
- (id)showDropDown:(UIView *)view titleList:(NSArray *)titleList imageList:(NSArray *)imageList directionDown:(BOOL)direction;

@end
