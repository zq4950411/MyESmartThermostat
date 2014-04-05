//
//  RegistGatewayViewController.h
//  MyE
//
//  Created by space on 13-8-31.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseTableViewController.h"
#import "ZBarSDK.h"

@protocol DictionaryDelegate;
@protocol HouseDelegate;

@interface RegistGatewayViewController : BaseTableViewController <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,ZBarReaderDelegate,DictionaryDelegate,HouseDelegate>
{
    NSString *mid;
    NSString *pin;
    
    NSString *houseName;
    NSString *houseId;
    
    NSString *zoneName;
    NSString *zoneId;
}


@end
