//
//  MyEUtil.m
//  MyE
//
//  Created by Ye Yuan on 2/23/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import "MyEUtil.h"
CGContextRef MyECreateBitmapContext (int pixelsWide,
                                     int pixelsHigh)
{
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
//    int bitmapByteCount;
    int bitmapBytesPerRow;
    bitmapBytesPerRow = (pixelsWide * 4); // 1
//    bitmapByteCount = (bitmapBytesPerRow * pixelsHigh);
    colorSpace = CGColorSpaceCreateDeviceRGB(); // 2
    
    context = CGBitmapContextCreate (NULL, // In Mac OS X 10.6 and iOS 4, you pass NULL as bitmap data, Quartz automatically allocates space for the bitmap.
                                     pixelsWide,
                                     pixelsHigh,
                                     8, // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedLast);
    if (context== NULL)
    {
        CGColorSpaceRelease( colorSpace ); // 6
        fprintf (stderr, "Context not created!");
        return NULL;
    }
    CGColorSpaceRelease( colorSpace ); // 6
    return context; // 7
}

float distanceBetweenPoints(CGPoint a, CGPoint b) {
    float deltaX = a.x - b.x;
    float deltaY = a.y - b.y;
    return sqrtf( (deltaX * deltaX) + (deltaY * deltaY) );
}

CGPoint midpointBetweenPoints(CGPoint a, CGPoint b) {
    CGFloat x = (a.x + b.x) / 2.0;
    CGFloat y = (a.y + b.y) / 2.0;
    return CGPointMake(x, y);
}

/*
 * 计算两个日期之间差多少天，
 * 返回值为负值表示startDate比endDate晚的天数，
 * 返回值为0表示startDate和endDate为同一天
 * 返回值为正值表示startDate比endDate早的天数，
 */
NSInteger getDaysBetweenDates(NSDate *startDate, NSDate *endDate) {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    unsigned int unitFlags = NSDayCalendarUnit;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:startDate  toDate:endDate  options:0];
    return [comps day];
}




@implementation MyEUtil
//如何根据HEX字符串创建UIColor, hex字符串必须必须是“0xffffff”这样的格式
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return DEFAULT_VOID_COLOR;
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return DEFAULT_VOID_COLOR;
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}


// 根据HEX值创建UIColor, hex值必须是8位16进制整数，最后两位是alpha 
+ (UIColor *) colorWithHexInteger8:(NSInteger)hexInteger {
    return [UIColor colorWithRed:((hexInteger>>24)&0xFF)/255.0 
                           green:((hexInteger>>16)&0xFF)/255.0 
                            blue:((hexInteger>>8)&0xFF)/255.0 
                           alpha:((hexInteger)&0xFF)/255.0];
}
// 根据HEX值创建UIColor, hex值必须是6位16进制整数，不包括alpha 
+ (UIColor *) colorWithHexInteger6:(NSInteger)hexInteger {
    return [UIColor colorWithRed:((hexInteger>>16)&0xFF)/255.0 
                           green:((hexInteger>>8)&0xFF)/255.0 
                            blue:((hexInteger)&0xFF)/255.0 
                           alpha:1];
}

// 根据HEX值创建各颜色分量，并返回float数组， hex值必须是8位16进制整数
// usage:  CGContextSetStrokeColor(c, HexToFloats(0x808080ff));
+ (MyERGBColorStruct) HexToFloats:(int) hexInteger {
    MyERGBColorStruct rgb;
    rgb.r = ((hexInteger>>24)&0xFF)/255.0;
    rgb.g = ((hexInteger>>16)&0xFF)/255.0;
    rgb.b = ((hexInteger>> 8)&0xFF)/255.0;
    rgb.alpha = ((hexInteger )&0xFF)/255.0;
    return rgb;
}


// 如何获取UIColor的RGBA值数组形式,每个分量都是在0.0~1.0之间取值
+ (MyERGBColorStruct) componetsWithUIColor:(UIColor *)uicolor {
    CGColorRef color = [uicolor CGColor];
    int numComponents = CGColorGetNumberOfComponents(color);
    float red = 1.0f, green = 1.0f, blue = 1.0f, alpha = 1.0f;
    if (numComponents >= 3)
    {
        const CGFloat *tmComponents = CGColorGetComponents(color);
        red = tmComponents[0];
        green = tmComponents[1];
        blue = tmComponents[2];
        if (numComponents > 3)
            alpha = tmComponents[3];
    }
    
    
    MyERGBColorStruct rgb;
    rgb.r = red;
    rgb.g = green;
    rgb.b = blue;
    rgb.alpha = alpha;
    return  rgb;
}

