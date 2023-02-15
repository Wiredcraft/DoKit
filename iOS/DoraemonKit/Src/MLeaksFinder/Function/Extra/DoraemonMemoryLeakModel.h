//
//  DoraemonMemoryLeakModel.h
//  DoraemonKit
//
//  Created by tiazhao1 on 2023/2/8.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoraemonMemoryLeakModel : RLMObject
@property (nonatomic, copy) NSString *info;
@property (nonatomic, copy) NSString *uid;
@end

NS_ASSUME_NONNULL_END
