//
//  OHSocketStreamManager.m
//  MediaService
//
//  Created by 梁甜 on 2022/7/17.
//

#import "OHStreamConnection.h"
#import "OHConnectionManager.h"

#define isValidInputStream(stream) (stream && [stream isKindOfClass:NSInputStream.class])
#define isValidOutputStream(stream) (stream && [stream isKindOfClass:NSOutputStream.class])
#define Lock(locker) dispatch_semaphore_wait(locker, DISPATCH_TIME_FOREVER)
#define Unlock(locker) dispatch_semaphore_signal(locker)
#define BUFFER_SIZE 1024

void ReadStreamClientCallBack(CFReadStreamRef _Null_unspecified stream, CFStreamEventType type, void * _Null_unspecified clientCallBackInfo) {
    OHStreamConnection *connection = (__bridge OHStreamConnection *)clientCallBackInfo;
    switch (type) {
        case kCFStreamEventOpenCompleted:
            connection.isReadStreamOpen = YES;
            NSLog(@"read stream open complete");
            break;
            
        case kCFStreamEventHasBytesAvailable:
            [connection handleReadStream:stream];
            break;
        
        case kCFStreamEventEndEncountered:
//            CFReadStreamUnscheduleFromRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
//            CFReadStreamClose(stream);
//            CFRelease(stream);
//            stream = nil;
            connection.isReadStreamOpen = NO;
//            [connection closeIfNeeded];
            break;
            
        default:
            break;
    }
}

void WriteStreamClientCallBack(CFWriteStreamRef _Null_unspecified stream, CFStreamEventType type, void * _Null_unspecified clientCallBackInfo) {
    OHStreamConnection *connection = (__bridge OHStreamConnection *)clientCallBackInfo;
    switch (type) {
        case kCFStreamEventOpenCompleted:
            connection.isWriteStreamOpen = YES;
            NSLog(@"write stream open complete");
            break;
        
        case kCFStreamEventCanAcceptBytes:
            [connection handleWriteStream:stream];
        
        case kCFStreamEventEndEncountered:
//            CFWriteStreamUnscheduleFromRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
//            CFWriteStreamClose(stream);
//            CFRelease(stream);
//            stream = nil;
            connection.isWriteStreamOpen = NO;
            [connection closeIfNeeded];
            break;
            
        default:
            break;
    }
}

@interface OHStreamConnection ()
@property (nonatomic, assign) CFHTTPMessageRef responseMessage;
@property (nonatomic, assign) CFHTTPMessageRef requestMessage;
@property (nonatomic, strong) dispatch_semaphore_t locker;
@end

@implementation OHStreamConnection
 
+ (instancetype)sharedInstance {
    static OHStreamConnection *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [OHStreamConnection new];
    });
    return manager;
}

