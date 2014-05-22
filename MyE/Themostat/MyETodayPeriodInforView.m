//
//  MyETMyETodayPeriodInforView.m
//  MyE
//
//  Created by Ye Yuan on 4/23/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyETodayPeriodInforView.h"
#import <QuartzCore/QuartzCore.h>
@interface MyETodayPeriodInforView(PrivateMethods)
- (void) _doneView;

@end

@implementation MyETodayPeriodInforView
@synthesize coolingLabel = _coolingLabel, heatingLabel = _heatingLabel, holdLabel = _holdLabel;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 120, frame.size.width, 120)];
        [bottomView setBackgroundColor:[UIColor blackColor]];
        [bottomView setOpaque:NO];
        [bottomView setAlpha:0.75];

               // create a label
        
        UILabel *heatingingNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, self.bounds.size.width/2.0, 30)];
        [heatingingNameLabel setBackgroundColor:[UIColor clearColor]];
        [heatingingNameLabel setTextColor:[UIColor whiteColor]];
        //        [heatingingNameLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14]];
        [heatingingNameLabel setText:@"Heating  "];
        [heatingingNameLabel setTextAlignment:NSTextAlignmentRight]; 
        
        _heatingLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/2.0, 10, self.bounds.size.width/2.0, 30)];
        [_heatingLabel setBackgroundColor:[UIColor clearColor]];
        [_heatingLabel setTextColor:[UIColor whiteColor]];
        [_heatingLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [_heatingLabel setText:@"70F"];
        [_coolingLabel setTextAlignment:NSTextAlignmentLeft]; 
        
        UILabel *coolingNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(heatingingNameLabel.frame) +  5, self.bounds.size.width/2.0, 30)];
        [coolingNameLabel setBackgroundColor:[UIColor clearColor]];
        [coolingNameLabel setTextColor:[UIColor whiteColor]];
        //        [coolingNameLabel setFont:[UIFont fontWithName:@"AmericanTypewriter" size:14]];
        [coolingNameLabel setText:@"Cooling  "];
        [coolingNameLabel setTextAlignment:NSTextAlignmentRight]; 
        
        _coolingLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/2.0, CGRectGetMaxY(heatingingNameLabel.frame) +  5, self.bounds.size.width/2, 30)];
        [_coolingLabel setBackgroundColor:[UIColor clearColor]];
        [_coolingLabel setTextColor:[UIColor whiteColor]];
        [_coolingLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [_coolingLabel setText:@"74F"];
        [_coolingLabel setTextAlignment:NSTextAlignmentLeft]; 

        _holdLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_coolingLabel.frame) +  5, self.bounds.size.width, 30)];
        [_holdLabel setBackgroundColor:[UIColor clearColor]];
        [_holdLabel setTextColor:[UIColor whiteColor]];
        [_holdLabel setFont:[UIFont fontWithName:@"SystemBold" size:18]];
        [_holdLabel setText:@"74F"];
        [_holdLabel setTextAlignment:NSTextAlignmentCenter]; 
        [_holdLabel setHidden:YES];
        
        // add subviews to container view
        //[bottomView addSubview:doneButton];//现在不需要done按钮，直接点击界面就可以因此此view
        [bottomView addSubview:heatingingNameLabel];
        [bottomView addSubview:_heatingLabel];
        [bottomView addSubview:coolingNameLabel];
        [bottomView addSubview:_coolingLabel];
        [bottomView addSubview:_holdLabel];
        
        [self addSubview:bottomView];
        // 描绘本容器view的边界，以便于调试
//        CALayer *theLayer= [self layer];
//        theLayer.borderColor = [UIColor purpleColor].CGColor;
//        theLayer.borderWidth = 1;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)setCooling:(NSInteger)cooling {
    self.coolingLabel.text = [NSString stringWithFormat:@"%iF", cooling];
}
- (void)setHeating:(NSInteger)heating{
    self.heatingLabel.text = [NSString stringWithFormat:@"%iF", heating];
}
- (void)setHoldString:(NSString *)holdString {
    if (holdString != nil && [holdString caseInsensitiveCompare:@"none"] != NSOrderedSame) {
        self.holdLabel.hidden = NO;
        self.holdLabel.text = [NSString stringWithFormat:@"Hold status: %@", holdString];
    } else {
        self.holdLabel.hidden = YES;
    }
    
}
- (void)_doneView {
    if ([self.delegate respondsToSelector:@selector(didFinishPeriodInforView)])
        [self.delegate didFinishPeriodInforView];
}

#pragma mark -
#pragma mark touch methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    [self _doneView];

}


@end
