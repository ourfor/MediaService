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

static CFHTTPMessageRef responseMessage;

@implementation OHStreamConnection
 
+ (instancetype)sharedInstance {
    static OHStreamConnection *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [OHStreamConnection new];
    });
    return manager;
}
 
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"%@ stream open completed!", [aStream isKindOfClass:NSInputStream.class] ? @"input" : @"output");
            break;
        
        case NSStreamEventHasBytesAvailable:
            // input stream
            [self _handleInputStream:aStream];
            [self _closeStream:aStream];
            break;
        
        case NSStreamEventHasSpaceAvailable:
            // output stream
            [self _handleOutputStream:aStream];
            [self _closeStream:aStream];
            break;
            
        case kCFStreamEventEndEncountered:
            [self _closeConnection];
            break;
            
        case NSStreamEventErrorOccurred:
            if ([aStream streamError]) {
                [self _closeConnection];
            }
            break;
            
        default:
            break;
    }
}

- (void)_closeStream:(NSStream *)stream {
    stream.delegate = nil;
    [stream close];
    [stream removeFromRunLoop:NSRunLoop.currentRunLoop forMode:NSDefaultRunLoopMode];
}

- (void)_closeConnection {
    [self _closeStream:self.inputStream];
    _inputStream = nil;
    [self _closeStream:self.outputStream];
    _outputStream = nil;
    [OHConnectionSharedManager removeConnection:self];
}
 
- (void)_handleOutputStream:(NSStream *)stream {
    if (!isValidOutputStream(stream)) {
        return;
    }
    
    NSOutputStream *outputStream = (NSOutputStream *)stream;
    if (responseMessage) {
        NSData *data = (__bridge NSData *)CFHTTPMessageCopySerializedMessage(responseMessage);
        [outputStream write:data.bytes maxLength:data.length];
        responseMessage = nil;
    }
}
 
- (void)_handleInputStream:(NSStream *)stream {
    if (!isValidInputStream(stream)) {
        return;
    }
    
    NSInputStream *inputStream = (NSInputStream *)stream;
    NSMutableData *data = [NSMutableData data];
#define BUFFER_SIZE 1024
    uint8_t *buffer = malloc(BUFFER_SIZE);
    NSUInteger length = 0;
    do {
        bzero(buffer, BUFFER_SIZE);
        length = [inputStream read:buffer maxLength:BUFFER_SIZE];
        [data appendBytes:buffer length:length];
    } while(length == BUFFER_SIZE);
    CFHTTPMessageRef message = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, YES);
    Boolean isInitRequest = CFHTTPMessageAppendBytes(message, buffer, length);
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
        CFHTTPMessageSetBody(message, (__bridge CFDataRef)contentData);
        responseMessage = message;
    }
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