- (void)open {
    CFOptionFlags readEvents = kCFStreamEventOpenCompleted | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered | kCFStreamEventHasBytesAvailable;
    CFOptionFlags writeEvents = kCFStreamEventOpenCompleted | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered | kCFStreamEventCanAcceptBytes;
    CFStreamClientContext context = {0, (__bridge void *)self, NULL, NULL, NULL};
    CFReadStreamSetProperty(self.readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    if (CFReadStreamSetClient(self.readStream, readEvents, ReadStreamClientCallBack, &context)) {
        CFReadStreamScheduleWithRunLoop(self.readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFRelease(self.readStream);
    }
    
    CFWriteStreamSetProperty(self.writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
    if (CFWriteStreamSetClient(self.writeStream, writeEvents, WriteStreamClientCallBack, &context)) {
        CFWriteStreamScheduleWithRunLoop(self.writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFRelease(self.writeStream);
    }
    CFReadStreamOpen(self.readStream);
    CFWriteStreamOpen(self.writeStream);
    self.locker = dispatch_semaphore_create(1);
}

- (void)closeIfNeeded {
    if (self.isReadStreamOpen || self.isWriteStreamOpen) {
        return;
    }
    
    [self close];
}
 
- (void)close {
    if (_readStream) {
        CFReadStreamUnscheduleFromRunLoop(_readStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFRelease(_readStream);
        _readStream = nil;
    }
    
    if (_writeStream) {
        CFWriteStreamUnscheduleFromRunLoop(_writeStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        CFRelease(_writeStream);
        _writeStream = nil;
    }
    
//    close(self.socket);
    
    if (_requestMessage) {
        CFRelease(_requestMessage);
        _requestMessage = nil;
    }
    
    if (_responseMessage) {
        CFRelease(_responseMessage);
        _responseMessage = nil;
    }
    
    [OHConnectionSharedManager removeConnection:self];
}

- (void)handleReadStream:(CFReadStreamRef)readStream {
    Lock(self.locker);
    UInt8 *buffer = malloc(BUFFER_SIZE);
    bzero(buffer, BUFFER_SIZE);
    CFIndex length = CFReadStreamRead(readStream, buffer, BUFFER_SIZE);
    CFHTTPMessageRef message = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, YES);
    Boolean isInitRequest = CFHTTPMessageAppendBytes(message, buffer, length);
    self.requestMessage = message;
    if (isInitRequest) {
        Boolean isHeaderComplete = CFHTTPMessageIsHeaderComplete(message);
        if (isHeaderComplete) {
            NSDictionary *header = (__bridge NSDictionary *)CFHTTPMessageCopyAllHeaderFields(message);
            NSLog(@"header %@", header);
        }
        NSURL *url = (__bridge NSURL *)CFHTTPMessageCopyRequestURL(message);
        NSLog(@"url: %@", url);
        NSString *method = (__bridge NSString *)CFHTTPMessageCopyRequestMethod(message);
        NSLog(@"method: %@", method);
        
        NSDictionary *content = @{
            @"message": @"Hello World"
        };
        NSData *contentData = [NSJSONSerialization dataWithJSONObject:content options:NSJSONWritingPrettyPrinted error:nil];
        
        CFHTTPMessageRef message = CFHTTPMessageCreateResponse(kCFAllocatorDefault, 200, NULL, kCFHTTPVersion2_0);
        CFHTTPMessageSetHeaderFieldValue(message, (__bridge CFStringRef)@"Content-Type", (__bridge CFStringRef)@"application/json");
        CFHTTPMessageSetHeaderFieldValue(message, (__bridge CFStringRef)@"Connection", (__bridge CFStringRef)@"close");
        CFHTTPMessageSetHeaderFieldValue(message, (__bridge CFStringRef)@"Content-Length", (__bridge CFStringRef)@(contentData.length).stringValue);
        CFHTTPMessageSetBody(message, (__bridge CFDataRef)contentData);
        self.responseMessage = message;
    }
    
    Unlock(self.locker);
}

- (void)handleWriteStream:(CFWriteStreamRef)writeStream {
    Lock(self.locker);
    if (self.responseMessage) {
        NSData *data = (__bridge NSData *)CFHTTPMessageCopySerializedMessage(self.responseMessage);
        CFIndex lengthWrote = 0;
        while (lengthWrote != data.length) {
            if (CFWriteStreamCanAcceptBytes(writeStream)) {
                const UInt8 *buffer = data.bytes + lengthWrote;
                CFIndex size = data.length - lengthWrote;
                lengthWrote += CFWriteStreamWrite(writeStream, buffer, size);
            }
        }
        CFRelease(self.responseMessage);
        self.responseMessage = nil;
    }
    Unlock(self.locker);
}
 
#pragma Setter
- (void)setInputStream:(NSInputStream *)inputStream {
    _inputStream = inputStream;
    inputStream.delegate = self;
}

- (void)setOutputStream:(NSOutputStream *)outputStream {
    _outputStream = outputStream;
    outputStream.delegate = self;
}
 
@end

