//
//  DoraemonPageSpeedManager.m
//  CocoaAsyncSocket
//
//  Created by tiazhao1 on 2023/3/31.
//

#import "DoraemonPageSpeedManager.h"
#import "RealmUtil.h"

@implementation DoraemonPageSpeedManager{
    dispatch_queue_t _serialQueue;
}

static NSString *DoraemonPageSpeedModelTable = @"DoraemonPageSpeedModelTable";

+ (DoraemonPageSpeedManager *)shareInstance {
    static dispatch_once_t once;
    static DoraemonPageSpeedManager *instance;
    dispatch_once(&once, ^{
        instance = [[DoraemonPageSpeedManager alloc] init];
    });
    return instance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _serialQueue = dispatch_queue_create("com.wcl.DoraemonPageSpeedModelTableQueue", NULL);
    }
    return self;
}

- (void)addPageSpeedModel:(PageLoadSpeedModel *)model {
    [RealmUtil addOrUpdateModel:model queue:_serialQueue tableName:DoraemonPageSpeedModelTable];
}

- (NSArray *)dataForReport {
    NSArray *models = [RealmUtil modelArrayWithTableName:DoraemonPageSpeedModelTable objClass:[PageLoadSpeedModel class]];
    NSMutableArray *res = @[].mutableCopy;
    for (NSInteger i = 0; i<models.count; i++) {
        PageLoadSpeedModel *model = models[i];
        NSMutableDictionary *dic = @{}.mutableCopy;
        dic[@"pageName"] = model.pageName;
        dic[@"duration"] = @((long)(model.loadEndTime - model.loadBeginTime));
        [res addObject:dic];
    }
    return res;
}

@end
