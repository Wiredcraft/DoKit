//
//  DoraemonCPUUsageCallStackModel.m
//  DoraemonKit
//
//  Created by junma1 on 2023/4/19.
//

#import "DoraemonCPUUsageCallStackModel.h"

@implementation DoraemonCPUUsageCallStackModel

- (instancetype)init {
    if (self = [super init]) {
        self.totalUsage = 0;
        self.maxUsageOfThread = 0;
        self.callstackOfThread = nil;
    }
    
    return self;
}

@end
