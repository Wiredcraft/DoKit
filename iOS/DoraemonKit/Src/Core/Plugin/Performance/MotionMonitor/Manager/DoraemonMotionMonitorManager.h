//
//  DoraemonMotionMonitorManager.h
//  CocoaAsyncSocket
//
//  Created by tianYang on 2022/11/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoraemonMotionMonitorManager : NSObject
+ (DoraemonMotionMonitorManager *)shareInstance;
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) NSInteger useMotionCount;
@property (nonatomic, assign) NSInteger useMotionTime;
@end

NS_ASSUME_NONNULL_END
