//
//  MyEPeriodInforDoughnutView.h
//  MyE
//  为MyEDoughnutView，在其上新建圆环布局上显示heating/cooling的数值提示
//  Created by Ye Yuan on 6/28/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol MyEPeriodInforDoughnutViewDelegate;
@interface MyEPeriodInforDoughnutView : UIView{
    NSMutableArray *_periods;
    float doughnutViewRadius;
    float _doughnutCenterOffsetX;
    float _doughnutCenterOffsetY;
}

@property (nonatomic, retain) id <MyEPeriodInforDoughnutViewDelegate> delegate;
@property (nonatomic, strong) NSArray * periods;
@property (nonatomic) float doughnutViewRadius;
// DoughnutView相对于本View中心的偏移量，因为很可能父DoughnutView不在中央，所以本View也要根据其父DoughnutView进行偏移
@property (nonatomic) float doughnutCenterOffsetX; 
@property (nonatomic) float doughnutCenterOffsetY;

@end

/*
 Protocol for the MyEPeriodInforDoughnutView's delegate.
 */
@protocol MyEPeriodInforDoughnutViewDelegate <NSObject>
@optional
- (void) didFinishPeriodInforDoughnutView;
@end