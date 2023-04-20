//
//  DotaemonANRModel.h
//  DoraemonKit
//
//  Created by tiazhao1 on 2023/4/19.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface DotaemonANRModel : RLMObject
@property (nonatomic, copy) NSString* uid;
@property (nonatomic, assign) long duration;
@property (nonatomic, copy) NSString * info;
@end

NS_ASSUME_NONNULL_END
