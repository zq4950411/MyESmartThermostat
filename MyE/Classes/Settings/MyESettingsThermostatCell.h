//
//  MyESettingsThermostatCell.h
//  MyE
//
//  Created by Ye Yuan on 3/16/13.
//  Copyright (c) 2013 MyEnergy Domain. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MyESettingsThermostatCellDelegate;

@interface MyESettingsThermostatCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *thermostatLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UISwitch *keypadLockSwitch;

@property (nonatomic, retain) id <MyESettingsThermostatCellDelegate> delegate;

- (IBAction)changeKaypadLock:(id)sender;
@end


/*
 Protocol for the MyEMyEModePickerView's delegate.
 */
@protocol MyESettingsThermostatCellDelegate <NSObject>

@required

-(void) didKeypadSwitchChanged:(MyESettingsThermostatCell *)theCell;
@end

