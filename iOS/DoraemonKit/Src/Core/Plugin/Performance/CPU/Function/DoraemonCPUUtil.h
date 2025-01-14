//
//  DoraemonCPUUtil.h
//  DoraemonKit
//
//  Created by yixiang on 2018/1/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DoraemonCPUUsageCallStackModel.h"

@interface DoraemonCPUUtil : NSObject

//获取CPU使用率
+ (CGFloat)cpuUsageForApp;
+ (nullable DoraemonCPUUsageCallStackModel *)cpuUsageAndCallstackForThread;

@end
