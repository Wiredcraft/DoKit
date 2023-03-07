//
//  DoraemonFPSDataManager.h
//  DoraemonKit
//
//  Created by Jun Ma on 2023/1/11.
//

#import <Foundation/Foundation.h>
#import "DoraemonFPSModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DoraemonFPSDataManager : NSObject

+ (instancetype)sharedInstance;
- (void)appendData:(DoraemonFPSModel *)data;
- (NSArray<DoraemonFPSModel *> *)allData;
- (NSArray<DoraemonFPSModel *> *)filterModelsWithBeginStamp: (NSString *)beginStamp endStamp: (NSString *)endStamp;
- (NSArray *)dataForReport;
@end

NS_ASSUME_NONNULL_END
