//
//  CLLocationManager+Monitor.m
//  DoraemonKit
//
//  Created by tianYang on 2023/1/6.
//

#import "CLLocationManager+Monitor.h"
#import "Aspects.h"
#import "DoraemonUseLocationManager.h"
#import "DoraemonUseLocationDataModel.h"
#import "DoraemonUseLocationDataModel.h"
#import <CoreLocation/CLLocationManager.h>

@implementation CLLocationManager (Monitor)

+ (void)load {
    [CLLocationManager aspect_hookSelector:@selector(setDelegate:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, id<CLLocationManagerDelegate> delegate) {
        NSObject *obj = (NSObject *)delegate;
        if ([obj respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
            [obj aspect_hookSelector:@selector(locationManager:didUpdateLocations:) withOptions: AspectPositionAfter usingBlock: ^(id<AspectInfo> aspectInfo, CLLocationManager *manager, NSArray<CLLocation *> *locations) {
                [self handleUseLocationWith:manager locations:locations];
            } error:NULL];
            [obj aspect_hookSelector:@selector(locationManager:didFailWithError:) withOptions: AspectPositionAfter usingBlock: ^(id<AspectInfo> aspectInfo, CLLocationManager *manager, NSArray<CLLocation *> *locations) {
                [self handleUseLocationWith:manager locations:locations];
                [DoraemonUseLocationManager shareInstance].useLocationBaseTimeStamp = 0;
            } error:NULL];
        }
    } error:NULL];

    [CLLocationManager aspect_hookSelector:@selector(requestLocation) withOptions: AspectPositionAfter usingBlock: ^(id<AspectInfo> aspectInfo) {
        [DoraemonUseLocationManager shareInstance].useLocationBaseTimeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
    } error:NULL];
    [CLLocationManager aspect_hookSelector:@selector(startUpdatingLocation) withOptions: AspectPositionAfter usingBlock: ^(id<AspectInfo> aspectInfo) {
        [DoraemonUseLocationManager shareInstance].useLocationBaseTimeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
    } error:NULL];
    [CLLocationManager aspect_hookSelector:@selector(stopUpdatingLocation) withOptions: AspectPositionAfter usingBlock: ^(id<AspectInfo> aspectInfo) {
        [DoraemonUseLocationManager shareInstance].useLocationBaseTimeStamp = 0;
    } error:NULL];
}

+ (void)handleUseLocationWith: (CLLocationManager *)locationManager locations: (NSArray<CLLocation *> *)locations{
    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusNotDetermined:
            [DoraemonUseLocationManager shareInstance].useLocationBaseTimeStamp = 0;
            return;
        case kCLAuthorizationStatusRestricted:
            [DoraemonUseLocationManager shareInstance].useLocationBaseTimeStamp = 0;
            return;
        case kCLAuthorizationStatusAuthorizedAlways:
            break;;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            break;
        case kCLAuthorizationStatusDenied:
            [DoraemonUseLocationManager shareInstance].useLocationBaseTimeStamp = 0;
            return;
        default:
            [DoraemonUseLocationManager shareInstance].useLocationBaseTimeStamp = 0;
            break;
    }
    NSTimeInterval baseLineTimeStamp = [DoraemonUseLocationManager shareInstance].useLocationBaseTimeStamp;
    NSTimeInterval currenntTimeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
    NSTimeInterval useDuration = currenntTimeStamp - baseLineTimeStamp;
    if (!baseLineTimeStamp) return;

    DoraemonUseLocationDataModel *useModel = [[DoraemonUseLocationDataModel alloc] init];
    useModel.modelId = [[NSUUID UUID] UUIDString];
    useModel.timeStamp = currenntTimeStamp;
    useModel.useDuration = useDuration;

    [DoraemonUseLocationManager shareInstance].useLocationBaseTimeStamp = currenntTimeStamp;

    [[DoraemonUseLocationManager shareInstance] addUseDataModel:useModel];
}

@end
