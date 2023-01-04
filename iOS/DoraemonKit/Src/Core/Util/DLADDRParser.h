//
//  DLADDRParser.h
//  DoraemonKit
//
//  Created by tianYang on 2023/1/3.
//

#import <Foundation/Foundation.h>

@interface DLADDR : NSObject

@property (nonatomic, assign) NSInteger depth;
@property (nonatomic, assign) NSString* fname;
@property (nonatomic, assign) NSString* sname;

@end

@interface DLADDRParser : NSObject
+ (DLADDR *)parseWithInput: (NSString *)input;
@end
