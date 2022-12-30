//
//  DoraemonMotionMonitorViewController.m
//  CocoaAsyncSocket
//
//  Created by tianYang on 2022/11/18.
//

#import "DoraemonMotionMonitorViewController.h"
#import "DoraemonCacheManager.h"
#import "DoraemonCellSwitch.h"
#import "DoraemonDefine.h"
#import "DoraemonMotionMonitorManager.h"
#import "MotionMonitorHeaderView.h"

@interface DoraemonMotionMonitorViewController ()<DoraemonSwitchViewDelegate>

@property (nonatomic, strong) DoraemonCellSwitch *switchView;
@property (nonatomic, strong) MotionMonitorHeaderView *overviewHeader;

@end

@implementation DoraemonMotionMonitorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = DoraemonLocalizedString(@"陀螺仪使用监测");
    _switchView = [[DoraemonCellSwitch alloc] initWithFrame:CGRectMake(0, 100, self.view.doraemon_width, kDoraemonSizeFrom750_Landscape(104))];
    [_switchView renderUIWithTitle:DoraemonLocalizedString(@"陀螺仪使用监测开关") switchOn:[DoraemonMotionMonitorManager shareInstance].enable];
    [_switchView needTopLine];
    [_switchView needDownLine];
    _switchView.delegate = self;
    [self.view addSubview:_switchView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([DoraemonMotionMonitorManager shareInstance].enable) {
        _overviewHeader = [[MotionMonitorHeaderView alloc] initWithFrame:CGRectMake(0, _switchView.doraemon_bottom + 15, self.view.doraemon_width, 40)];
        [self.view addSubview:_overviewHeader];
        [_overviewHeader renderWithCount:[DoraemonMotionMonitorManager shareInstance].useMotionCount totalTime:[DoraemonMotionMonitorManager shareInstance].useMotionTime];
    }
}

- (void)changeSwitchOn:(BOOL)on sender:(id)sender{
    __weak typeof(self) weakSelf = self;
    [DoraemonAlertUtil handleAlertActionWithVC:self okBlock:^{
        [DoraemonMotionMonitorManager shareInstance].enable = on;
        exit(0);
    } cancleBlock:^{
        weakSelf.switchView.switchView.on = !on;
    }];
}

@end
