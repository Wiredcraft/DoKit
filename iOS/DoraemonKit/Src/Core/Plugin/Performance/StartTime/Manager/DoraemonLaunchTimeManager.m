//
//  DoraemonLaunchTimeManager.m
//  CocoaAsyncSocket
//
//  Created by tiazhao1 on 2023/2/7.
//

#import "DoraemonLaunchTimeManager.h"
#import "RealmUtil.h"

@implementation DoraemonLaunchTimeManager{
    dispatch_queue_t _serialQueue;
}

static NSString *DoraemonLaunchTimeDataTable = @"DoraemonLaunchTimeDataTable";

+ (DoraemonLaunchTimeManager *)shareInstance{
    static dispatch_once_t once;
    static DoraemonLaunchTimeManager *instance;
    dispatch_once(&once, ^{
        instance = [[DoraemonLaunchTimeManager alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _serialQueue = dispatch_queue_create("com.wcl.DoraemonLaunchTimeDataTableQueue", NULL);
    }
    return self;
}

-(NSArray<DoraemonLaunchTimeModel *> *)launchTimeModelArray {
    return [RealmUtil modelArrayWithTableName:DoraemonLaunchTimeDataTable objClass:DoraemonLaunchTimeModel.self];
}

- (NSArray<DoraemonLaunchTimeModel *> *)filterModelsWithBeginStamp: (NSString *)beginStamp endStamp: (NSString *)endStamp {
    NSTimeInterval begin = [beginStamp doubleValue];
    NSTimeInterval end = [endStamp doubleValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timeStamp between {%@, %@}", begin, end];
    return [RealmUtil filterModelsWithPredicate:predicate tableName:DoraemonLaunchTimeDataTable objClass:DoraemonLaunchTimeModel.self];
}

- (void)addOrUpdateUseModel:(DoraemonLaunchTimeModel *)timeModel {
    [RealmUtil addOrUpdateModel:timeModel queue:_serialQueue tableName:DoraemonLaunchTimeDataTable];
}

-(NSArray<NSDictionary *> *)modelDics {
    NSMutableArray *dicArray = @[].mutableCopy;
    for (DoraemonLaunchTimeModel *model in self.launchTimeModelArray) {
        NSMutableDictionary *dic = @{}.mutableCopy;
        dic[@"uid"] = model.uid;
        dic[@"time"] = @((long)model.time);
        dic[@"launchCost"] = @((long)model.launchCost);
        [dicArray addObject:dic];
    }
    return dicArray;
}

- (void)clear {
    [RealmUtil clearWithqueue:_serialQueue tableName:DoraemonLaunchTimeDataTable];
}

@end
