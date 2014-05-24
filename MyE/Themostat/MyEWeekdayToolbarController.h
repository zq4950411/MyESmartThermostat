//
//  MyEWeekdayToolbarController.h
//  MyE
//
//  Created by Ye Yuan on 4/11/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UISegmentedControl+Extension.h"

@protocol MyEWeekdayToolbarControllerDelegate;

@interface MyEWeekdayToolbarController : NSObject{
    UISegmentedControl *_segmentedControl;
    id <MyEWeekdayToolbarControllerDelegate> delegate;
}
@property (strong, nonatomic) id <MyEWeekdayToolbarControllerDelegate> delegate;
@property (retain, nonatomic) UISegmentedControl *segmentedControl;
@property (retain, nonatomic) NSArray *items;
@property (retain, nonatomic) NSArray *colors;

- (id)initWithFrame:(CGRect)frame items:(NSArray *)theItems tintColors:(NSArray *)colors;
- (void)viewDidUnload;
- (void)updateTextColors;
@end


@protocol MyEWeekdayToolbarControllerDelegate <NSObject>

@optional
- (void)didSelectWeekdayId:(NSUInteger)weekdayId;

@end