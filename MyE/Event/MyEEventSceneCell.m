//
//  SceneCell.m
//  MyE
//
//  Created by space on 13-8-23.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "MyEEventSceneCell.h"
#import "MyEEventSceneEntity.h"
#import "ACPButton.h"

@implementation MyEEventSceneCell

-(void) awakeFromNib
{
    editButtonX = self.headButton.frame.origin.x;
    deleteButtonX = editButtonX - 55;
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    if ([object isKindOfClass:[MyEEventSceneEntity class]])
    {
        if (self.editingStyle == UITableViewCellEditingStyleDelete)
        {
            [UIView animateWithDuration:0.35f animations:^{
                self.headButton.left = deleteButtonX;
            }];
        }
        else
        {
            MyEEventSceneEntity *scene = (MyEEventSceneEntity *)object;
            
            self.userLabel.text = scene.sceneName;
            if (editButtonX != self.headButton.left)
            {
                [UIView animateWithDuration:0.35f animations:^{
                    self.headButton.left = editButtonX;
                }];
            }
            
            ACPButton *tempButton = (ACPButton *)headButton;
            if (scene.type.integerValue == 0)
            {
                self.headButton.enabled = NO;
                self.headButton.userInteractionEnabled = NO;
                
                [tempButton setStyleType:ACPButtonDarkGrey];
            }
            else if (scene.type.integerValue == 1)
            {
                self.userInteractionEnabled = YES;
                self.headButton.enabled = YES;
                
                [tempButton setStyleType:ACPButtonOK];
            }
            else
            {
                self.headButton.userInteractionEnabled = NO;
                self.headButton.enabled = NO;
                
                [tempButton setStyleType:ACPButtonDarkGrey];
            }
        }
    }
}

@end
