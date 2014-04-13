//
//  MyEBlockAlertViewWithCheckbox.h
//  MyE
//
//  Created by Ye Yuan on 7/4/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyECheckBoxView;

@interface MyEBlockAlertViewWithCheckbox : NSObject{
@protected
    UIView *_view;
    NSMutableArray *_blocks;
    CGFloat _height;
    
    //* start added by YY
    MyECheckBoxView *_checkbox;
    BOOL _hideNextTime;
    BOOL _isShowAnimated;
    BOOL _isHideAnimated;
    //end added by YY*/
}

+ (MyEBlockAlertViewWithCheckbox *)alertWithTitle:(NSString *)title message:(NSString *)message;

- (id)initWithTitle:(NSString *)title message:(NSString *)message;

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block;
- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block;
- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block;

- (void)show;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

@property (nonatomic, retain) UIImage *backgroundImage;
@property (nonatomic, readonly) UIView *view;
@property (nonatomic, readwrite) BOOL vignetteBackground;

//* start added by YY
- (BOOL) isChecked;
- (void) addCheckboxWithTitle:(NSString *)title;
- (void) isShowAnimated:(BOOL)animated;
- (void) isHideAnimated:(BOOL)animated;
//end added by YY*/
@end
