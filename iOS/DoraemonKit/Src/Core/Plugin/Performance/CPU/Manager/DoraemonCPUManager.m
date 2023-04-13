//
//  DoraemonCPUManager.m
//  CocoaAsyncSocket
//
//  Created by tiazhao1 on 2023/2/24.
//

#import "DoraemonCPUManager.h"
#import "DoraemonCPUUtil.h"
#import "RealmUtil.h"

@implementation DoraemonCPUUsageModel
+ (NSString *)primaryKey {
    return @"uid";
}
@end

@implementation DoraemonCPUManager {
    dispatch_queue_t _serialQueue;
}

static NSString *DoraemonUseCPUDataModelTable = @"DoraemonUseCPUDataModelTable";

+ (DoraemonCPUManager *)shareInstance {
    static dispatch_once_t once;
    static DoraemonCPUManager *instance;
    dispatch_once(&once, ^{
        instance = [[DoraemonCPUManager alloc] init];
    });
    return instance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _serialQueue = dispatch_queue_create("com.wcl.DoraemonUseCPUDataModelTableQueue", NULL);
        [self startRecord];
    }
    return self;
}

- (void)startRecord {
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(customThreadEntryPoint:) object:nil];
    [thread start];
}

- (void)customThreadEntryPoint:(id)object {
    @autoreleasepool {
        [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
    }
}

- (void)timerFired:(NSTimer *)timer {
    CGFloat cpuUsage = [DoraemonCPUUtil cpuUsageForApp];
    if (cpuUsage * 100 > 100) {
        cpuUsage = 100;
    } else if (cpuUsage * 100 < 0){
        cpuUsage = 0;
    } else {
        cpuUsage = cpuUsage * 100;
    }

    [self addCpuUsage:cpuUsage];
}

- (void)addCpuUsage: (CGFloat)rate {
    DoraemonCPUUsageModel *model = [[DoraemonCPUUsageModel alloc] init];
    model.uid = [[NSUUID UUID] UUIDString];
    model.timeStamp = (long)[[NSDate date] timeIntervalSince1970] * 1000;
    model.cpuUsageRate = (long)rate;
    [RealmUtil addOrUpdateModel:model queue:_serialQueue tableName:DoraemonUseCPUDataModelTable];
}

- (NSDictionary *)dataForReport {
    NSArray<DoraemonCPUUsageModel *> *array = [RealmUtil modelArrayWithTableName:DoraemonUseCPUDataModelTable objClass:DoraemonCPUUsageModel.class];
    NSMutableDictionary *res = @{}.mutableCopy;
    NSMutableArray *itemList = @[].mutableCopy;
    NSMutableArray *temporaryAnomalies = @[].mutableCopy;
    NSMutableArray *anomalies = @[].mutableCopy;
    for (NSInteger i = 0; i < array.count; i++) {
        DoraemonCPUUsageModel *model = array[i];
        NSMutableDictionary *dic = @{}.mutableCopy;
        dic[@"time"] = @((long)model.timeStamp);
        dic[@"usageRate"] = @(model.cpuUsageRate);
        [itemList addObject:dic];

        if (i >= 4) {
            NSMutableArray<DoraemonCPUUsageModel *> *temArray = [array subarrayWithRange:NSMakeRange(i-4, 5)];
            long reduceAvg = [self avgRateOfModelArray:temArray];
            if (reduceAvg > 50) {
                long reduceMax = [self maxRateOfModelArray:temArray];
                NSMutableDictionary *item = @{}.mutableCopy;
                item[@"beginEndTime"] = [NSString stringWithFormat:@"%ld-%ld", temArray.lastObject.timeStamp, temArray.firstObject.timeStamp];
                item[@"averageCpuUsageRate"] = @(reduceAvg);
                item[@"maxCpuUsageRate"] = @(reduceMax);
                [temporaryAnomalies addObject:item];
            }
        }
        if (i >= 14) {
            NSMutableArray<DoraemonCPUUsageModel *> *temArray = [array subarrayWithRange:NSMakeRange(i-14, 15)];
            long reduceAvg = [self avgRateOfModelArray:temArray];
            if (reduceAvg > 30) {
                long reduceMax = [self maxRateOfModelArray:temArray];
                NSMutableDictionary *item = @{}.mutableCopy;
                item[@"beginEndTime"] = [NSString stringWithFormat:@"%ld-%ld", temArray.lastObject.timeStamp, temArray.firstObject.timeStamp];
                item[@"averageCpuUsageRate"] = @(reduceAvg);
                item[@"maxCpuUsageRate"] = @(reduceMax);
                [anomalies addObject:item];
            }
        }
    }

    // sort
    NSComparator cmpr = ^NSComparisonResult(NSDictionary*  _Nonnull obj1, NSDictionary*  _Nonnull obj2) {
        long num1 = [[obj1 objectForKey:@"averageCpuUsageRate"] longValue];
        long num2 = [[obj2 objectForKey:@"averageCpuUsageRate"] longValue];
        if (num1 < num2) {
            return NSOrderedDescending;
        } else if (num1 > num2) {
            return NSOrderedAscending;
        } else {
            return NSOrderedSame;
        }
    };
    temporaryAnomalies = [temporaryAnomalies sortedArrayUsingComparator: cmpr];
    anomalies = [anomalies sortedArrayUsingComparator: cmpr];

    res[@"itemList"] = itemList;
    res[@"temporaryAnomalies"] = temporaryAnomalies.count > 5 ? [temporaryAnomalies subarrayWithRange:NSMakeRange(0, 5)] : temporaryAnomalies;
    res[@"anomalies"] = anomalies.count > 5 ? [anomalies subarrayWithRange:NSMakeRange(0, 5)] : anomalies;;
    return res;
}

- (long)avgRateOfModelArray: (NSArray<DoraemonCPUUsageModel *> *)modelArray {
    long sum = 0;
    for (DoraemonCPUUsageModel *model in modelArray) {
        sum += model.cpuUsageRate;
    }
    return (long)(sum / modelArray.count);
}

- (long)maxRateOfModelArray: (NSArray<DoraemonCPUUsageModel *> *)modelArray {
    long max = 0;
    for (DoraemonCPUUsageModel *model in modelArray) {
        if (max < model.cpuUsageRate) max = model.cpuUsageRate;
    }
    return max;
}

@end
