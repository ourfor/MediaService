//
//  OHConnectionManager.m
//  MediaService
//
//  Created by 梁甜 on 2022/7/19.
//

#import "OHConnectionManager.h"
#import "OHComponentLoader.h"


@implementation OHConnectionManager

+ (instancetype)sharedInstance {
    static OHConnectionManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [OHConnectionManager new];
    });
    return instance;
}

- (void)addConnection:(OHStreamConnection *)connection {
    if (connection) {
        [self.connections addObject:connection];
    }
}

- (void)removeConnection:(OHStreamConnection *)connection {
    if (connection) {
        [self.connections removeObject:connection];
    }
}

- (NSMutableArray<OHStreamConnection *> *)connections {
    if (!_connections) {
        _connections = [NSMutableArray array];
    }
    return _connections;
}

@end
