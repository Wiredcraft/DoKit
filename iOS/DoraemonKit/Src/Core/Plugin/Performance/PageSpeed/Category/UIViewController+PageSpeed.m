//
//  UIViewController+PageSpeed.m
//  CocoaAsyncSocket
//
//  Created by tiazhao1 on 2023/3/30.
//

#import "UIViewController+PageSpeed.h"
#import <objc/runtime.h>
#import "PageLoadSpeedModel.h"
#import "DoraemonPageSpeedManager.h"
#import "NSObject+Doraemon.h"

@interface UIViewController ()
@property (strong, nonatomic) PageLoadSpeedModel* loadSpeedModel;
@end

@implementation UIViewController (PageSpeed)
- (void)setLoadSpeedModel: (NSString *)loadSpeedModel
{
    objc_setAssociatedObject(self, @selector(loadSpeedModel), loadSpeedModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (PageLoadSpeedModel *)loadSpeedModel
{
    return objc_getAssociatedObject(self, _cmd);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[self class] doraemon_swizzleInstanceMethodWithOriginSel:@selector(viewDidLoad) swizzledSel:@selector(pageSpeed_viewDidLoad)];
        [[self class] doraemon_swizzleInstanceMethodWithOriginSel:@selector(viewDidAppear:) swizzledSel:@selector(pageSpeed_viewDidAppear:)];
    });
}

- (void)pageSpeed_viewDidLoad {
    UIViewController* instance = self;
    if ([instance isKindOfClass:[UINavigationController class]] || [instance isKindOfClass:[UITabBarController class]]) [self pageSpeed_viewDidLoad];
    PageLoadSpeedModel *model = [[PageLoadSpeedModel alloc] init];
    model.modelId = [[NSUUID UUID] UUIDString];
    model.pageName = [[NSString alloc] initWithUTF8String: object_getClassName(instance)];
    model.loadBeginTime = [[NSDate date] timeIntervalSince1970] * 1000;
    instance.loadSpeedModel = model;
    [self pageSpeed_viewDidLoad];
}


- (void)pageSpeed_viewDidAppear:(BOOL)animated {
    [self pageSpeed_viewDidAppear:animated];
    UIViewController* instance = self;
    PageLoadSpeedModel *model = instance.loadSpeedModel;
    if (model && !model.isLoadEnded) {
        model.isLoadEnded = YES;
        model.loadEndTime = [[NSDate date] timeIntervalSince1970] * 1000;
        long duration = (long)(model.loadEndTime - model.loadBeginTime);
        if (duration < 3000 && ![model.pageName containsString:@"DoraemonKit"]) {
            PageLoadSpeedModel *savedModel = [[PageLoadSpeedModel alloc] initWithValue:model];
            [[DoraemonPageSpeedManager shareInstance] addPageSpeedModel:savedModel];
        }
    }
}

@end
