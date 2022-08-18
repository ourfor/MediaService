//
//  OHComponentLoader.m
//  MediaService
//
//  Created by 梁甜 on 2022/8/18.
//

#import "OHComponentLoader.h"
#import "OHComponent.h"

@interface OHComponentLoader ()
@property (nonatomic, copy) NSMutableArray<id<OHComponent>> *components;
@property (nonatomic, strong) id<OHComponentContext> context;

- (void)loadComponentWithPhase:(OHComponentPhase)phase;
- (SEL)selectorForPhase:(OHComponentPhase)phase;
@end

@implementation OHComponentLoader

- (void)loadComponentWithPhase:(OHComponentPhase)phase {
    if (!self.components) {
        return;
    }
    
    SEL lifeCycle = [self selectorForPhase:phase];
    NSArray<id<OHComponent>> *components = self.components;
    id<OHComponentContext> context = self.context;
    for (id<OHComponent> component in components) {
        if (![component respondsToSelector:lifeCycle]) {
            continue;
        }
        
        [component performSelector:lifeCycle withObject:context];
    }
}


- (SEL)selectorForPhase:(OHComponentPhase)phase {
    SEL selector = nil;
    switch (phase) {
        case OHComponentWillMount:
            selector = @selector(componentWillMount:);
            break;
        case OHComponentDidMount:
            selector = @selector(componentDidMount:);
            break;
        case OHComponentWillAppear:
            selector = @selector(componentWillAppear:);
            break;
        case OHComponentDidAppear:
            selector = @selector(componentDidAppear:);
            break;
        case OHComponentWillDisappear:
            selector = @selector(componentWillDisappear:);
            break;
        case OHComponentDidDisappear:
            selector = @selector(componentDidDisappear:);
            break;
        case OHComponentWillUnmount:
            selector = @selector(componentWillUnmount:);
            break;
        default:
            break;
    }
    return selector;
}

@end
