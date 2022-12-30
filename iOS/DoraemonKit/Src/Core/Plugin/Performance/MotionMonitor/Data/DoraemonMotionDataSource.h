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

@property (nonatomic, strong) NSMutableArray<DoraemonMotionDataModel *> *motionUseModelArray;

+ (DoraemonMotionDataSource *)shareInstance;

- (void)addUseModel:(DoraemonMotionDataModel *)useModel;

- (void)clear;

- (NSString *)toJson;

@end

NS_ASSUME_NONNULL_END
