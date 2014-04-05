//
//  UIUtils.m
//  MyE
//
//  Created by space on 13-8-20.
//  Copyright (c) 2013年 MyEnergy Domain. All rights reserved.
//

#import "UIUtils.h"

@implementation UIUtils

+(UIViewController *) getControllerFromNavViewController:(UIViewController *) vc andClass:(Class) cls
{
    if (vc.navigationController)
    {
        NSArray *array = vc.navigationController.viewControllers;
        for (UIViewController *temp in array)
        {
            if ([temp isKindOfClass:[UITabBarController class]])
            {
                UITabBarController *tabVc = (UITabBarController *)temp;
                for (UIViewController *temp2 in tabVc.viewControllers)
                {
                    if ([temp2 isKindOfClass:cls])
                    {
                        return temp2;
                    }
                }
            }
            if ([temp isKindOfClass:cls])
            {
                return temp;
            }
        }
    }
    return nil;
}

@end
