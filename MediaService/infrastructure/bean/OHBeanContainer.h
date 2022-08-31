//
//  OHBeanContainer.h
//  MediaService
//
//  Created by 梁甜 on 2022/8/27.
//

#import <Foundation/Foundation.h>

#define LINK(protocol) ([[OHBeanContainer sharedInstance] getBean:protocol])
#define BIND(protocol, value) ([[OHBeanContainer sharedInstance] setBean:protocol value:value])

NS_ASSUME_NONNULL_BEGIN

@interface OHBeanContainer : NSObject
+ (instancetype)sharedInstance;
- (id)getBean:(Protocol *)protocol;
- (void)setBean:(Protocol *)protocol value:(id)value;
@end

NS_ASSUME_NONNULL_END
