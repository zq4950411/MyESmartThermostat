//
//  MyETipViewController.h
//  MyE
//
//  Created by Ye Yuan on 6/26/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyETipViewController : NSObject
{
    NSMutableArray *_tipDataArray;
    NSMutableArray *_tempShuffledDataArray;// 临时打乱次序的提示数据数组
}
@property (nonatomic, strong) NSMutableArray *tipDataArray;

+(MyETipViewController *)tipViewControllerWithTipDataArray:(NSArray *)dataArray;
-(void)addTipWithWithKey:(NSString *)key title:(NSString *)title message:(NSString *)message;
-( void )showTips;  
@end
