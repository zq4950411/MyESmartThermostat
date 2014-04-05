//
//  Utils.h
//  CIBN
//
//  Created by penghui on 11-6-10.
//  Copyright 2011 #. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

@interface Utils : NSObject 
{

}
+(NSArray *) getUEArray;
//调整图像方向
+(UIImage *) rotateImage:(UIImage *)image;

//+(NSMutableArray *) parseHTML2Array:(NSString *) webSite;

+(CATransition *) createAnimatioin:(NSString *) animationName duration:(float) time subtype:(NSString *) subtype;

+(void) alertWithMessage:(NSString*) message;

+(void) alertWithMessage:(NSString*) message withDelegate:(id <UIAlertViewDelegate>) delegate;

+(NSString *) writeImageToFile:(NSString *) fileName data:(NSData *) data;

+(BOOL) removeFileName:(NSString *) fileName;

+(UIImage *) getImageFromFile:(NSString *) fileName;

+(UIImage *) getFixedImage:(UIImage *) image width:(int) w height:(int) h;

+(id) getDataFromFile:(NSString *) fileName;

+(void) writeToDocumentDomain:(NSString *) fileName withData:(id) datas;

+(NSString *) getNowDateString;

+(NSString *) getNowDate;

+(NSString *) getTodayString;

+(NSDate *) getDateFromString:(NSString *) dateString;

+(NSData *) getDataFromURL:(NSString *) urlString;

+(void) makePretyView:(UIView *) view;

+(UILabel *) createLabel;

+(void) setLabelText:(NSString *) text parentView:(UIView *) view;

+(void) setULabelShade:(UILabel *) label;

+(void) setULabelShade:(UILabel *) label withShadeColor:(UIColor *) color andFont:(UIFont *) font;

+(void) setFemaleLabel:(UILabel *) label;

+(UIColor *) colorWithHexString: (NSString *) string;


+(int) getWordsLength:(NSString *) word;

+(NSString *) getUUIDString;

+(NSString *) writeImageToDocument:(NSString *) docName fileName:(NSString *) fileName data:(NSData *) data;

+(NSString *) writeImageToDocument:(NSString *) docName fileName:(NSString *) fileName image:(UIImage *) img;

+(BOOL) writeImageToDocument:(NSString *) absoultePath image:(UIImage *) img;

+(UIImage *) getImageFromDocument:(NSString *) docName fileName:(NSString *) fileName;

+(NSMutableDictionary *) getDictionaryFromObject:(id) object;

+ (BOOL) isNetConnected;

+(BOOL) isEmail:(NSString *) string;

+(NSString *) getStringFromDate:(NSDate *) date;

@end
