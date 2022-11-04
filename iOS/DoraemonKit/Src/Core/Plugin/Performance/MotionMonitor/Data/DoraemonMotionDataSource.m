//
//  DoraemonMotionDataSource.m
//  CocoaAsyncSocket
//
//  Created by tianYang on 2022/11/4.
//

#import "DoraemonMotionDataSource.h"

@implementation DoraemonMotionDataSource {
    dispatch_semaphore_t semaphore;
}
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
        _motionUseModelArray = [NSMutableArray array];
        semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)addUseModel:(DoraemonMotionDataModel *)useModel {
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [_motionUseModelArray insertObject:useModel atIndex:0];
    dispatch_semaphore_signal(semaphore);
}

- (void)clear{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    [_motionUseModelArray removeAllObjects];
    dispatch_semaphore_signal(semaphore);
}

@end
