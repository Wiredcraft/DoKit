//
//  DoraemonANRManager.m
//  DoraemonKit
//
//  Created by yixiang on 2018/6/14.
//

#import "DoraemonANRManager.h"
#import "DoraemonCacheManager.h"
#import "DoraemonANRTracker.h"
#import "DoraemonMemoryUtil.h"
#import "DoraemonAppInfoUtil.h"
#import "Doraemoni18NUtil.h"
#import "DoraemonANRTool.h"
#import "DoraemonHealthManager.h"
#import "DotaemonANRModel.h"
#import "RealmUtil.h"
#import "UIViewController+Doraemon.h"

//默认超时间隔
static CGFloat const kDoraemonBlockMonitorTimeInterval = 0.2f;

@interface DoraemonANRManager()

@property (nonatomic, strong) DoraemonANRTracker *doraemonANRTracker;
@property (nonatomic, copy) DoraemonANRManagerBlock block;

@end

@implementation DoraemonANRManager{
    dispatch_queue_t _serialQueue;
}

static NSString *DoraemonANRDataModelTable = @"DoraemonANRDataModelTable";

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _serialQueue = dispatch_queue_create("com.wcl.DoraemonANRDataModelTableQueue", NULL);
        _doraemonANRTracker = [[DoraemonANRTracker alloc] init];
        _timeOut = kDoraemonBlockMonitorTimeInterval;
        _anrTrackOn = [DoraemonCacheManager sharedInstance].anrTrackSwitch;
        [self start];
    }
    
    return self;
}

- (void)start {
    __weak typeof(self) weakSelf = self;
    [_doraemonANRTracker startWithThreshold:self.timeOut handler:^(NSDictionary *info) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf dumpWithInfo:info];
        });
    }];
}

- (void)dumpWithInfo:(NSDictionary *)info {
    long duration = [[info objectForKey:@"duration"] longLongValue];
    if (![info isKindOfClass:[NSDictionary class]] || duration <= 200) {
        return;
    }

    NSString *className = NSStringFromClass([[UIViewController topViewControllerForKeyWindow] class]);
    DotaemonANRModel *model = [[DotaemonANRModel alloc] init];
    model.uid = [[NSUUID UUID] UUIDString];
    model.duration = duration;
    model.info = className;
    [RealmUtil addOrUpdateModel:model queue:_serialQueue tableName:DoraemonANRDataModelTable];

//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[DoraemonHealthManager sharedInstance] addANRInfo:info];
//        if (self.block) {
//            self.block(info);
//        }
//        [DoraemonANRTool saveANRInfo:info];
//    });

}

- (void)addANRBlock:(DoraemonANRManagerBlock)block{
    self.block = block;
}


- (void)dealloc {
    [self stop];
}

- (void)stop {
    [self.doraemonANRTracker stop];
}

- (void)setAnrTrackOn:(BOOL)anrTrackOn {
    _anrTrackOn = anrTrackOn;
    [[DoraemonCacheManager sharedInstance] saveANRTrackSwitch:anrTrackOn];
}

- (NSArray*)dataForReport {
    NSArray<DotaemonANRModel *> *modelArray = (NSArray<DotaemonANRModel *> *)[RealmUtil modelArrayWithTableName:DoraemonANRDataModelTable objClass:DotaemonANRModel.class];

    NSMutableDictionary *dic = @{}.mutableCopy;
    for (DotaemonANRModel *model in modelArray) {
        NSString *modelKey = model.info;
        if (!modelKey) modelKey = @"no info";
        if ([dic objectForKey:modelKey]) {
            NSMutableArray *values = dic[model.info];
            [values addObject:model];
            dic[modelKey] = values;
        } else {
            NSMutableArray *values = @[].mutableCopy;
            [values addObject:model];
            dic[modelKey] = values;
        }
    }

    NSMutableArray *res = @[].mutableCopy;
    for (NSMutableArray *models in dic.allValues) {
        if (!models.count) continue;
        long sum = 0;
        for (DotaemonANRModel *model in models) {
            sum += model.duration;
        }
        long avgDuration = (long)(sum / models.count);

        NSMutableDictionary *item = @{}.mutableCopy;
        item[@"duration"] = @(avgDuration);
        item[@"count"] = @(models.count);
        item[@"info"] = [(DotaemonANRModel *)models.firstObject info];
        [res addObject:item];
    }

    [res sortUsingComparator:^NSComparisonResult(NSDictionary*  _Nonnull obj1, NSDictionary*  _Nonnull obj2) {
        long duration1 = [[obj1 objectForKey:@"duration"] longLongValue];
        long duration2 = [[obj2 objectForKey:@"duration"] longLongValue];
        if (duration1 > duration2) {
            return NSOrderedAscending;
        } else if (duration1 < duration2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];

    if (res.count > 5) {
        return [res subarrayWithRange:NSMakeRange(0, 5)];
    }
    return res;
}

- (void)clearData {
    [RealmUtil clearWithqueue:_serialQueue tableName:DoraemonANRDataModelTable];
}

@end
