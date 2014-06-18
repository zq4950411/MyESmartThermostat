//
//  HouseBlankView.m
//  MyE
//
//  Created by space on 13-9-25.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "HouseBlankView.h"
#import "ASDepthModalViewController.h"


@implementation HouseBlankView

- (void)rtLabel:(id)rtLabel didSelectLinkWithURL:(NSURL*)url
{
    [[UIApplication sharedApplication] openURL:url];
}

-(IBAction) close:(UIButton *) sender
{
    [ASDepthModalViewController dismiss];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.cornerRadius = 12;
    self.layer.shadowOpacity = 0.7;
    self.layer.shadowOffset = CGSizeMake(6, 6);
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    RTLabel *label = (RTLabel *)[self viewWithTag:10];
    label.delegate = self;
    label.text = @"This app is for Smart Home control associated with a property. Please visit our <a href='http://www.myenergydomain.com'>website</a> and add a property to your account before using this app.";
}

@end
