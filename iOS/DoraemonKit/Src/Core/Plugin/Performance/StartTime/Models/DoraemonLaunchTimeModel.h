//
//  DoraemonLaunchTimeModel.h
//  CocoaAsyncSocket
//
//  Created by tiazhao1 on 2023/2/7.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoraemonLaunchTimeModel : RLMObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, assign) NSTimeInterval launchCost;

@end

NS_ASSUME_NONNULL_END
