//
//  MYEWeekButtons.m
//  weekBtn
//
//  Created by 翟强 on 14-5-20.
//  Copyright (c) 2014年 翟强. All rights reserved.
//

#import "MYEWeekButtons.h"

@implementation MYEWeekButtons

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}
- (void)drawRect:(CGRect)rect
{
    NSLog(@"draw rect");
    self.weeks = [NSMutableArray array];
    self.backgroundColor = [UIColor clearColor]; //背景透明
    [self setButtonsInViewWithFrame:rect];
}
#pragma mark - add Button In View
-(void)setButtonsInViewWithFrame:(CGRect)frame{
    if (frame.size.width/frame.size.height < 7) {
        NSLog(@"view的宽度太窄");
        return ;
    }
    CGFloat hight = frame.size.height;
    for (int i = 1; i < 8; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i+1000;
        btn.frame = CGRectMake(hight*(i-1), 0, hight, hight);
        [btn setBackgroundImage:[UIImage imageNamed:@"weekBtn-normal"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"weekBtn-select"] forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn setTitle:[self setBtnTitleWithTag:btn.tag] forState:UIControlStateNormal];
//        btn.titleLabel.font = [UIFont systemFontOfSize:14*hight/40];
        btn.titleLabel.font = [UIFont systemFontOfSize:14*hight/40];
        [btn addTarget:self action:@selector(didBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
}
-(NSString *)setBtnTitleWithTag:(NSInteger)tag{
    /*星期一： Mon.=Monday
     星期二： Tues.=Tuesday
     星期三： Wed.=Wednesday
     星期四： Thur.=Thursday
     星期五： Fri.=Friday
     星期六： Sat.=Saturday*/
    NSString *title = nil;
    switch (tag - 1000) {
        case 1:
            title = @"Mon";
            break;
        case 2:
            title = @"Tues";
            break;
        case 3:
            title = @"Wed";
            break;
        case 4:
            title = @"Thur";
            break;
        case 5:
            title = @"Fri";
            break;
        case 6:
            title = @"Sat";
            break;
        default:
            title = @"Sun";
            break;
    }
    return title;
}

#pragma mark - did Click Button
-(void)didBtnSelected:(UIButton *)btn{
    btn.selected = !btn.selected;
    if (btn.selected) {
        [self.weeks addObject:@(btn.tag - 1000)];
    }else{
        if ([self.weeks containsObject:@(btn.tag - 1000)]) {
            [self.weeks removeObject:@(btn.tag - 1000)];
        }
    }
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSArray *newArray = [self.weeks sortedArrayUsingDescriptors:@[sort]];
    if ([self.delegate respondsToSelector:@selector(weekButtons:selectedButtonTag:)]) {
        [self.delegate weekButtons:self selectedButtonTag:newArray];
    }
}
#pragma mark - private methods
-(void)setSelectedButtons:(NSArray *)selectedButtons{
    if (![selectedButtons count]) {
        return;
    }
    for (NSNumber *i in selectedButtons) {
        for (UIButton *btn in self.subviews) {
            if (btn.tag == [i intValue]+1000) {
                btn.selected = YES;
            }
        }
    }
}
@end
