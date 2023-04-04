//
//  UIViewController+PageSpeed.m
//  CocoaAsyncSocket
//
//  Created by tiazhao1 on 2023/3/30.
//

#import "UIViewController+PageSpeed.h"
#import "Aspects.h"
#import <objc/runtime.h>
#import "PageLoadSpeedModel.h"
#import "DoraemonPageSpeedManager.h"

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

+(void)load {
    [UIViewController aspect_hookSelector:@selector(viewDidLoad) withOptions:AspectPositionBefore usingBlock:^(id<AspectInfo> aspectInfo) {
        UIViewController* instance = aspectInfo.instance;
        if ([instance isKindOfClass:[UINavigationController class]] || [instance isKindOfClass:[UITabBarController class]]) return;;
        PageLoadSpeedModel *model = [[PageLoadSpeedModel alloc] init];
        model.modelId = [[NSUUID UUID] UUIDString];
        model.pageName = [[NSString alloc] initWithUTF8String: object_getClassName(instance)];
        model.loadBeginTime = [[NSDate date] timeIntervalSince1970] * 1000;
        instance.loadSpeedModel = model;
    } error:NULL];

    [UIViewController aspect_hookSelector:@selector(viewDidAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL isAnimated) {
        UIViewController* instance = aspectInfo.instance;
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
    } error:NULL];
}
@end
