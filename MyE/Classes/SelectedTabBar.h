//
//  SelectedTabBar.h
//  MyE
//
//  Created by Haifeng Guo on 10/28/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#ifndef MyE_SelectedTabBar_h
#define MyE_SelectedTabBar_h

/* The reason to create this protocol is to remember the selected tab view,
 so that when users enter the same house from the houseViewList, they will
 see the same tab view where they left last time */

@protocol SelectedTabBar

- (void) saveSeletedTabIndex:(NSInteger) index;

@end



#endif
