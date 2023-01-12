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
#import "DoraemonBacktraceLogger.h"
#import "DLADDRParser.h"

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
            DoraemonMotionDataModel *updateModel = [[DoraemonMotionDataModel alloc] initWithValue:model];
            updateModel.deviceMotionUpdateInterval = manager.deviceMotionUpdateInterval;
            [[DoraemonMotionDataSource shareInstance] addOrUpdateUseModel:updateModel];
            return;
        }
    }
    DoraemonMotionDataModel *model = [[DoraemonMotionDataModel alloc] init];
    model.modelId = modelID;
    model.beginDate = [NSDate date];
    model.timeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
    model.deviceMotionUpdateInterval = manager.deviceMotionUpdateInterval;
    NSString *namespace = [NSBundle mainBundle].infoDictionary[@"CFBundleExecutable"];
    NSArray * callBack = [NSThread callStackSymbols];
    for (NSInteger i = 0; i < callBack.count; i++) {
        NSString *track = callBack[i];
        DLADDR *dladd = [DLADDRParser parseWithInput:track];
        if (dladd && [namespace isEqualToString:dladd.fname]) {
            model.callerInfo = dladd.sname;
            break;
        }
    }
    [[DoraemonMotionDataSource shareInstance] addOrUpdateUseModel:model];
}

+ (void)handleEndUseMotionWith: (CMMotionManager *)manager {
    NSString *modelID = manager.description;
    for (DoraemonMotionDataModel *model in [DoraemonMotionDataSource shareInstance].motionUseModelArray) {
        if ([model.modelId isEqualToString:modelID]) {
            DoraemonMotionDataModel *updateModel = [[DoraemonMotionDataModel alloc] initWithValue:model];
            updateModel.deviceMotionUpdateInterval = manager.deviceMotionUpdateInterval;
            updateModel.endDate = [NSDate date];
            [[DoraemonMotionDataSource shareInstance] addOrUpdateUseModel:updateModel];
            return;
        }
    }
}

+ (NSString *)getProjectName {
    NSString *namespace = [NSBundle mainBundle].infoDictionary[@"CFBundleExecutable"];
    return namespace;
}

@end
