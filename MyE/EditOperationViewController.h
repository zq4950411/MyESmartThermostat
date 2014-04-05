//
//  EditOperationViewController.h
//  MyE
//
//  Created by space on 13-8-13.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseTableViewController.h"

@class CommonCell;
@class InstructionEntity;

@interface EditOperationViewController : BaseTableViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    __weak NSString *operationName;
    
    int type;
    
    CommonCell *commentCell;
    InstructionEntity *instruction;
    
    BOOL isRecoredSuccess;
    
    int requestCount;
}

@property (nonatomic,strong) CommonCell *commentCell;
@property (nonatomic,strong) InstructionEntity *instruction;

@property (nonatomic,weak) NSString *operationName;
@property (nonatomic) int type;

-(id) initWithType:(int) type andName:(NSString *) name;

@end
