//
//  DoraemonCPUManager.h
//  CocoaAsyncSocket
//
//  Created by tiazhao1 on 2023/2/24.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoraemonCPUUsageModel : RLMObject
@property (nonatomic, copy) NSString* uid;
@property (nonatomic, assign) double timeStamp;
@property (nonatomic, assign) CGFloat averageCpuUsageRate;
@property (nonatomic, assign) CGFloat maxCpuUsageRate;
@end

@interface DoraemonCPUManager : NSObject
+ (DoraemonCPUManager *)shareInstance;
- (void)startRecord;
- (NSArray *)dataForReport;
@end

NS_ASSUME_NONNULL_END
