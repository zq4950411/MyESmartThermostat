//
//  MyEUCChannelSetViewController.m
//  MyE
//
//  Created by 翟强 on 14-6-9.
//  Copyright (c) 2014年 MyEnergy Domain. All rights reserved.
//

#import "MyEUCChannelSetViewController.h"

@interface MyEUCChannelSetViewController ()
{
    NSMutableArray *_data;
    MyEUCChannelInfo *_newChannel;
}
@end

@implementation MyEUCChannelSetViewController

#pragma mark - life circle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    _newChannel = [self.channelInfo copy];
    NSLog(@"%@",_newChannel);
    _data = [NSMutableArray array];
    for (int i=1; i < 7; i++) {
        [_data addObject:[NSString stringWithFormat:@"Channel %i",i]];
    }
    [self.channelBtn setTitle:[NSString stringWithFormat:@"Channel %i",_newChannel.channel] forState:UIControlStateNormal];
    self.durationTxt.text = [NSString stringWithFormat:@"%i",_newChannel.duration];
    NSString *imgName = IS_IOS6?@"detailBtn-ios6":@"detailBtn";
    [self.channelBtn setBackgroundImage:[[UIImage imageNamed:imgName] stretchableImageWithLeftCapWidth:0 topCapHeight:0] forState:UIControlStateNormal];
    [self.channelBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 30)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark - IBAction methods
- (IBAction)setChannels:(UIButton *)sender {
    [self.view endEditing:YES];
    MYEPickerView *picker = [[MYEPickerView alloc] initWithView:self.view andTag:100 title:@"Select Channel" dataSource:_data andSelectRow:[_data containsObject:sender.currentTitle]?[_data indexOfObject:sender.currentTitle]:0];
    picker.delegate = self;
    [picker showInView:self.view];
}
- (IBAction)saveEdit:(UIBarButtonItem *)sender {
    if (self.durationTxt.text.intValue < 24*60) {
        _newChannel.duration = [self.durationTxt.text intValue];
        if (self.isAdd) {
            [self.sequential.sequentialOrder addObject:_newChannel];
        }else{
            if ([self.sequential.sequentialOrder containsObject:self.channelInfo]) {
                NSInteger i = [self.sequential.sequentialOrder indexOfObject:self.channelInfo];
                [self.sequential.sequentialOrder removeObject:self.channelInfo];
                [self.sequential.sequentialOrder insertObject:_newChannel atIndex:i];
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
    }else
        [SVProgressHUD showErrorWithStatus:@"Duration Error"];
}

#pragma mark - MYEPickerView delegate methods
-(void)MYEPickerView:(UIView *)pickerView didSelectTitles:(NSString *)title andRow:(NSInteger)row{
    _newChannel.channel = row +1 ;
}
@end
