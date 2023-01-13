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
    CLLocation *currentLocation = locations.firstObject;

    NSTimeInterval baseLineTimeStamp = [DoraemonUseLocationManager shareInstance].useLocationBaseTimeStamp;
    NSTimeInterval currenntTimeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
    NSTimeInterval useDuration = currenntTimeStamp - baseLineTimeStamp;
    if (!baseLineTimeStamp) useDuration = 0;

    DoraemonUseLocationDataModel *useModel = [[DoraemonUseLocationDataModel alloc] init];
    useModel.modelId = [NSUUID UUID];
    useModel.timeStamp = currenntTimeStamp;
    useModel.distanceFilter = locationManager.distanceFilter;
    useModel.desiredAccuracy = locationManager.desiredAccuracy;
    useModel.longitude = currentLocation.coordinate.longitude;
    useModel.latitude = currentLocation.coordinate.latitude;
    useModel.useDuration = useDuration;

    [DoraemonUseLocationManager shareInstance].useLocationBaseTimeStamp = currenntTimeStamp;

    [[DoraemonUseLocationManager shareInstance] addUseDataModel:useModel];
}

@end
