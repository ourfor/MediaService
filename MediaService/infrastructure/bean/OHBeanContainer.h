//
//  OHBeanContainer.h
//  MediaService
//
//  Created by 梁甜 on 2022/8/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OHBeanContainer : NSObject
- (id)getBean:(Protocol *)protocol;
- (void)setBean:(Protocol *)protocol value:(id)value;
@end

NS_ASSUME_NONNULL_END
