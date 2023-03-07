//
//  DoraemonFPSModel.h
//  DoraemonKit
//
//  Created by Jun Ma on 2023/1/11.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoraemonFPSModel : RLMObject

@property(nonatomic, copy) NSString * modelId;
@property(nonatomic, assign) NSTimeInterval timestamp;
@property(nonatomic, assign) NSInteger value;
@property(nonatomic, copy) NSString *topViewName;

@end

NS_ASSUME_NONNULL_END
