//
//  OHSocketStreamManager.h
//  MediaService
//
//  Created by 梁甜 on 2022/7/17.
//

#import <Foundation/Foundation.h>

#define OHSocketStreamSharedManager ([OHSocketStreamManager sharedInstance])

NS_ASSUME_NONNULL_BEGIN

@interface OHSocketStreamManager : NSObject<NSStreamDelegate>
+(instancetype)sharedInstance;
@end

NS_ASSUME_NONNULL_END
