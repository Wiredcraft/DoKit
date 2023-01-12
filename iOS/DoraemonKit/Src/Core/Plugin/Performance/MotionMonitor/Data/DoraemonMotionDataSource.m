//
//  DoraemonMotionDataSource.m
//  CocoaAsyncSocket
//
//  Created by tianYang on 2022/11/4.
//

#import "DoraemonMotionDataSource.h"
#import "RealmUtil.h"

@implementation DoraemonMotionDataSource {
    dispatch_queue_t _serialQueue;
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
    }
    return self;
}

-(NSArray<DoraemonMotionDataModel *> *)motionUseModelArray {
    return [RealmUtil modelArrayWithTableName:DoraemonMotionDataTable objClass:DoraemonMotionDataModel.self];
}

- (NSArray<DoraemonMotionDataModel *> *)filterModelsWithBeginStamp: (NSString *)beginStamp endStamp: (NSString *)endStamp {
    NSTimeInterval begin = [beginStamp doubleValue];
    NSTimeInterval end = [endStamp doubleValue];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timeStamp between {%@, %@}", begin, end];
    return [RealmUtil filterModelsWithPredicate:predicate tableName:DoraemonMotionDataTable objClass:DoraemonMotionDataModel.self];
}

- (void)addOrUpdateUseModel:(DoraemonMotionDataModel *)useModel {
    [RealmUtil addOrUpdateModel:useModel queue:_serialQueue tableName:DoraemonMotionDataTable];
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
