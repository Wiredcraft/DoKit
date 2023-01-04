//
//  DLADDRParser.m
//  DoraemonKit
//
//  Created by tianYang on 2023/1/3.
//

#import "DLADDRParser.h"

@implementation DLADDR
-(instancetype)initWithDepth: (NSInteger)depth fname: (NSString *)fname sname: (NSString *)sname {
    self = [super init];
    if (self) {
        _depth = depth;
        _fname = fname;
        _sname = sname;
    }
    return self;
}
@end

@implementation DLADDRParser
+ (DLADDR *)parseWithInput: (NSString *)input {
    if (input == nil || input.length <= 0) { return nil; }
    NSPredicate * predicate = [NSPredicate predicateWithBlock:^BOOL(NSString *  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return evaluatedObject.length > 0;
    }];
    NSArray<NSString *> *array = [[input componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] filteredArrayUsingPredicate: predicate];
    NSString *depthNumberString = [array firstObject];
    NSString *fname = [array objectAtIndex:1];

    NSMutableArray *marray = [array mutableCopy];
    if (marray.count >= 3) [marray removeObjectsInRange:NSMakeRange(0, 3)];
    if (marray.count >= 2) [marray removeObjectsInRange:NSMakeRange(marray.count - 2, 2)];
    NSString *sname = [marray componentsJoinedByString:@" "];
    return [[DLADDR alloc] initWithDepth:[depthNumberString integerValue] fname:fname sname:sname];
}
@end
