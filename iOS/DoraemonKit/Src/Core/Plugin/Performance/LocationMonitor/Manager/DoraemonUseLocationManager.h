//
//  DoraemonUseLocationManager.h
//  DoraemonKit
//
//  Created by tianYang on 2023/1/6.
//

#import <Foundation/Foundation.h>
#import "DoraemonUseLocationDataModel.h"

@interface DoraemonUseLocationManager : NSObject

+ (DoraemonUseLocationManager *)shareInstance;

@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) double useLocationBaseTimeStamp;

@property (nonatomic, strong) NSMutableArray<DoraemonUseLocationDataModel *> *useModelArray;

- (void)addUseDataModel:(DoraemonUseLocationDataModel *)useModel;

- (void)clear;

- (NSString *)toJson;

@end

