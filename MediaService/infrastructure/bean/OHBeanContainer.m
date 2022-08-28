//
//  OHBeanContainer.m
//  MediaService
//
//  Created by 梁甜 on 2022/8/27.
//

#import "OHBeanContainer.h"

@interface OHBeanContainer ()
@property (nonatomic, strong) NSMapTable<Protocol *, id> *holder;
@end

@implementation OHBeanContainer

- (void)setBean:(Protocol *)protocol value:(id)value {
    if (!protocol || !value) {
        return;
    }
    
    [self.holder setObject:value forKey:protocol];
}

- (id)getBean:(Protocol *)protocol {
    if (!protocol) {
        return nil;
    }
    
    __strong id bean = [self.holder objectForKey:protocol];
    return bean;
}

#pragma mark Getter
- (NSMapTable<Protocol *,id> *)holder {
    if (!_holder) {
        _holder = [NSMapTable strongToWeakObjectsMapTable];
    }
    return _holder;
}

@end
