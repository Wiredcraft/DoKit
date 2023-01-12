//
//  DoraemonMotionDataSource.h
//  CocoaAsyncSocket
//
//  Created by tianYang on 2022/11/4.
//

#import <Foundation/Foundation.h>
#import "DoraemonMotionDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DoraemonMotionDataSource : NSObject

@property (nonatomic, strong, readonly) NSArray<DoraemonMotionDataModel *> *motionUseModelArray;

+ (DoraemonMotionDataSource *)shareInstance;

- (void)addOrUpdateUseModel:(DoraemonMotionDataModel *)useModel;
- (NSArray<DoraemonMotionDataModel *> *)filterModelsWithBeginStamp: (NSString *)beginStamp endStamp: (NSString *)endStamp;

- (NSArray<NSDictionary *> *)modelDics;
- (NSString *)toJson;

@end

NS_ASSUME_NONNULL_END
