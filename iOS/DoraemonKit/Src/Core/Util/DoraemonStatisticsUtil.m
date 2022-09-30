//
//  DoraemonStatisticsUtil.m
//  DoraemonKit
//
//  Created by yixiang on 2018/12/10.
//

#import "DoraemonStatisticsUtil.h"
#import "DoraemonDefine.h"

@implementation DoraemonStatisticsUtil

+ (nonnull DoraemonStatisticsUtil *)shareInstance{
    static dispatch_once_t once;
    static DoraemonStatisticsUtil *instance;
    dispatch_once(&once, ^{
        instance = [[DoraemonStatisticsUtil alloc] init];
    });
    return instance;
}

- (void)upLoadUserInfo{
    
}

@end
