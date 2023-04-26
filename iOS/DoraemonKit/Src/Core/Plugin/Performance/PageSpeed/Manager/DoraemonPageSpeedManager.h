//
//  DoraemonPageSpeedManager.h
//  CocoaAsyncSocket
//
//  Created by tiazhao1 on 2023/3/31.
//

#import <Foundation/Foundation.h>
#import "PageLoadSpeedModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface DoraemonPageSpeedManager : NSObject
+ (DoraemonPageSpeedManager *)shareInstance;
- (void)addPageSpeedModel:(PageLoadSpeedModel *)model;
- (NSArray *)dataForReport;
- (void)clear;
@end

NS_ASSUME_NONNULL_END
