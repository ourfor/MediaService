//
//  OHComponentSource.h
//  MediaService
//
//  Created by 梁甜 on 2022/9/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OHComponentSource <NSObject>

@optional
- (NSArray<NSString *> *)componentClassNames;
- (NSArray<Class *> *)componentClasses;

@end

NS_ASSUME_NONNULL_END
