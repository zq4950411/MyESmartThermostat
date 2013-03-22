//
//  MyELaunchIntroViewController.m
//  MyE
//
//  Created by Ye Yuan on 3/17/13.
//  Copyright (c) 2013 MyEnergy Domain. All rights reserved.
//

#import "MyELaunchIntroViewController.h"

@interface MyELaunchIntroViewController ()

@end

@implementation MyELaunchIntroViewController
@synthesize pageControlBeingUsed;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * 4, self.scrollView.frame.size.height);
    self.pageControlBeingUsed = NO;
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
        CGRect frame = [self.scrollView frame];

        CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 548.0f);

        [self.scrollView setFrame:newFrame];


        self.imageView0.image = [UIImage imageNamed:@"demo0-568h.png"];
        self.imageView1.image = [UIImage imageNamed:@"demo1-568h.png"];
        self.imageView2.image = [UIImage imageNamed:@"demo2-568h.png"];
        self.imageView3.image = [UIImage imageNamed:@"demo3-568h.png"];
    } else {
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSubview0:nil];
    [self setSubview1:nil];
    [self setSubview2:nil];
    [self setSubview3:nil];
    [self setScrollView:nil];
    [self setPageControl:nil];
    [self setImageView0:nil];
    [self setImageView1:nil];
    [self setImageView2:nil];
    [self setImageView3:nil];
    [super viewDidUnload];
}

#pragma mark
#pragma mark ScrollView Delegate methods
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}
- (IBAction)changePage:(id)sender {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    pageControlBeingUsed = NO;
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    pageControlBeingUsed = NO;
//}
@end
