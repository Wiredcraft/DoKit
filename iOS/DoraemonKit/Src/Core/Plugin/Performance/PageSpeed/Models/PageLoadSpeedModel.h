//
//  PageLoadSpeedModel.h
//  CocoaAsyncSocket
//
//  Created by tiazhao1 on 2023/3/31.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface PageLoadSpeedModel : RLMObject
@property (copy, nonatomic) NSString * modelId;
@property (copy, nonatomic) NSString * pageName;
@property (assign, nonatomic) double loadBeginTime;
@property (assign, nonatomic) double loadEndTime;
@property (assign, nonatomic) BOOL isLoadEnded;
@end

NS_ASSUME_NONNULL_END
