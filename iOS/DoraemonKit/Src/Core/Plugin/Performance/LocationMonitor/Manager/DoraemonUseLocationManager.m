//
//  DoraemonUseLocationManager.m
//  DoraemonKit
//
//  Created by tianYang on 2023/1/6.
//

#import "DoraemonUseLocationManager.h"

@implementation DoraemonUseLocationManager {
    dispatch_semaphore_t semaphore;
}

static NSString *doraemonUseLocationMonitorEnableKey = @"doraemonUseLocationMonitorEnableKey";

+ (DoraemonUseLocationManager *)shareInstance {
    static dispatch_once_t once;
    static DoraemonUseLocationManager *instance;
    dispatch_once(&once, ^{
        instance = [[DoraemonUseLocationManager alloc] init];
    });
    return instance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _useModelArray = @[].mutableCopy;
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        _enable = [userDefaults boolForKey:doraemonUseLocationMonitorEnableKey];
    }
    return self;
}

- (void)setEnable:(BOOL)enable {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:enable forKey:doraemonUseLocationMonitorEnableKey];
}

- (void)addUseDataModel:(DoraemonUseLocationDataModel *)useModel {
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [_useModelArray insertObject:useModel atIndex:0];
    dispatch_semaphore_signal(semaphore);
}

- (void)clear {
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [_useModelArray removeAllObjects];
    dispatch_semaphore_signal(semaphore);
}

- (NSString *)toJson {
    NSMutableArray *dicArray = @[].mutableCopy;
    for (DoraemonUseLocationDataModel *model in _useModelArray) {
        NSMutableDictionary *dic = @{}.mutableCopy;
        dic[@"timeStamp"] = @(model.timeStamp);
        dic[@"useDuration"] = @(model.useDuration);
        dic[@"distanceFilter"] = @(model.distanceFilter);
        dic[@"desiredAccuracy"] = @(model.desiredAccuracy);
        dic[@"longitude"] = @(model.longitude);
        dic[@"latitude"] = @(model.latitude);
        [dicArray addObject:dic];
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicArray options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];;
}

@end
