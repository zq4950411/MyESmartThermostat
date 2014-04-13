//
//  MyECheckBoxView.m
//  MyE
//
//  Created by Ye Yuan on 6/24/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyECheckBoxView.h"
#import <objc/message.h>
#import <QuartzCore/QuartzCore.h>

@implementation MyECheckBoxView
@synthesize label,icon,value,delegate;  
-( id )initWithFrame: ( CGRect )frame  
{  
    if ( self = [super initWithFrame: frame])   
    {  
                
        icon =[[UIImageView alloc] initWithFrame:  
               CGRectMake ( 10 , (frame.size.height - frame.size.height/2)/2 , frame.size.height/2 , frame.size.height/2 )];  
        
        [ self setStyle : CheckButtonStyleDefault ]; // 默认风格为方框（多选）样式  
        
        //self.backgroundColor=[UIColor grayColor];  
        [ self addSubview : icon ];  
        
        
        label =[[ UILabel alloc ] initWithFrame : CGRectMake ( icon.frame.size.width + 18 , 2 ,  
                                                              frame.size.width - icon.frame.size.width - 18 ,  
                                                              frame.size.height-4 )];  
        label.backgroundColor =[ UIColor clearColor ];  
        label.font =[ UIFont fontWithName : @"Arial" size : 16 ];  
        label.textColor =[ UIColor  
                          colorWithRed : 0xff / 255.0  
                          green : 0xff / 255.0  
                          blue : 0xff / 255.0  
                          alpha : 1 ];  
        label.textAlignment = NSTextAlignmentLeft;
        [self addSubview: label];  
        [self addTarget: self action: @selector( clicked ) forControlEvents: UIControlEventTouchUpInside];  
        [self addTarget: self action: @selector( pressed ) forControlEvents: UIControlEventTouchDown]; 

        
        /* 设置背景、边框、圆角等 */
        self.layer.backgroundColor =[UIColor blackColor].CGColor;
        self.layer.cornerRadius = 4.0;
        
        [self.layer setShadowOffset:CGSizeMake(0, 3)];
        [self.layer setShadowRadius:4];
        [self.layer setShadowOpacity:0.8]; 
        [self.layer setShadowColor:[UIColor grayColor].CGColor];
        
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1;

    }  
    
    return self;  
    
}  
-( CheckButtonStyle )style  
{  
    return style ;  
}  
-( void )setStyle: ( CheckButtonStyle )st  
{  
    style =st;  
    
    switch ( style )   
    {  
        case CheckButtonStyleDefault:  
        case CheckButtonStyleBox:  
            checkname = @"checkbox-checked.png";  
            uncheckname = @"checkbox-unchecked.png";  
            checkedpressedname = @"checkbox-checked-pressed.png";
            uncheckedpressedname = @"checkbox-unchecked-pressed.png";
            break;  
        case CheckButtonStyleRadio:  
            checkname = @"radio.png";  
            uncheckname = @"unradio.png";  
            checkedpressedname = @"checkbox-checked-pressed.png";
            uncheckedpressedname = @"checkbox-unchecked-pressed.png";
            break;  
        default:  
            break;  
    }  
    
    [self setChecked: checked];  
}  
-( void )updateView {
    if ( checked )   
    {  
        [icon setImage: [UIImage imageNamed: checkname]];  
        label.textColor =[ UIColor  
                          colorWithRed : 0xf9 / 255.0  
                          green : 0xe8 / 255.0  
                          blue : 0x57 / 255.0  
                          alpha : 1 ]; 
    }   
    else  
    {  
        [icon setImage: [UIImage imageNamed: uncheckname]];  
        label.textColor =[ UIColor  
                          colorWithRed : 0xff / 255.0  
                          green : 0xff / 255.0  
                          blue : 0xff / 255.0  
                          alpha : 1 ]; 
    }  
    if(!self.enabled ) {
        self.alpha = 0.6;
        // 可以用下面这些效果，但用上面alpha透明效果已经不错了
//        self.layer.backgroundColor =[UIColor lightGrayColor].CGColor;
//        label.textColor =[ UIColor grayColor]; 
    } else {
//        self.layer.backgroundColor =[UIColor blackColor].CGColor;
        self.alpha = 1.0;
    }
}
-( BOOL )isChecked  
{  
    return checked;  
}  
-( void )setChecked: ( BOOL )b  
{  
    if (b!= checked )  
    {  
        checked = b;  
    }  
[self updateView];
}
-( void )setDisabled:(BOOL)disabled {
    if(disabled) {
        self.enabled = NO;
    } else {
        self.enabled = YES;
    }
    [self updateView];
}
-( BOOL )isDisabled {
    return !self.enabled;
}
-( void )clicked  
{  
    [self setChecked: !checked];  
    
    if ( delegate != nil )   
    {  
        SEL sel = NSSelectorFromString ( @"checkButtonClicked" );  
        
        if ([delegate respondsToSelector: sel])  
        {  
            objc_msgSend(delegate, sel);
            //[delegate performSelector: sel];  // 原来是此语句，但它会报告警告
            /*
             http://stackoverflow.com/questions/7043999/im-writing-a-button-class-in-objective-c-with-arc-how-do-i-prevent-clangs-m
             
             Because you're dynamically assigning action, the compiler sees a possible leak with ARC. In the future, the LLVM compiler may allow you to suppress the warning. Until then, you can avoid the warning by using the runtime's objc_msgSend() instead of -performSelector:.
             
             First, import the runtime message header
             
             #import <objc/message.h>
             Next, replace performSelector: with objc_msgSend()
             // [object performSelector:action];
             objc_msgSend(object, action);
             
             */
        }   
        
    }  
    
}  

-( void )pressed  
{  
    if ( checked )   
    {  
        [icon setImage: [UIImage imageNamed: checkedpressedname]];
        label.textColor =[ UIColor  
                          colorWithRed : 0xd8 / 255.0  
                          green : 0xe9 / 255.0  
                          blue : 0xf7 / 255.0  
                          alpha : 1 ]; 
         
    }   
    else  
    {  
        [icon setImage: [UIImage imageNamed: uncheckedpressedname]]; 
        label.textColor =[ UIColor  
                          colorWithRed : 0xff / 255.0  
                          green : 0xbe / 255.0  
                          blue : 0x8f / 255.0  
                          alpha : 1 ];
    }  

}  
-( void )setBackgroundColor:(UIColor *)backgroundColor showBorder:(BOOL)showBorder showShadow:(BOOL)showShadow{
    /* 设置背景、边框、圆角等 */
    self.layer.backgroundColor = backgroundColor.CGColor;
    self.layer.cornerRadius = 4.0;

    if (showBorder) {
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1;
    } else {
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 0;
    }
    
    if (showShadow) {
        [self.layer setShadowOpacity:1.0f];
    } else {
        [self.layer setShadowOpacity:0.0f];

    }
}
-( void )dealloc{  
    value = nil ; delegate = nil ;   
}  

@end
