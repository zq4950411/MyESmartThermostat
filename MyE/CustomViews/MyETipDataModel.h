//
//  MyETipDataModel.h
//  MyE
//
//  Created by Ye Yuan on 6/26/12.
//  Copyright (c) 2012 MyEnergy Domain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyETipDataModel : NSObject {
    NSString *_key;// key/id used to identify this tip data, it will be used to save tip show flag in NSUserDefaults
    NSString *_title;
    NSString *_message;
}
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;

+(MyETipDataModel *)tipDataModelWithKey:(NSString *)key title:(NSString *)title message:(NSString *)message;
@end
