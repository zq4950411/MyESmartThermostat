//
//  MyEStartupViewController.m
//  MyE
//
//  Created by Ye Yuan on 3/16/13.
//  Copyright (c) 2013 MyEnergy Domain. All rights reserved.
//

#import "MyEStartupViewController.h"

@interface MyEStartupViewController ()

@end

@implementation MyEStartupViewController
@synthesize  pageControlBeingUsed;
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
    self.scrollView.contentSize = self.imageView.image.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {

    [self setImageView:nil];
    [self setScrollView:nil];
    [self setPageControl:nil];
    [super viewDidUnload];
}

#pragma mark ScrollView delegate method and UIPageControl

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
//    NSLog(@"scrollViewDidScroll page No: %i", page);
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
    NSLog(@"=========, page = %i",self.pageControl.currentPage);
}
- (IBAction)changePage:(id)sender {
    NSLog(@"changePage pae No: %i", [self.pageControl currentPage]);
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];}
@end
