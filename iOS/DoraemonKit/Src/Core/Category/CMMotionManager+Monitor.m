//
//  CMMotionManager+Monitor.m
//  DoraemonKit
//
//  Created by tianYang on 2022/10/21.
//

#import "CMMotionManager+Monitor.h"
#import "Aspects.h"

@implementation CMMotionManager (Monitor)

+ (void)load {
    [CMMotionManager aspect_hookSelector:@selector(startDeviceMotionUpdates) withOptions: AspectPositionAfter usingBlock: ^(id<AspectInfo> aspectInfo) {
        CMMotionManager *manager = aspectInfo.instance;
        NSLog(@"勾住了 陀螺仪开始运行 %@", [NSDate date]);
        NSLog(@"UpdateInterval = %f", manager.deviceMotionUpdateInterval);
    } error:NULL];
    [CMMotionManager aspect_hookSelector:@selector(startDeviceMotionUpdatesUsingReferenceFrame:) withOptions: AspectPositionAfter usingBlock: ^(id<AspectInfo> aspectInfo) {
        CMMotionManager *manager = aspectInfo.instance;
        NSLog(@"勾住了 陀螺仪开始运行 %@", [NSDate date]);
        NSLog(@"UpdateInterval = %f", manager.deviceMotionUpdateInterval);
    } error:NULL];
    [CMMotionManager aspect_hookSelector:@selector(startDeviceMotionUpdatesToQueue:withHandler:) withOptions: AspectPositionAfter usingBlock: ^(id<AspectInfo> aspectInfo) {
        CMMotionManager *manager = aspectInfo.instance;
        NSLog(@"勾住了 陀螺仪开始运行 %@", [NSDate date]);
        NSLog(@"UpdateInterval = %f", manager.deviceMotionUpdateInterval);
    } error:NULL];
    [CMMotionManager aspect_hookSelector:@selector(startDeviceMotionUpdatesUsingReferenceFrame:toQueue:withHandler:) withOptions: AspectPositionAfter usingBlock: ^(id<AspectInfo> aspectInfo) {
        CMMotionManager *manager = aspectInfo.instance;
        NSLog(@"勾住了 陀螺仪开始运行 %@", [NSDate date]);
        NSLog(@"UpdateInterval = %f", manager.deviceMotionUpdateInterval);
    } error:NULL];

    [CMMotionManager aspect_hookSelector:@selector(stopDeviceMotionUpdates) withOptions: AspectPositionAfter usingBlock: ^(id<AspectInfo> aspectInfo) {
        CMMotionManager *manager = aspectInfo.instance;
        NSLog(@"勾住了 陀螺仪停止运行 %@", [NSDate date]);
        NSLog(@"UpdateInterval = %f", manager.deviceMotionUpdateInterval);
    } error:NULL];

//    [[[CMMotionManager alloc] init] startDeviceMotionUpdates];
//    [[[CMMotionManager alloc] init] startDeviceMotionUpdatesUsingReferenceFrame:<#(CMAttitudeReferenceFrame)#>];
//    [[[CMMotionManager alloc] init] startDeviceMotionUpdatesToQueue:<#(nonnull NSOperationQueue *)#> withHandler:<#^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error)handler#>];
//    [[[CMMotionManager alloc] init] startDeviceMotionUpdatesUsingReferenceFrame:<#(CMAttitudeReferenceFrame)#> toQueue:<#(nonnull NSOperationQueue *)#> withHandler:<#^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error)handler#>];
}

@end
