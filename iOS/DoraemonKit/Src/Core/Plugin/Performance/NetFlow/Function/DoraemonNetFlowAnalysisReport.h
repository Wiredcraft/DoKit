//
//  DoraemonNetFlowAnalysisReport.h
//  DoraemonKit
//
//  Created by tianYang on 2023/1/5.
//

#import <Foundation/Foundation.h>

@interface DoraemonNetFlowAnalysisReport : NSObject

@property (nonatomic, assign) NSTimeInterval requestTimeThreshold;

@property (nonatomic, assign, readonly) NSTimeInterval summaryRequestTime;
@property (nonatomic, assign, readonly) NSString* summaryRequestUploadFlow;
@property (nonatomic, assign, readonly) NSString* summaryRequestDownFlow;
@property (nonatomic, assign, readonly) NSInteger summaryRequestCount;
@property (nonatomic, assign, readonly) NSTimeInterval requestAverageTime;
@property (nonatomic, assign, readonly) double requestSucsessRate;
@property (nonatomic, assign, readonly) NSInteger slowRequestCount;

@property (nonatomic, assign, readonly) NSArray<NSDictionary *>* reqCountRank;
@property (nonatomic, assign, readonly) NSArray<NSDictionary *>* failReqCountRank;
@property (nonatomic, assign, readonly) NSArray<NSDictionary *>* reqTimeRank;
@property (nonatomic, assign, readonly) NSArray<NSDictionary *>* uploadDataRank;
@property (nonatomic, assign, readonly) NSArray<NSDictionary *>* downloadDataRank;

-(instancetype)initWithRequestTimeThreshold: (NSTimeInterval)requestTimeThreshold;

- (NSDictionary *)reportDic;
- (NSString *)toJson;
@end
