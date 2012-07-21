//
//  MyEWeekdayToolbarController.m
//  MyE
//
//  Created by Ye Yuan on 4/11/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEWeekdayToolbarController.h"

// Tag的起始编号
#define kTagStart 2178

@interface MyEWeekdayToolbarController(PrivateMethods)
- (void)selectDay:(id)sender;
@end

@implementation MyEWeekdayToolbarController
@synthesize segmentedControl = _segmentedControl, items = _items, colors = _colors;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame items:(NSArray *)theItems tintColors:(NSArray *)theColors
{
    self.items = theItems;
    self.colors = theColors;
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:self.items];
    
    [self.segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [self.segmentedControl setTintColor:[UIColor lightGrayColor]];
    [self.segmentedControl setFrame:frame];
    
    UIFont *font = [UIFont boldSystemFontOfSize:15.0f];
    NSArray *values = [[NSArray alloc] initWithObjects:font, [NSNumber numberWithFloat:2.0], nil];
    NSArray *keys = [[NSArray alloc] initWithObjects:UITextAttributeFont, UITextAttributeTextShadowOffset, nil];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    [self.segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    [self.segmentedControl addTarget:self action:@selector(selectDay:) forControlEvents:UIControlEventValueChanged];
    
    // ... now to the interesting bits
    
    // at some point later, the segment indexes change, so
    // must set tags on the segments before they render
    for (int i = 0; i<[self.items count]; i++) {
        [self.segmentedControl setTag:i+kTagStart forSegmentAtIndex:i];
        [self.segmentedControl setTintColor:[self.colors objectAtIndex:i] forTag:i+kTagStart];
    }
    [self updateTextColors];
    
    return self;
}


- (void)selectDay:(id)sender {
    // when a segment is selected, it resets the text colors
    // so set them back
    [self updateTextColors];
    
    UISegmentedControl *myUISegmentedControl=(UISegmentedControl *)sender;
    
    //在本App中，weekdayId顺序是:         0-sun, 1-mon, 2-Tue, ..., 6-Sat
    // 调整顺序，因为segmentedControl顺序是       0-Mon, 1-Tue, ..., 5-Sat, 6-Sun
    NSInteger weekdayId = myUISegmentedControl.selectedSegmentIndex+1;     
    if (weekdayId >6) {
        weekdayId = 0;
    }

    if ([delegate respondsToSelector:@selector(didSelectWeekdayId:)])
        [delegate didSelectWeekdayId:weekdayId];
}
-(void)updateTextColors {
    //  把全部分段设置为一种颜色
    for (int i = 0; i<[self.items count]; i++) {
        [self.segmentedControl setTextColor:[UIColor whiteColor] forTag:i+kTagStart];
//        [self.segmentedControl setShadowColor:[UIColor lightGrayColor] forTag:i+kTagStart];
    }
    
    // 把被选择的分段设置成白色加亮
    [self.segmentedControl setTextColor:[UIColor yellowColor] forTag:self.segmentedControl.selectedSegmentIndex + kTagStart];
//    [self.segmentedControl setShadowColor:[UIColor lightGrayColor] forTag:self.segmentedControl.selectedSegmentIndex + kTagStart];
}

- (void)viewDidUnload 
{
    [self setSegmentedControl:nil];
    [self setItems:nil];
    [self setColors:nil];
}

@end
