//
//  OHSocketStreamManager.h
//  MediaService
//
//  Created by 梁甜 on 2022/7/17.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface OHStreamConnection : NSObject<NSStreamDelegate>
@property (nonatomic, assign) CFReadStreamRef readStream;
@property (nonatomic, assign) CFWriteStreamRef writeStream;
@property (nonatomic, assign) CFSocketNativeHandle socket;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, assign) BOOL isReadStreamOpen;
@property (nonatomic, assign) BOOL isWriteStreamOpen;

+(instancetype)sharedInstance;
- (void)open;
- (void)close;
- (void)closeIfNeeded;
- (void)handleReadStream:(CFReadStreamRef)readStream;
- (void)handleWriteStream:(CFWriteStreamRef)writeStream;
@end

NS_ASSUME_NONNULL_END
