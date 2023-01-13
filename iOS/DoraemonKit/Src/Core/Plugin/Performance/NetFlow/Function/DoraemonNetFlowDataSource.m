//
//  DoraemonNetFlowDataSource.m
//  DoraemonKit
//
//  Created by yixiang on 2018/4/11.
//

#import "DoraemonNetFlowDataSource.h"
#import "RealmUtil.h"

@implementation DoraemonNetFlowDataSource {
    dispatch_queue_t _serialQueue;
}

static NSString *DoraemonNetFlowHttpModelTable = @"DoraemonNetFlowHttpModelTable";

+ (DoraemonNetFlowDataSource *)shareInstance{
    static dispatch_once_t once;
    static DoraemonNetFlowDataSource *instance;
    dispatch_once(&once, ^{
        instance = [[DoraemonNetFlowDataSource alloc] init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _serialQueue = dispatch_queue_create("com.wcl.DoraemonNetFlowHttpModelTableQueue", NULL);
    }
    return self;
}

- (void)addHttpModel:(DoraemonNetFlowHttpModel *)httpModel{
    [RealmUtil addOrUpdateModel:httpModel queue:_serialQueue tableName:DoraemonNetFlowHttpModelTable];
}

- (void)clear{
    [RealmUtil clearWithqueue:_serialQueue tableName:DoraemonNetFlowHttpModelTable];
}

-(NSMutableArray<DoraemonNetFlowHttpModel *> *)httpModelArray {
    return [RealmUtil modelArrayWithTableName:DoraemonNetFlowHttpModelTable objClass:DoraemonNetFlowHttpModel.self];
}

@end
