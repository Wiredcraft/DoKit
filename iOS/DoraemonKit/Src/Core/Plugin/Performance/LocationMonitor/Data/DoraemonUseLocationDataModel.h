//
//  DoraemonUseLocationDataModel.h
//  DoraemonKit
//
//  Created by tianYang on 2023/1/6.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface DoraemonUseLocationDataModel : RLMObject

@property (nonatomic, copy) NSString * modelId;
@property (nonatomic, assign) double timeStamp;
@property (nonatomic, assign) double useDuration;

@property (nonatomic, assign) double distanceFilter;
@property (nonatomic, assign) double desiredAccuracy;

@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;

@end

