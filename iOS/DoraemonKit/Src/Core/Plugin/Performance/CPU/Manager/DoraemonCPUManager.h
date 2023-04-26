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
@property (nonatomic, assign) long timestamp;
@property (nonatomic, assign) long cpuUsageRate;
@end

@interface DoraemonCPUManager : NSObject
+ (DoraemonCPUManager *)shareInstance;
- (void)startRecord;
- (NSDictionary *)dataForReport;
- (void)clear;
@end

NS_ASSUME_NONNULL_END
