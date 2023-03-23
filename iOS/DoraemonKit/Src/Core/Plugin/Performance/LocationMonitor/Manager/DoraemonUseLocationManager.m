//
//  DoraemonUseLocationManager.m
//  DoraemonKit
//
//  Created by tianYang on 2023/1/6.
//

#import "DoraemonUseLocationManager.h"
#import "RealmUtil.h"

@implementation DoraemonUseLocationManager {
    dispatch_queue_t _serialQueue;
}

static NSString *doraemonUseLocationMonitorEnableKey = @"doraemonUseLocationMonitorEnableKey";
static NSString *DoraemonUseLocationDataModelTable = @"DoraemonUseLocationDataModelTable";

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
        _serialQueue = dispatch_queue_create("com.wcl.DoraemonUseLocationDataModelTableQueue", NULL);
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        _enable = [userDefaults boolForKey:doraemonUseLocationMonitorEnableKey];
    }
    return self;
}

- (void)setEnable:(BOOL)enable {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:enable forKey:doraemonUseLocationMonitorEnableKey];
}

-(NSArray<DoraemonUseLocationDataModel *> *)useModelArray {
    return [RealmUtil modelArrayWithTableName:DoraemonUseLocationDataModelTable objClass:DoraemonUseLocationDataModel.self];
}

- (void)addUseDataModel:(DoraemonUseLocationDataModel *)useModel {
    [RealmUtil addOrUpdateModel:useModel queue:_serialQueue tableName:DoraemonUseLocationDataModelTable];
}

- (void)clear {
    [RealmUtil clearWithqueue:_serialQueue tableName:DoraemonUseLocationDataModelTable];
}

- (NSString *)toJson {
    NSMutableArray *dicArray = @[].mutableCopy;
    for (DoraemonUseLocationDataModel *model in [self useModelArray]) {
        NSMutableDictionary *dic = @{}.mutableCopy;
        dic[@"modelId"] = model.modelId;
        dic[@"timeStamp"] = @(model.timeStamp);
        dic[@"useDuration"] = @(model.useDuration);
        [dicArray addObject:dic];
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicArray options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];;
}

- (NSArray *)dicForReport {
    NSArray *modelArray = [self useModelArray];
    NSMutableArray *resArray = @[].mutableCopy;
    for (DoraemonUseLocationDataModel *model in modelArray) {
        NSMutableDictionary *dic = @{}.mutableCopy;
        dic[@"time"] = @(model.timeStamp);
        dic[@"duration"] = @(model.useDuration);
        [resArray addObject:dic];
    }
    return resArray;
}

@end
