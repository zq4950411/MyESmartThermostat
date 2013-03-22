//
//  MyELaunchIntroViewController.h
//  MyE
//
//  Created by Ye Yuan on 3/17/13.
//  Copyright (c) 2013 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyELaunchIntroViewController : UIViewController
@property(nonatomic)BOOL pageControlBeingUsed;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *subview0;
@property (weak, nonatomic) IBOutlet UIView *subview1;
@property (weak, nonatomic) IBOutlet UIView *subview2;
@property (weak, nonatomic) IBOutlet UIView *subview3;

@property (weak, nonatomic) IBOutlet UIImageView *imageView0;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UIImageView *imageView3;

- (IBAction)changePage:(id)sender;
@end
