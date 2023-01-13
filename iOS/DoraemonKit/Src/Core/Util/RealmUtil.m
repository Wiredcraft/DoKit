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
    dispatch_async(queue, ^{
        NSError *error = nil;
        RLMRealm *realm = [RLMRealm realmWithConfiguration:config error:&error];
        [realm transactionWithBlock:^{
            if (model) [realm addOrUpdateObject:model];
        }];
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
        return (NSArray<RLMObject *> *)[objClass allObjectsInRealm:realm];
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
        return (NSArray<RLMObject *> *)[objClass objectsInRealm:realm withPredicate:predicate];;
    }
    return @[];
}

@end
