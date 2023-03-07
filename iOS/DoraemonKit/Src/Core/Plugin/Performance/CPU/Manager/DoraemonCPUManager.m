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
    dispatch_semaphore_t _semaphore;
    NSMutableArray *_temCpuUsageArray;
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
        _semaphore = dispatch_semaphore_create(1);
        _temCpuUsageArray = @[].mutableCopy;
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
    // get cpu usage rate
    CGFloat cpuUsage = [DoraemonCPUUtil cpuUsageForApp];
    if (cpuUsage * 100 > 100) {
        cpuUsage = 100;
    }else{
        cpuUsage = cpuUsage * 100;
    }

    [self addCpuUsage:cpuUsage];
}

- (void)addCpuUsage: (CGFloat)rate {
    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    [_temCpuUsageArray addObject:@(rate)];
    dispatch_semaphore_signal(_semaphore);

    if (_temCpuUsageArray.count == 10) {
        NSNumber *reduceAvg = [_temCpuUsageArray valueForKeyPath:@"@avg.self"];
        NSNumber *reduceMax = [_temCpuUsageArray valueForKeyPath:@"@max.self"];

        DoraemonCPUUsageModel *model = [[DoraemonCPUUsageModel alloc] init];
        model.uid = [[NSUUID UUID] UUIDString];
        model.timeStamp = [[NSDate date] timeIntervalSince1970];
        model.averageCpuUsageRate = [reduceAvg floatValue];
        model.maxCpuUsageRate = [reduceMax floatValue];
        [RealmUtil addOrUpdateModel:model queue:_serialQueue tableName:DoraemonUseCPUDataModelTable];

        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
        [_temCpuUsageArray removeAllObjects];
        dispatch_semaphore_signal(_semaphore);
    }
}

- (NSArray *)dataForReport {
    NSArray<DoraemonCPUUsageModel *> *array = [RealmUtil modelArrayWithTableName:DoraemonUseCPUDataModelTable objClass:DoraemonCPUUsageModel.class];
    NSMutableArray *resArray = @[].mutableCopy;
    for (DoraemonCPUUsageModel *model in array) {
        NSMutableDictionary *dic = @{}.mutableCopy;
        dic[@"uid"] = model.uid;
        dic[@"timeStamp"] = @(model.timeStamp);
        dic[@"averageCpuUsageRate"] = @(model.averageCpuUsageRate);
        dic[@"maxCpuUsageRate"] = @(model.maxCpuUsageRate);
        [resArray addObject:dic];
    }
    return resArray;
}

@end
