//
//  DoraemonUseLocationDataModel.h
//  DoraemonKit
//
//  Created by tianYang on 2023/1/6.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface DoraemonUseLocationDataModel : RLMObject
@property (nonatomic, copy) NSString * modelId;
@property (nonatomic, assign) double timeStamp;
@property (nonatomic, assign) double useDuration;
@end

