//
//  DoraemonMotionDataModel.m
//  CocoaAsyncSocket
//
//  Created by tianYang on 2022/11/4.
//

#import "DoraemonMotionDataModel.h"

@implementation DoraemonMotionDataModel
- (NSInteger)useTime {
    if (!(_beginDate && _endDate)) { return 0; }
    NSDateComponents * components = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:_beginDate toDate:_endDate options:NSCalendarWrapComponents];
    return components.second;
}
@end
