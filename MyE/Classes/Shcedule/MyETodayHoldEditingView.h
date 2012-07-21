//
//  MyETodayHoldEditingView.h
//  MyE
//
//  Created by Ye Yuan on 6/30/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MyETodayHoldEditingViewDelegate;

@interface MyETodayHoldEditingView : UIView<UIPickerViewDelegate,UIPickerViewDataSource>{
    id <MyETodayHoldEditingViewDelegate> delegate;
    NSInteger _periodIndex;//当前正在编辑的period的index
    NSInteger _setpoint;
    NSString *_holdString;
    
    UILabel *_holdLabel; 
    
    UIPickerView *_setpointPickerView;
    
    UIButton *_runButton;
    UIButton *_okButton;
    UIButton *_cancelButton;
}
@property (nonatomic, retain) id <MyETodayHoldEditingViewDelegate> delegate;
@property (nonatomic) NSInteger periodIndex;
@property (nonatomic) NSInteger setpoint;
@property (nonatomic, copy) NSString *holdString;

@end

/*
 Protocol for the MyETodayHoldEditingView's delegate.
 */
@protocol MyETodayHoldEditingViewDelegate <NSObject>
@required
// action: 0-run, 1-ok, 2-cancel
- (void) didFinishHoldEditingWithAction:(NSInteger)action setpoint:(NSInteger)setpoint run:(BOOL)isRun;

@end
