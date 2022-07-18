//
//  OHSocketStreamManager.h
//  MediaService
//
//  Created by 梁甜 on 2022/7/17.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface OHStreamConnection : NSObject<NSStreamDelegate>
+(instancetype)sharedInstance;

@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@end

NS_ASSUME_NONNULL_END
