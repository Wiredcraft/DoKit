//
//  RealmUtil.m
//  DoraemonKit
//
//  Created by tianYang on 2023/1/12.
//

#import "RealmUtil.h"

@implementation RealmUtil

+(RLMRealmConfiguration *)getRealmConfig: (NSString *)tableName {
    RLMRealmConfiguration *configuration = [RLMRealmConfiguration defaultConfiguration];
    configuration.fileURL = [[[configuration.fileURL URLByDeletingLastPathComponent]
                             URLByAppendingPathComponent:tableName]
                             URLByAppendingPathExtension:@"realm"];
    return configuration;
}

+ (void)addOrUpdateModel:(RLMObject *)model queue: (dispatch_queue_t)queue tableName: (NSString *)tableName {
    RLMRealmConfiguration *config = [self getRealmConfig:tableName];
    RLMThreadSafeReference *ref;
    if ([model realm]) {
        ref = [RLMThreadSafeReference referenceWithThreadConfined: model];
    }
    dispatch_async(queue, ^{
        NSError *error = nil;
        RLMRealm *realm = [RLMRealm realmWithConfiguration:config error:&error];
        RLMObject *obj;
        if (ref) {
            obj = [realm resolveThreadSafeReference: ref];
        } else {
            obj = model;
        }
        if (obj) {
            [realm transactionWithBlock:^{
                if (model) [realm addOrUpdateObject:obj];
            }];
        };
    });
}

+ (void)clearWithqueue: (dispatch_queue_t)queue tableName: (NSString *)tableName {
    RLMRealmConfiguration *config = [self getRealmConfig:tableName];
    dispatch_async(queue, ^{
        NSError *error = nil;
        RLMRealm *realm = [RLMRealm realmWithConfiguration:config error:&error];
        [realm transactionWithBlock:^{
            [realm deleteAllObjects];
        }];
    });
}


+ (NSArray<RLMObject *> *)modelArrayWithTableName: (NSString *)tableName objClass: (Class)objClass {
    RLMRealmConfiguration *config = [self getRealmConfig:tableName];
    NSError *error = nil;
    RLMRealm *realm = [RLMRealm realmWithConfiguration:config error:&error];
    if (error) {
        return @[];
    }
    if ([objClass isSubclassOfClass: RLMObject.self]) {
        RLMResults *results = [objClass allObjectsInRealm: realm];
        if (results == nil || results.count == 0) {
            return @[];
        }
        
        NSRange range = NSMakeRange(0, results.count);
        NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndexesInRange:range];
        return [results objectsAtIndexes:indexes];
    }
    return @[];
}

+ (NSArray<RLMObject *> *)filterModelsWithPredicate: (NSPredicate *)predicate tableName: (NSString *)tableName objClass: (Class)objClass {
    RLMRealmConfiguration *config = [self getRealmConfig:tableName];
    NSError *error = nil;
    RLMRealm *realm = [RLMRealm realmWithConfiguration: config error:&error];
    if (error) {
        return @[];
    }
    if ([objClass isSubclassOfClass: RLMObject.self]) {
        RLMResults *results = [objClass objectsInRealm:realm withPredicate:predicate];
        if (results == nil || results.count == 0) {
            return @[];
        }
        
        NSRange range = NSMakeRange(0, results.count);
        NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndexesInRange:range];
        return [results objectsAtIndexes:indexes];
    }
    return @[];
}

@end
