//
//  DoraemonFPSDataManager.m
//  DoraemonKit
//
//  Created by Jun Ma on 2023/1/11.
//

#import "DoraemonFPSDataManager.h"
#import "DoraemonFPSModel.h"

@interface DoraemonFPSDataManager ()

@property(nonatomic, copy) dispatch_semaphore_t semaphore;
@property(nonatomic, strong) NSMutableArray<DoraemonFPSModel *> *models;

@end

@implementation DoraemonFPSDataManager

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
        _semaphore = dispatch_semaphore_create(1);
        _models = @[].mutableCopy;
    }
    return self;
}

- (void)appendData:(DoraemonFPSModel *)data {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    [self.models addObject:data];
    dispatch_semaphore_signal(self.semaphore);
}

- (NSArray<DoraemonFPSModel *> *)allData {
    return self.models.copy;
}

@end
