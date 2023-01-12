//
//  DoraemonFPSDataManager.m
//  DoraemonKit
//
//  Created by Jun Ma on 2023/1/11.
//

#import "DoraemonFPSDataManager.h"
#import "DoraemonFPSModel.h"
#import "RealmUtil.h"

@implementation DoraemonFPSDataManager {
    dispatch_queue_t _serialQueue;
}

static NSString *DoraemonFPSDataTable = @"DoraemonFPSDataTable";

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static DoraemonFPSDataManager *instance;
    dispatch_once(&once, ^{
        instance = [[DoraemonFPSDataManager alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _serialQueue = dispatch_queue_create("com.wcl.DoraemonFPSModelTableQueue", NULL);
    }
    return self;
}

- (void)appendData:(DoraemonFPSModel *)data {
    [RealmUtil addOrUpdateModel:data queue:_serialQueue tableName:DoraemonFPSDataTable];
}

- (NSArray<DoraemonFPSModel *> *)allData {
    return [RealmUtil modelArrayWithTableName:DoraemonFPSDataTable objClass:DoraemonFPSModel.self];
}

- (NSArray<DoraemonFPSModel *> *)filterModelsWithBeginStamp: (NSString *)beginStamp endStamp: (NSString *)endStamp {
    NSTimeInterval begin = [beginStamp doubleValue];
    NSTimeInterval end = [endStamp doubleValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timestamp between {%@, %@}", begin, end];
    return [RealmUtil filterModelsWithPredicate:predicate tableName:DoraemonFPSDataTable objClass:DoraemonFPSModel.self];
}

@end
