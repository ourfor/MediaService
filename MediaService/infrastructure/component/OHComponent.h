//
//  OHComponent.h
//  MediaService
//
//  Created by 梁甜 on 2022/8/18.
//

#import <Foundation/Foundation.h>
#import "OHComponentContext.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, OHComponentPhase) {
    OHComponentWillMount,
    OHComponentDidMount,
    OHComponentWillAppear,
    OHComponentDidAppear,
    OHComponentWillDisappear,
    OHComponentDidDisappear,
    OHComponentWillUnmount
};

@protocol OHComponent <NSObject>
+ (void)component:(id<OHComponentContext>)context;

- (void)componentWillMount:(id<OHComponentContext>)context;
- (void)componentDidMount:(id<OHComponentContext>)context;
- (void)componentWillAppear:(id<OHComponentContext>)context;
- (void)componentDidAppear:(id<OHComponentContext>)context;
- (void)componentWillDisappear:(id<OHComponentContext>)context;
- (void)componentDidDisappear:(id<OHComponentContext>)context;
- (void)componentWillUnmount:(id<OHComponentContext>)context;
@end

NS_ASSUME_NONNULL_END
