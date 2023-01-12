//
//  DoraemonMotionDataSource.m
//  CocoaAsyncSocket
//
//  Created by tianYang on 2022/11/4.
//

#import "DoraemonMotionDataSource.h"
#import <Realm/Realm.h>>

@implementation DoraemonMotionDataSource {
    dispatch_queue_t _serialQueue;
    RLMRealmConfiguration *_realmConfig;
}

static NSString *DoraemonMotionDataTable = @"DoraemonMotionDataTable";

+ (DoraemonMotionDataSource *)shareInstance{
    static dispatch_once_t once;
    static DoraemonMotionDataSource *instance;
    dispatch_once(&once, ^{
        instance = [[DoraemonMotionDataSource alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _serialQueue = dispatch_queue_create("com.wcl.DoraemonMotionDataTableQueue", NULL);
        NSString *tableName = DoraemonMotionDataTable;
        RLMRealmConfiguration *configuration = [RLMRealmConfiguration defaultConfiguration];
        configuration.fileURL = [[[configuration.fileURL URLByDeletingLastPathComponent]
                                 URLByAppendingPathComponent:tableName]
                                 URLByAppendingPathExtension:@"realm"];
        _realmConfig = configuration;
    }
    return self;
}

-(NSArray<DoraemonMotionDataModel *> *)motionUseModelArray {
    NSError *error = nil;
    RLMRealm *realm = [RLMRealm realmWithConfiguration:_realmConfig error:&error];
    if (error) {
        return @[];
    }
    return [DoraemonMotionDataModel allObjectsInRealm:realm];
}

- (NSArray<DoraemonMotionDataModel *> *)filterModelsWithBeginStamp: (NSString *)beginStamp endStamp: (NSString *)endStamp {
    NSTimeInterval begin = [beginStamp doubleValue];
    NSTimeInterval end = [endStamp doubleValue];
    NSError *error = nil;
    RLMRealm *realm = [RLMRealm realmWithConfiguration:_realmConfig error:&error];
    if (error) {
        return @[];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timeStamp between {%@, %@}", begin, end];
    return [DoraemonMotionDataModel objectsInRealm:realm withPredicate:predicate];
}

- (void)addOrUpdateUseModel:(DoraemonMotionDataModel *)useModel {
    dispatch_async(_serialQueue, ^{
        NSError *error = nil;
        RLMRealm *realm = [RLMRealm realmWithConfiguration:_realmConfig error:&error];
        [realm transactionWithBlock:^{
            if (useModel) [realm addOrUpdateObject:useModel];
        }];
    });
}

- (NSString *)toJson {
    NSMutableArray *dicArray = [self modelDics];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicArray options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];;
}

-(NSArray<NSDictionary *> *)modelDics {
    NSMutableArray *dicArray = @[].mutableCopy;
    for (DoraemonMotionDataModel *model in self.motionUseModelArray) {
        NSMutableDictionary *dic = @{}.mutableCopy;
        dic[@"id"] = model.modelId;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        NSString *beginDateString = [dateFormatter stringFromDate:model.beginDate];
        NSString *endDateString = [dateFormatter stringFromDate:model.endDate];
        dic[@"beginDate"] = beginDateString;
        dic[@"endDate"] = endDateString;
        dic[@"deviceMotionUpdateInterval"] = @(model.deviceMotionUpdateInterval);
        dic[@"callerInfo"] = model.callerInfo;
        [dicArray addObject:dic];
    }
    return dicArray;
}

@end
