//
//  DoraemonMotionPlugin.m
//  CocoaAsyncSocket
//
//  Created by tianYang on 2022/11/18.
//

#import "DoraemonMotionPlugin.h"
#import "DoraemonMotionMonitorViewController.h"
#import "DoraemonHomeWindow.h"

@implementation DoraemonMotionPlugin
- (void)pluginDidLoad{
    DoraemonMotionMonitorViewController *vc = [[DoraemonMotionMonitorViewController alloc] init];
    [DoraemonHomeWindow openPlugin:vc];
}
@end
