//
//  OHSocketStreamManager.m
//  MediaService
//
//  Created by 梁甜 on 2022/7/17.
//

#import "OHSocketStreamManager.h"

static CFHTTPMessageRef responseMessage;

@implementation OHSocketStreamManager
 
+ (instancetype)sharedInstance {
    static OHSocketStreamManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [OHSocketStreamManager new];
    });
    return manager;
}
 
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            NSLog(@"open completed!");
            break;
        
        case NSStreamEventHasBytesAvailable:
            // input stream
            [self _handleInputStream:aStream];
            break;
        
        case NSStreamEventHasSpaceAvailable:
            // output stream
            [self _handleOutputStream:aStream];
            break;
            
        default:
            break;
    }
}
 
- (void)_handleOutputStream:(NSStream *)stream {
#define isValidOutputStream(stream) (stream && [stream isKindOfClass:NSOutputStream.class])
    if (!isValidOutputStream(stream)) {
        return;
    }
    
    NSOutputStream *outputStream = (NSOutputStream *)stream;
    if (responseMessage) {
        NSData *data = (__bridge NSData *)CFHTTPMessageCopySerializedMessage(responseMessage);
        [outputStream write:data.bytes maxLength:data.length];
        responseMessage = nil;
    }
    [outputStream close];
}
 
- (void)_handleInputStream:(NSStream *)stream {
#define isValidInputStream(stream) (stream && [stream isKindOfClass:NSInputStream.class])
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
    [inputStream close];
}
 
@end

