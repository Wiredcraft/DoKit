//
//  DataManager.m
//  CocoaAsyncSocket
//
//  Created by tiazhao1 on 2023/4/26.
//

#import "DataManager.h"
#import "DoraemonANRManager.h"
#import "DoraemonNetFlowDataSource.h"
#import "DoraemonUseLocationManager.h"
#import "DoraemonCPUManager.h"
#import "DoraemonLaunchTimeManager.h"
#import "DoraemonPageSpeedManager.h"
#import "DoraemonMemoryLeakData.h"

@implementation DataManager
+ (void) clearAllData {
    [[DoraemonANRManager sharedInstance] clearData];
    [[DoraemonNetFlowDataSource shareInstance] clear];
    [[DoraemonUseLocationManager shareInstance] clear];
    [[DoraemonCPUManager shareInstance] clear];
    [[DoraemonLaunchTimeManager shareInstance] clear];
    [[DoraemonPageSpeedManager shareInstance] clear];
    [[DoraemonMemoryLeakData shareInstance] clearResult];
}
@end
