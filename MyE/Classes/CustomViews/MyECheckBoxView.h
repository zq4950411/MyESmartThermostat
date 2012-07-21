//
//  MyECheckBoxView.h
//  MyE
//
//  Created by Ye Yuan on 6/24/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {  
    CheckButtonStyleDefault = 0 ,  
    CheckButtonStyleBox = 1 ,  
    CheckButtonStyleRadio = 2  
} CheckButtonStyle; 

@interface MyECheckBoxView : UIControl
{  
    //UIControl* control;  
    UILabel *label;  
    UIImageView *icon;  
    BOOL checked;  
    id value;  
    id delegate;  
    CheckButtonStyle style;  
    NSString *checkname;   
    NSString *uncheckname; // 勾选／反选时的图片文件名  
    NSString *checkedpressedname; // 已经选中时，按下高亮时的图片文件名
    NSString *uncheckedpressedname;// 在未被选中时，按下高亮时的图片文件名 
}  
@property ( retain , nonatomic ) id value;  
@property ( retain , nonatomic ) id delegate;  
@property ( retain , nonatomic ) UILabel *label;  
@property ( retain , nonatomic ) UIImageView *icon;  
@property ( assign ) CheckButtonStyle style;  

-( CheckButtonStyle )style;  
-( void )setStyle: ( CheckButtonStyle )st;  
-( BOOL )isChecked;  
-( void )setChecked: ( BOOL )b;  
-( void )setDisabled:(BOOL)disabled;
-( BOOL )isDisabled;
-( void )updateView;
-( void )setBackgroundColor:(UIColor *)backgroundColor showBorder:(BOOL)showBorder  showShadow:(BOOL)showShadow;
@end
