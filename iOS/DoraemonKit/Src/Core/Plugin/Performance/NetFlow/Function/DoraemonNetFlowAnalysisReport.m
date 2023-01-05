//
//  DoraemonNetFlowAnalysisReport.m
//  DoraemonKit
//
//  Created by tianYang on 2023/1/5.
//

#import "DoraemonNetFlowAnalysisReport.h"
#import "DoraemonNetFlowDataSource.h"
#import "DoraemonUtil.h"

@implementation DoraemonNetFlowAnalysisReport

-(instancetype)initWithRequestTimeThreshold: (NSTimeInterval)requestTimeThreshold {
    self = [super init];
    if (self) {
        _requestTimeThreshold = requestTimeThreshold;
    }
    return self;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _requestTimeThreshold = 1000;
    }
    return self;
}

- (NSMutableArray<DoraemonNetFlowHttpModel *> *)httpModelArray {
    return [DoraemonNetFlowDataSource shareInstance].httpModelArray;
}

- (NSInteger)summaryRequestCount {
    return  [self httpModelArray].count;
}

- (NSTimeInterval)summaryRequestTime {
    return [[[self reportDic] objectForKey:@"summaryRequestTime"] doubleValue];
}

- (NSString *)summaryRequestUploadFlow {
    return [[self reportDic] objectForKey:@"summaryRequestUploadFlow"];
}

- (NSString *)summaryRequestDownFlow {
    return [[self reportDic] objectForKey:@"summaryRequestDownFlow"];
}

- (NSTimeInterval)requestAverageTime {
    return [[[self reportDic] objectForKey:@"requestAverageTime"] doubleValue];
}

- (double)requestSucsessRate {
    return [[[self reportDic] objectForKey:@"requestSucsessRate"] doubleValue];
}

- (NSInteger)slowRequestCount {
    return [[[self reportDic] objectForKey:@"slowRequestCount"] integerValue];
}

- (NSArray<NSString *> *)reqCountRank {
    return [[self reportDic] objectForKey:@"reqCountRank"];
}

- (NSArray<NSString *> *)failReqCountRank {
    return [[self reportDic] objectForKey:@"failReqCountRank"];
}

- (NSArray<NSString *> *)reqTimeRank {
    return [[self reportDic] objectForKey:@"reqTimeRank"];
}

- (NSArray<NSString *> *)uploadDataRank {
    return [[self reportDic] objectForKey:@"uploadDataRank"];
}

- (NSArray<NSString *> *)downloadDataRank {
    return [[self reportDic] objectForKey:@"downloadDataRank"];
}

