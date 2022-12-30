//
//  DoraemonMotionMonitorManager.m
//  CocoaAsyncSocket
//
//  Created by tianYang on 2022/11/11.
//

#import "DoraemonMotionMonitorManager.h"
#import "DoraemonMotionDataSource.h"

@implementation DoraemonMotionMonitorManager

static NSString *doraemonMotionMonitorEnableKey = @"doraemonMotionMonitorEnableKey";

+ (DoraemonMotionMonitorManager *)shareInstance {
    static dispatch_once_t once;
    static DoraemonMotionMonitorManager *instance;
    dispatch_once(&once, ^{
        instance = [[DoraemonMotionMonitorManager alloc] init];
    });
    return instance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        _enable = [userDefaults boolForKey:doraemonMotionMonitorEnableKey];
    }
    return self;
}

- (void)setEnable:(BOOL)enable {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:enable forKey:doraemonMotionMonitorEnableKey];
}

- (NSInteger)useMotionCount {
    return DoraemonMotionDataSource.shareInstance.motionUseModelArray.count;
}

- (NSInteger)useMotionTime {
    NSInteger time = 0;
    for (DoraemonMotionDataModel *model in DoraemonMotionDataSource.shareInstance.motionUseModelArray) {
        time += model.useTime;
    }
    return time;
}

@end

