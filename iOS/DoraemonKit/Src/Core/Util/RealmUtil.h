//
//  RealmUtil.h
//  DoraemonKit
//
//  Created by tianYang on 2023/1/12.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface RealmUtil : NSObject
+ (void)addOrUpdateModel:(RLMObject *)model queue: (dispatch_queue_t)queue tableName: (NSString *)tableName;
+ (NSArray<RLMObject *> *)modelArrayWithTableName: (NSString *)tableName objClass: (Class)objClass;
+ (NSArray<RLMObject *> *)filterModelsWithPredicate: (NSPredicate *)predicate tableName: (NSString *)tableName objClass: (Class)objClass;
@end

NS_ASSUME_NONNULL_END
