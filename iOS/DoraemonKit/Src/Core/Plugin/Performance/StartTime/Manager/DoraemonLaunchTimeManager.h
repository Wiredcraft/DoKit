//
//  DoraemonLaunchTimeManager.h
//  CocoaAsyncSocket
//
//  Created by tiazhao1 on 2023/2/7.
//

#import <Foundation/Foundation.h>
#import "DoraemonLaunchTimeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DoraemonLaunchTimeManager : NSObject
@property (nonatomic, strong, readonly) NSArray<DoraemonLaunchTimeModel *> *launchTimeModelArray;

+ (DoraemonLaunchTimeManager *)shareInstance;
- (void)addOrUpdateUseModel:(DoraemonLaunchTimeModel *)timeModel;
- (NSArray<DoraemonLaunchTimeModel *> *)filterModelsWithBeginStamp: (NSString *)beginStamp endStamp: (NSString *)endStamp;
- (NSArray<NSDictionary *> *)modelDics;
@end

NS_ASSUME_NONNULL_END
