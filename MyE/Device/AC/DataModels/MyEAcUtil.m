//
//  MyEACUtils.m
//  MyEHomeCN2
//
//  Created by Ye Yuan on 10/11/13.
//  Copyright (c) 2013 My Energy Domain Inc. All rights reserved.
//

#import "MyEAcUtil.h"

@implementation MyEAcUtil

+ (NSString *)getStringForPowerSwitch:(NSInteger)powerSwitch
{
    if (powerSwitch == 1) {
        return @"ON";
    }else return @"OFF";
}
+ (NSString *)getStringForRunMode:(NSInteger)runMode
{
    switch (runMode) {
        case 1:
            return @"Auto";
            break;
        case 2:
            return @"Heating";
            break;
        case 3:
            return @"Cooling";
            break;
        case 4:
            return @"Dehumidify";
            break;
        case 5:
            return @"Fan Only";
            break;
        default:
            return @"Auto";
            break;
    }
}
+ (NSString *)getStringForSetpoint:(NSInteger)setpoint
{
    return [NSString stringWithFormat:@"%ld℃",(long)setpoint];
}
+ (NSString *)getStringForWindLevel:(NSInteger)windLevel
{
    switch (windLevel) {
        case 0:
            return @"Auto";
            break;
        case 1:
            return @"Lv1";
            break;
        case 2:
            return @"Lv2";
            break;
        case 3:
            return @"Lv3";
            break;
        default:
            return @"Auto";
            break;
    }
}


+ (NSString *)getFilenameForRunMode:(NSInteger)runMode
{
    switch (runMode) {
        case 1:
            return @"run1";
            break;
        case 2:
            return @"run2";
            break;
        case 3:
            return @"run3";
            break;
        case 4:
            return @"run4";
            break;
        case 5:
            return @"run5";
            break;
        default:
            return @"run1";
            break;
    }
}
//+(UIImage *)getImageForDeviceType:(NSInteger)deviceType
//{
//    switch (deviceType) {
//        case DT_AC:
//            return [UIImage imageNamed:@"ac-on"];
//            break;
//        case DT_TV:
//            return [UIImage imageNamed:@"tv-on"];
//            break;
//        case DT_CURTAIN:
//            return [UIImage imageNamed:@"curtain-on"];
//            break;
//        case DT_AUDIO:
//            return [UIImage imageNamed:@"audio-on"];
//            break;
//        case DT_SOCKET:
//            return [UIImage imageNamed:@"socket-on"];
//            break;
//        case DT_OTHER:
//            return [UIImage imageNamed:@"other-on"];
//            break;
//        default:
//            return [UIImage imageNamed:@"switch-on"];
//            break;
//    }
//    return [UIImage imageNamed:@"other-on"];
//}
@end
