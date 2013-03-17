//
//  MyEStartupViewController.h
//  MyE
//
//  Created by Ye Yuan on 3/16/13.
//  Copyright (c) 2013 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEStartupViewController : UIViewController <UIScrollViewDelegate>
@property (nonatomic) BOOL pageControlBeingUsed;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

- (id)initWithPageNumber:(int)page;
@end
