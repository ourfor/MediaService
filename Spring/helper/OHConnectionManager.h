//
//  OHConnectionManager.h
//  MediaService
//
//  Created by 梁甜 on 2022/7/19.
//

#import <Foundation/Foundation.h>
#import "OHStreamConnection.h"

#define OHConnectionSharedManager ([OHConnectionManager sharedInstance])

NS_ASSUME_NONNULL_BEGIN

@interface OHConnectionManager : NSObject
@property (nonatomic, strong) NSMutableArray<OHStreamConnection *> *connections;

+ (instancetype)sharedInstance;
- (void)addConnection:(OHStreamConnection *)connection;
- (void)removeConnection:(OHStreamConnection *)connection;
@end

NS_ASSUME_NONNULL_END
