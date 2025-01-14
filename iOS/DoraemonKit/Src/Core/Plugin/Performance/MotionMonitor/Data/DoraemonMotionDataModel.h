//
//  DoraemonMotionDataModel.h
//  CocoaAsyncSocket
//
//  Created by tianYang on 2022/11/4.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoraemonMotionDataModel : RLMObject
@property (nonatomic, assign) double timeStamp;
@property (nonatomic, strong) NSDate *beginDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, copy) NSString *modelId;
@property (nonatomic, assign) NSTimeInterval deviceMotionUpdateInterval;
@property (nonatomic, copy) NSString *callerInfo;

@property (nonatomic, assign, readonly) NSInteger useTime;
@end

NS_ASSUME_NONNULL_END
