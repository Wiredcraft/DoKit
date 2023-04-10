//
//  DoraemonStartTimeViewController.m
//  DoraemonKit
//
//  Created by yixiang on 2019/7/17.
//

#import "DoraemonStartTimeViewController.h"
#import "DoraemonCellSwitch.h"
#import "DoraemonCellButton.h"
#import "DoraemonDefine.h"
#import "DoraemonCacheManager.h"
#import "NSObject+Doraemon.h"
#import "DoraemonManager.h"
#import <objc/runtime.h>
#import "DoraemonHealthManager.h"
#import "DoraemonTimeProfiler.h"
#import "DoraemonStartTimeProfilerViewController.h"
#import "DoraemonLaunchTimeManager.h"
#import "Aspects.h"

static NSTimeInterval startTime;
static NSTimeInterval endTime;

@interface DoraemonStartTimeViewController ()<DoraemonSwitchViewDelegate,DoraemonCellButtonDelegate>

@property (nonatomic, strong) DoraemonCellSwitch *switchView;
@property (nonatomic, strong) DoraemonCellButton *cellBtn;

@end

@implementation DoraemonStartTimeViewController

+ (void)load{
    startTime = [[NSDate date] timeIntervalSince1970] * 1000;

    [UIApplication aspect_hookSelector:@selector(setDelegate:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, id<UIApplicationDelegate> delegate) {
        NSObject *obj = (NSObject *)delegate;
        [self hockDidFinishLaunchingWithOptions:obj];
    } error:NULL];
}

+ (void) hockDidFinishLaunchingWithOptions: (NSObject *)appDelegate {
    Class class = appDelegate.class;
    Method originMethod = class_getInstanceMethod(class, @selector(application:didFinishLaunchingWithOptions:));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(doraemon_application:didFinishLaunchingWithOptions:));
    class_addMethod(class, method_getName(swizzledMethod), method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    Method swizzledMethod2 = class_getInstanceMethod(class, @selector(doraemon_application:didFinishLaunchingWithOptions:));
    method_exchangeImplementations(originMethod, swizzledMethod2);

    dispatch_after(1.0, dispatch_get_main_queue(), ^{
        [[DoraemonManager shareInstance] install];
    });
}

- (BOOL)doraemon_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [DoraemonTimeProfiler startRecord];
    BOOL ret = [self doraemon_application:application didFinishLaunchingWithOptions:launchOptions];
    [DoraemonTimeProfiler stopRecord];
    endTime = [[NSDate date] timeIntervalSince1970] * 1000;
    
    [DoraemonHealthManager sharedInstance].startTime = endTime - startTime;

    // 存入数据库
    DoraemonLaunchTimeModel *timeModel = [[DoraemonLaunchTimeModel alloc] init];
    timeModel.uid = [[NSUUID UUID] UUIDString];
    timeModel.time = endTime;
    timeModel.launchCost = endTime - startTime;
    [[DoraemonLaunchTimeManager shareInstance] addOrUpdateUseModel:timeModel];

    return ret;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = DoraemonLocalizedString(@"启动耗时");
    
    _switchView = [[DoraemonCellSwitch alloc] initWithFrame:CGRectMake(0, self.bigTitleView.doraemon_bottom, self.view.doraemon_width, kDoraemonSizeFrom750(104))];
    [_switchView renderUIWithTitle:DoraemonLocalizedString(@"开关") switchOn:[[DoraemonCacheManager sharedInstance] startTimeSwitch]];
    [_switchView needTopLine];
    [_switchView needDownLine];
    _switchView.delegate = self;
    [self.view addSubview:_switchView];
    
    _cellBtn = [[DoraemonCellButton alloc] initWithFrame:CGRectMake(0, _switchView.doraemon_bottom, self.view.doraemon_width, kDoraemonSizeFrom750(104))];
    if ([[DoraemonCacheManager sharedInstance] startTimeSwitch]){
        [_cellBtn renderUIWithTitle:[NSString stringWithFormat:@"%@%fs",DoraemonLocalizedString(@"本次启动时间为"),endTime-startTime]];
    }
    _cellBtn.delegate = self;
    [_cellBtn needDownLine];
    [self.view addSubview:_cellBtn];
    
}

- (BOOL)needBigTitleView{
    return YES;
}

#pragma mark -- DoraemonSwitchViewDelegate
- (void)changeSwitchOn:(BOOL)on sender:(id)sender{
    __weak typeof(self) weakSelf = self;
    [DoraemonAlertUtil handleAlertActionWithVC:self okBlock:^{
        [[DoraemonCacheManager sharedInstance] saveStartTimeSwitch:on];
        exit(0);
    } cancleBlock:^{
        weakSelf.switchView.switchView.on = !on;
    }];
}

#pragma mark -- DoraemonCellButtonDelegate
- (void)cellBtnClick:(id)sender{
    DoraemonStartTimeProfilerViewController *vc = [[DoraemonStartTimeProfilerViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}



@end
