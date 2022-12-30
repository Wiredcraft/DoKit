//
//  CMMotionManager+Monitor.m
//  DoraemonKit
//
//  Created by tianYang on 2022/10/21.
//

#import "CMMotionManager+Monitor.h"
#import "Aspects.h"
#import "DoraemonMotionDataModel.h"
#import "DoraemonMotionDataSource.h"
#import "DoraemonMotionMonitorManager.h"

@implementation CMMotionManager (Monitor)

+ (void)load {
    if (!DoraemonMotionMonitorManager.shareInstance.enable) { return; }
    [CMMotionManager aspect_hookSelector:@selector(startDeviceMotionUpdates) withOptions: AspectPositionAfter usingBlock: ^(id<AspectInfo> aspectInfo) {
        CMMotionManager *manager = aspectInfo.instance;
        [self handleBeginUseMotionWith:manager];
    } error:NULL];
    [CMMotionManager aspect_hookSelector:@selector(startDeviceMotionUpdatesUsingReferenceFrame:) withOptions: AspectPositionAfter usingBlock: ^(id<AspectInfo> aspectInfo) {
        CMMotionManager *manager = aspectInfo.instance;
        [self handleBeginUseMotionWith:manager];
    } error:NULL];
    [CMMotionManager aspect_hookSelector:@selector(startDeviceMotionUpdatesToQueue:withHandler:) withOptions: AspectPositionAfter usingBlock: ^(id<AspectInfo> aspectInfo) {
        CMMotionManager *manager = aspectInfo.instance;
        [self handleBeginUseMotionWith:manager];
    } error:NULL];
    [CMMotionManager aspect_hookSelector:@selector(startDeviceMotionUpdatesUsingReferenceFrame:toQueue:withHandler:) withOptions: AspectPositionAfter usingBlock: ^(id<AspectInfo> aspectInfo) {
        CMMotionManager *manager = aspectInfo.instance;
        [self handleBeginUseMotionWith:manager];
    } error:NULL];

    [CMMotionManager aspect_hookSelector:@selector(stopDeviceMotionUpdates) withOptions: AspectPositionAfter usingBlock: ^(id<AspectInfo> aspectInfo) {
        CMMotionManager *manager = aspectInfo.instance;
        [self handleEndUseMotionWith:manager];
    } error:NULL];
}

+ (void)handleBeginUseMotionWith: (CMMotionManager *)manager {
    NSString *modelID = manager.description;
    for (DoraemonMotionDataModel *model in [DoraemonMotionDataSource shareInstance].motionUseModelArray) {
        if ([model.modelId isEqualToString:modelID]) {
            model.deviceMotionUpdateInterval = manager.deviceMotionUpdateInterval;
            return;
        }
    }
    DoraemonMotionDataModel *model = [[DoraemonMotionDataModel alloc] init];
    model.modelId = modelID;
    model.beginDate = [NSDate date];
    model.deviceMotionUpdateInterval = manager.deviceMotionUpdateInterval;
    [[DoraemonMotionDataSource shareInstance] addUseModel:model];
}

+ (void)handleEndUseMotionWith: (CMMotionManager *)manager {
    NSString *modelID = manager.description;
    for (DoraemonMotionDataModel *model in [DoraemonMotionDataSource shareInstance].motionUseModelArray) {
        if ([model.modelId isEqualToString:modelID]) {
            model.deviceMotionUpdateInterval = manager.deviceMotionUpdateInterval;
            model.endDate = [NSDate date];
            return;
        }
    }
}

@end
