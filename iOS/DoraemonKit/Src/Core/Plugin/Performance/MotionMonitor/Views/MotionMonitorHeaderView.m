//
//  MotionMonitorHeaderView.m
//  CocoaAsyncSocket
//
//  Created by tianYang on 2022/11/18.
//

#import "MotionMonitorHeaderView.h"

@interface MotionMonitorHeaderView()
@property (nonatomic, strong) UILabel * overviewLabel;
@end

@implementation MotionMonitorHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)renderWithCount: (NSInteger)count totalTime: (NSInteger)time {
    NSString *str = [NSString stringWithFormat:@"使用次数：%d次          总时间： %d秒", count, time];
    self.overviewLabel.text = str;
}

- (void) setupSubviews {
    CGRect rect = CGRectMake(self.bounds.origin.x + 20, self.bounds.origin.y + 10, self.frame.size.width - 40, self.frame.size.height - 20);
    _overviewLabel = [[UILabel alloc] initWithFrame:rect];
    _overviewLabel.textColor = UIColor.blackColor;
    _overviewLabel.textAlignment = UITextAlignmentCenter;
    [self addSubview: _overviewLabel];
}

@end