// 获取UIColor的16进制字符串，不包含alpha值，输出形式为@"0xffffff"
+ (NSString *) hexStringWithUIColor:(UIColor *)uicolor {
    CGColorRef color = [uicolor CGColor];
    int numComponents = CGColorGetNumberOfComponents(color);
    float red = 1.0f, green = 1.0f, blue = 1.0f;
    if (numComponents >= 3)
    {
        const CGFloat *tmComponents = CGColorGetComponents(color);
        red = tmComponents[0];
        green = tmComponents[1];
        blue = tmComponents[2];
    }
    
    return  [NSString stringWithFormat:@"%#08X", (int)(red* 0xff0000 + green * 0xff00 + blue * 0xff)];
}
// 获取UIColor的16进制数字，不包含alpha值，输出形式为0xffffff
+ (int) hexIntegerWithUIColor:(UIColor *)uicolor {
    CGColorRef color = [uicolor CGColor];
    int numComponents = CGColorGetNumberOfComponents(color);
    float red = 0.0f, green = 0.0f, blue = 0.0f;
    if (numComponents >= 3)
    {
        const CGFloat *tmComponents = CGColorGetComponents(color);
        red = tmComponents[0];
        green = tmComponents[1];
        blue = tmComponents[2];
    }
    
    return  (int)(red * 0xff0000 + green * 0xff00 + blue * 0xff);
}

// 创建16个样本颜色的UIColor对象构成的数组，这些样本颜色是不变的，用于Schedule的mode的颜色
+ (NSArray *) sampleColorArrayForScheduleMode {
    return [NSArray arrayWithObjects: 
            [MyEUtil colorWithHexInteger6:MODE_COLOR0],
            [MyEUtil colorWithHexInteger6:MODE_COLOR1],
            [MyEUtil colorWithHexInteger6:MODE_COLOR2],
            [MyEUtil colorWithHexInteger6:MODE_COLOR3],
            [MyEUtil colorWithHexInteger6:MODE_COLOR4],
            [MyEUtil colorWithHexInteger6:MODE_COLOR5],
            [MyEUtil colorWithHexInteger6:MODE_COLOR6],
            [MyEUtil colorWithHexInteger6:MODE_COLOR7],
            [MyEUtil colorWithHexInteger6:MODE_COLOR8],
            [MyEUtil colorWithHexInteger6:MODE_COLOR9],
            [MyEUtil colorWithHexInteger6:MODE_COLOR10],
            [MyEUtil colorWithHexInteger6:MODE_COLOR11],
            [MyEUtil colorWithHexInteger6:MODE_COLOR12],
            [MyEUtil colorWithHexInteger6:MODE_COLOR13],
            [MyEUtil colorWithHexInteger6:MODE_COLOR14],
            [MyEUtil colorWithHexInteger6:MODE_COLOR15],
            nil];
}

// 根据颜色取得其在Scheudle模块中mode所使用颜色的样本颜色数组的序号，返回-1表示没找到
+ (NSInteger) colorIndexInSampleColorArrayForColor:(UIColor *)color {
    int hex = [MyEUtil hexIntegerWithUIColor:color];
    if (hex == MODE_COLOR0) 
        return 0;
    if (hex == MODE_COLOR1) 
        return 1;
    if (hex == MODE_COLOR2) 
        return 2;
    if (hex == MODE_COLOR3) 
        return 3;
    if (hex == MODE_COLOR4) 
        return 4;
    if (hex == MODE_COLOR5) 
        return 5;
    if (hex == MODE_COLOR6) 
        return 6;
    if (hex == MODE_COLOR7) 
        return 7;
    if (hex == MODE_COLOR8) 
        return 8;
    if (hex == MODE_COLOR9) 
        return 9;
    if (hex == MODE_COLOR10) 
        return 10;
    if (hex == MODE_COLOR11) 
        return 11;
    if (hex == MODE_COLOR12) 
        return 12;
    if (hex == MODE_COLOR13) 
        return 13;
    if (hex == MODE_COLOR14) 
        return 14;
    if (hex == MODE_COLOR15) 
        return 15;
    return -1;
}
@end