- (NSDictionary *)reportDic {
    NSMutableArray<DoraemonNetFlowHttpModel *> * httpModelArray = [self httpModelArray];
    NSMutableDictionary *dic = @{}.mutableCopy;

    NSTimeInterval summaryRequestCount = httpModelArray.count;
    dic[@"summaryRequestCount"] = @(summaryRequestCount);

    NSTimeInterval totalTime = 0;
    CGFloat totalDownFlow = 0.;
    CGFloat totalUploadFlow = 0.;
    CGFloat sucsessCount = 0.;
    NSInteger slowRequestCount = 0;

    NSMutableDictionary *reqCountDic = @{}.mutableCopy;
    NSMutableDictionary *failReqCountDic = @{}.mutableCopy;
    NSMutableDictionary *reqTimeRankDic = @{}.mutableCopy;
    NSMutableDictionary *uploadDataRankDic = @{}.mutableCopy;
    NSMutableDictionary *downloadDataRankDic = @{}.mutableCopy;

    for (int i=0; i<httpModelArray.count; i++) {
        DoraemonNetFlowHttpModel *httpModel = httpModelArray[i];
        NSString *rankKey = [NSString stringWithFormat:@"%@ %@", httpModel.method, httpModel.url];

        CGFloat uploadFlow =  [httpModel.uploadFlow floatValue];
        totalUploadFlow += uploadFlow;
        CGFloat downFlow = [httpModel.downFlow floatValue];
        totalDownFlow += downFlow;
        totalTime += [httpModel.totalDuration doubleValue];

        NSInteger statusCode = [httpModel.statusCode integerValue];
        if (statusCode >= 200 && statusCode <= 399) {
            sucsessCount += 1;
        } else {
            NSArray<NSString *> *failReqCountDicAllKeys = [failReqCountDic allKeys];
            if ([failReqCountDicAllKeys containsObject:rankKey]) {
                NSInteger count = [[reqCountDic objectForKey:rankKey] integerValue];
                failReqCountDic[rankKey] = @(count + 1);
            } else {
                failReqCountDic[rankKey] = @(1);
            }
        }

        if ([httpModel.totalDuration doubleValue] * 1000 > self.requestTimeThreshold) {
            slowRequestCount += 1;
        }

        NSArray<NSString *> *reqCountDicAllKeys = [reqCountDic allKeys];
        if ([reqCountDicAllKeys containsObject:rankKey]) {
            NSInteger count = [[reqCountDic objectForKey:rankKey] integerValue];
            reqCountDic[rankKey] = @(count + 1);
        } else {
            reqCountDic[rankKey] = @(1);
        }

        NSArray<NSString *> *reqTimeRankDicAllKeys = [reqTimeRankDic allKeys];
        if ([reqTimeRankDicAllKeys containsObject:rankKey]) {
            NSTimeInterval oldtime = [[reqTimeRankDic objectForKey:rankKey] doubleValue];
            NSTimeInterval time = (oldtime + [httpModel.totalDuration doubleValue]) / 2.0;
            reqTimeRankDic[rankKey] = @(time);
        } else {
            reqTimeRankDic[rankKey] = @([httpModel.totalDuration doubleValue]);
        }

        NSArray<NSString *> *uploadDataRankDicAllKeys = [uploadDataRankDic allKeys];
        if ([uploadDataRankDicAllKeys containsObject:rankKey]) {
            CGFloat oldDataFlow = [[uploadDataRankDic objectForKey:rankKey] floatValue];
            CGFloat flow = (oldDataFlow + [httpModel.uploadFlow floatValue]) / 2.0;
            uploadDataRankDic[rankKey] = @(flow);
        } else {
            uploadDataRankDic[rankKey] = @([httpModel.uploadFlow floatValue]);
        }

        NSArray<NSString *> *downloadDataRankDicAllKeys = [downloadDataRankDic allKeys];
        if ([downloadDataRankDicAllKeys containsObject:rankKey]) {
            CGFloat oldDataFlow = [[downloadDataRankDic objectForKey:rankKey] floatValue];
            CGFloat flow = (oldDataFlow + [httpModel.downFlow floatValue]) / 2.0;
            downloadDataRankDic[rankKey] = @(flow);
        } else {
            downloadDataRankDic[rankKey] = @([httpModel.downFlow floatValue]);
        }
    }
    NSString *upLoad = [DoraemonUtil formatByte:totalUploadFlow];
    NSString *downLoad = [DoraemonUtil formatByte:totalDownFlow];

    dic[@"summaryRequestTime"] = @(totalTime);
    dic[@"summaryRequestUploadFlow"] = upLoad;
    dic[@"summaryRequestDownFlow"] = downLoad;

    NSTimeInterval requestAverageTime = 0;
    double requestSucsessRate = 0;
    if (summaryRequestCount != 0) {
        requestAverageTime = totalTime * 1000 / (double)summaryRequestCount;
        requestSucsessRate = (double)sucsessCount / (double)summaryRequestCount;
    }
    dic[@"requestAverageTime"] = @(requestAverageTime);
    dic[@"requestSucsessRate"] = @(requestSucsessRate);
    dic[@"slowRequestCount"] = @(slowRequestCount);

    // reqCountRank
    NSArray<NSString *> *reqCountRank = [reqCountDic keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return NSOrderedDescending;
    }];
    if (reqCountRank.count > 5) {
        dic[@"reqCountRank"] = [reqCountRank subarrayWithRange:NSMakeRange(0, 5)];
    } else {
        dic[@"slowRequestCount"] = reqCountRank;
    }
    // failReqCountRank
    NSArray<NSString *> *failReqCountRank = [failReqCountDic keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return NSOrderedDescending;
    }];
    if (failReqCountRank.count > 5) {
        dic[@"failReqCountRank"] = [failReqCountRank subarrayWithRange:NSMakeRange(0, 5)];
    } else {
        dic[@"failReqCountRank"] = failReqCountRank;
    }
    // reqTimeRank
    NSArray<NSString *> *reqTimeRank = [reqTimeRankDic keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return NSOrderedDescending;
    }];
    if (reqTimeRank.count > 5) {
        dic[@"reqTimeRank"] = [reqTimeRank subarrayWithRange:NSMakeRange(0, 5)];
    } else {
        dic[@"reqTimeRank"] = reqTimeRank;
    }
    // uploadDataRank
    NSArray<NSString *> *uploadDataRank = [uploadDataRankDic keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return NSOrderedDescending;
    }];
    if (uploadDataRank.count > 5) {
        dic[@"uploadDataRank"] = [uploadDataRank subarrayWithRange:NSMakeRange(0, 5)];
    } else {
        dic[@"uploadDataRank"] = uploadDataRank;
    }
    // downloadDataRank
    NSArray<NSString *> *downloadDataRank = [downloadDataRankDic keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return NSOrderedDescending;
    }];
    if (downloadDataRank.count > 5) {
        dic[@"downloadDataRank"] = [downloadDataRank subarrayWithRange:NSMakeRange(0, 5)];
    } else {
        dic[@"downloadDataRank"] = downloadDataRank;
    }
    return dic;
}

- (NSString *)toJson {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self reportDic] options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];;
}

@end
