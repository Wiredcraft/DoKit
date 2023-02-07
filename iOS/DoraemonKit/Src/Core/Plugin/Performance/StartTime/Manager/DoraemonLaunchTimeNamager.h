//
//  DoraemonLaunchTimeNamager.h
//  CocoaAsyncSocket
//
//  Created by tiazhao1 on 2023/2/7.
//

#import <Foundation/Foundation.h>
#import "DoraemonLaunchTimeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DoraemonLaunchTimeNamager : NSObject
@property (nonatomic, strong, readonly) NSArray<DoraemonLaunchTimeModel *> *launchTimeModelArray;

+ (DoraemonLaunchTimeNamager *)shareInstance;
- (void)addOrUpdateUseModel:(DoraemonLaunchTimeModel *)timeModel;
- (NSArray<DoraemonLaunchTimeModel *> *)filterModelsWithBeginStamp: (NSString *)beginStamp endStamp: (NSString *)endStamp;
- (NSArray<NSDictionary *> *)modelDics;
@end

NS_ASSUME_NONNULL_END
