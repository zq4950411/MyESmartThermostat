//
//  OperationViewController.h
//  MyE
//
//  Created by space on 13-8-13.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "BaseTableViewController.h"

@class InstructionEntity;
@interface OperationViewController : BaseTableViewController <UITableViewDataSource,UITableViewDelegate>
{
    BOOL canAddNew;
}

-(InstructionEntity *) getCurrentInstruction;
-(void) updateInstruction;

-(void) deleteRow;

@end
