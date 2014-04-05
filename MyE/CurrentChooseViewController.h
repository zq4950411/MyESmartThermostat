//
//  CurrentChooseViewController.h
//  MyE
//
//  Created by space on 13-9-9.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseViewController.h"

@interface CurrentChooseViewController : BaseViewController <UIPickerViewDataSource,UIPickerViewDelegate>
{
    int t;
}

-(id) initWithIndex:(int) index;

@end
