//
//  MyEModePickerView.m
//  MyE
//
//  Created by Ye Yuan on 3/8/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MyEModePickerView.h"
#import "MyEScheduleModeData.h"
#import "MyEScheduleWeeklyData.h"


#define THUMB_WIDTH 50
#define THUMB_HEIGHT 31
#define THUMB_H_PADDING 1

#define AUTOSCROLL_THRESHOLD 30

@interface MyEModePickerView(PrivateMethods)

- (void)_hightThumbModeView:(MyEThumbModeView *)tmv;
@end


@implementation MyEModePickerView
@synthesize delegate = _delegate;
@synthesize currentSelectedThumbModeView = _currentSelectedThumbModeView;

- (id) initWithFrame:(CGRect)frame delegate:(id<MyEModePickerViewDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = delegate;
        [self createOrUpdateThumbScrollViewIfNecessary];
        self.backgroundColor = [UIColor lightGrayColor];//测试用
        
        [[self layer] setCornerRadius:5];

    }
    return self;
}

-(void)setCurrentSelectedThumbModeView:(MyEThumbModeView *)currentSelectedThumbModeView {
    NSInteger modeId = -1;
    if(currentSelectedThumbModeView != nil) {
        modeId = currentSelectedThumbModeView.modeId;
    }
    _currentSelectedThumbModeView = currentSelectedThumbModeView;
    for (MyEThumbModeView *thumb in [thumbScrollView subviews]) {
        // 不知为什么，到这里时，本来thumbScrollView的subview应该都是MyEThumbModeView的实例，但是无缘无故在后面多出了两个UIImageView类型的对象，还不知道原因是什么，这里把后面这两个无用对象删除
        if ([thumb isKindOfClass:[MyEThumbModeView class]]){
            if(thumb.modeId == modeId ) {
                [thumb highlight];
            }
            else 
                [thumb unhighlight];
        } else {
            [thumb removeFromSuperview];
        }
    }
}

#pragma mark -
#pragma mark private methods

- (void)createOrUpdateThumbScrollViewIfNecessary {
    float scrollViewHeight = THUMB_HEIGHT +2;
    float scrollViewWidth  = [self bounds].size.width;

    if (!thumbScrollView) {        
        // create a scroll view to contain the custom color picker 
                thumbScrollView = [[UIScrollView alloc] 
                           initWithFrame:CGRectMake((self.bounds.size.width - scrollViewWidth) / 2.0, 
                                                    1 , 
                                                    scrollViewWidth, 
                                                    scrollViewHeight)];
        [thumbScrollView setCanCancelContentTouches:NO];
        [thumbScrollView setClipsToBounds:YES];
//        [thumbScrollView setBackgroundColor:[UIColor grayColor]];
        
        [thumbScrollView setIndicatorStyle:UIScrollViewIndicatorStyleDefault];
        
        [self addSubview:thumbScrollView];
    }
    
    // 移除所有的thumb view
    for(MyEThumbModeView *thumbView in thumbScrollView.subviews)
        [thumbView removeFromSuperview];

    // now place all the thumb views as subviews of the scroll view 
    // and in the course of doing so calculate the content width
    float xPosition = THUMB_H_PADDING;


    for (MyEScheduleModeData *mode in self.delegate.weeklyModel.metaModeArray) {
        NSLog(@"2 Mode name = %@, id = %i", mode.modeName, mode.modeId);
        UIColor *color = mode.color;
        CGRect frame = CGRectMake(xPosition, 1.0, THUMB_WIDTH, THUMB_HEIGHT);
        MyEThumbModeView *thumbView = [[MyEThumbModeView alloc] initWithFrame:frame Color:color modeId:mode.modeId title:mode.modeName];
        
        [thumbView setDelegate:self];

        [thumbScrollView addSubview:thumbView];
        xPosition += (frame.size.width + THUMB_H_PADDING);
    }

    [thumbScrollView setContentSize:CGSizeMake(xPosition, scrollViewHeight)];
}

// 私有函数，当用户触摸一个thumb mode时，就调用此函数来设置thumb mode view在加亮之间切换
- (void)_hightThumbModeView:(MyEThumbModeView *)tmv {
    for (MyEThumbModeView *thumb in [thumbScrollView subviews]) {
        if ([thumb isKindOfClass:[MyEThumbModeView class]]){
            [thumb unhighlight];
        } else {
            [thumb removeFromSuperview];
        }
    }
    [tmv highlight];
}

#pragma mark -
#pragma mark MyEThumbModeViewDelegate methods

- (void)thumbModeViewWasTapped:(MyEThumbModeView *)tmv {
//    NSLog(@"self.currentSelectedThumbModeView.modeId = %i,  tmv.modeId = %i",self.currentSelectedThumbModeView.modeId, tmv.modeId);
    if( self.currentSelectedThumbModeView == nil || 
       self.currentSelectedThumbModeView.modeId != tmv.modeId){
        [self _hightThumbModeView:tmv];
        self.currentSelectedThumbModeView = tmv;
        
        if ([self.delegate respondsToSelector:@selector(modePickerView:didSelectModeId:)])
            [self.delegate modePickerView:self didSelectModeId:tmv.modeId];
    } else if(self.currentSelectedThumbModeView.modeId == tmv.modeId){//如果新触摸的thumb view和刚才已经选择的thumb view是一个，表示第二次点击同一个thumb，用户准备取消这个thumb选择
        [self _hightThumbModeView:nil];
        self.currentSelectedThumbModeView = nil;
        
        if ([self.delegate respondsToSelector:@selector(modePickerView:didSelectModeId:)])
            [self.delegate modePickerView:self didSelectModeId:-1];
    }
}
- (void)thumbModeViewWasDoubleTapped:(MyEThumbModeView *)tmv {
    // 下面两句是单击是才应该有的语句，原来不知为何加上了，现在取消
//        [self _hightThumbModeView:tmv];
//        self.currentSelectedThumbModeView = tmv;
        
        if ([self.delegate respondsToSelector:@selector(modePickerView:didDoubleTapModeId:)])
            [self.delegate modePickerView:self didDoubleTapModeId:tmv.modeId];
    
}

@end
