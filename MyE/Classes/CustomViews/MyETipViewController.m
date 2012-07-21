//
//  MyETipViewController.m
//  MyE
//
//  Created by Ye Yuan on 6/26/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyETipViewController.h"
#import "MyEBlockAlertViewWithCheckbox.h"
#import "MyETipDataModel.h"

@interface MyETipViewController (PrivateMethods)
// 显示提示信息
- (void)_showAlertWithTipIndex:(NSInteger )index;
- (void)_getValidAndShuffledTempDataArray;
@end


@implementation MyETipViewController 
@synthesize tipDataArray = _tipDataArray;
+(MyETipViewController *)tipViewControllerWithTipDataArray:(NSArray *)dataArray {
    MyETipViewController *vc = [[MyETipViewController alloc] init];
    vc.tipDataArray = [NSMutableArray arrayWithArray:dataArray];
    return vc;
}
-(MyETipViewController *)init {
    if((self = [super init])){
        self.tipDataArray = [NSMutableArray array];
        return self;
    }
return nil;
}
-(MyETipViewController *)initWithWithTipDataArray:(NSArray *)dataArray {
    if((self = [super init])){
        self.tipDataArray = [NSMutableArray array];
        return self;
    }
    return nil;
}
-(void)addTipWithWithKey:(NSString *)key title:(NSString *)title message:(NSString *)message {
    MyETipDataModel *tdm = [[MyETipDataModel alloc] init];
    tdm.key = key;
    tdm.title = title;
    tdm.message = message;
    [self.tipDataArray addObject:tdm];
}
-( void )showTips {
    [self _getValidAndShuffledTempDataArray];
    
    [self _showAlertWithTipIndex:0];
}

@end



@implementation MyETipViewController (PrivateMethods)
// 显示提示信息
- (void)_showAlertWithTipIndex:(NSInteger )index {
    NSInteger tipCount = [_tempShuffledDataArray count];
    if(index >= tipCount) {
        return;
    }
    NSInteger nextTipIndex = index +1;// get next tip index
    
    MyETipDataModel *tipData = [_tempShuffledDataArray objectAtIndex:index];
    
    // 此处获取本地存储中的是否显示tip的标志位
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    /**  下面会产生警告： Capturing 'alert' strongly in this block is likely to lead to a retain cycle
     * 解决办法见： http://stackoverflow.com/questions/8159274/ios-5-twitter-framework-completionhandler-block-capturing-self-strongly-i
     */
    __weak MyEBlockAlertViewWithCheckbox *alert = [MyEBlockAlertViewWithCheckbox alertWithTitle:tipData.title message:tipData.message];
    
    [alert addCheckboxWithTitle:@"I knew. Don't show this on again."];
    if(nextTipIndex < tipCount){
        [alert setCancelButtonWithTitle:@"Next" block:^{
            // 此处在本地存储中保存继续显示tip的标志位
            [prefs setBool:[alert isChecked] forKey:tipData.key];
            [prefs synchronize];
            if(nextTipIndex < tipCount){// try to show next tip
                [self _showAlertWithTipIndex:nextTipIndex];
            }
        }];
    }
    [alert setDestructiveButtonWithTitle:@"Close!" block:^{
        // 此处在本地存储中保存继续显示tip的标志位
        [prefs setBool:[alert isChecked] forKey:tipData.key];
        [prefs synchronize];
    }];

    [alert isShowAnimated:index==0?YES:NO];//如果第一次，就显示进入动画，否则不显示

    [alert isHideAnimated:index == tipCount - 1 ?YES:NO];//如果是最后一个tip，就显示隐藏动画

    [alert show];
    
}

/* 打乱提示数据数组中的顺序，产生一个临时的乱序的数组
 * @see http://stackoverflow.com/questions/56648/whats-the-best-way-to-shuffle-an-nsmutablearray
 */
- (void)_getValidAndShuffledTempDataArray
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    _tempShuffledDataArray = [NSMutableArray array];

    for (MyETipDataModel *tipData in _tipDataArray) {
        BOOL needHideTip = [prefs boolForKey:tipData.key];
        if(!needHideTip) {
            [_tempShuffledDataArray addObject:tipData];
        }
    }
    static BOOL seeded = NO;
    if(!seeded)
    {
        seeded = YES;
        srandom(time(NULL));
    }
    
    NSUInteger count = [_tempShuffledDataArray count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = (random() % nElements) + i;
        [_tempShuffledDataArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}
@end
