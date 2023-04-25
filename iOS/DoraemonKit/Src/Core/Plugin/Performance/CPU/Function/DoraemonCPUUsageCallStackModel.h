//
//  DoraemonCPUUsageCallStackModel.h
//  DoraemonKit
//
//  Created by junma1 on 2023/4/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoraemonCPUUsageCallStackModel : NSObject

// Total CPU usage for the app
@property(nonatomic, assign) float totalUsage;

// CPU usage for the thread which consumes most of CPU
@property(nonatomic, assign) float maxUsageOfThread;
// Call stack for the thread which consumes most of CPU
@property(nonatomic, copy, nullable) NSString *callstackOfThread;

@end

NS_ASSUME_NONNULL_END
