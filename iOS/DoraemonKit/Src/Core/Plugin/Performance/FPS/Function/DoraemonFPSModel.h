//
//  DoraemonFPSModel.h
//  DoraemonKit
//
//  Created by Jun Ma on 2023/1/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoraemonFPSModel : NSObject

@property(nonatomic, assign) NSTimeInterval timestamp;
@property(nonatomic, assign) NSInteger value;

@end

NS_ASSUME_NONNULL_END
