//
//  main.m
//  MediaService
//
//  Created by 梁甜 on 2022/7/17.
//

#include <iostream>
#include <dispatch/dispatch.h>
#include <semaphore.h>
#include <Foundation/Foundation.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <errno.h>
#include <string.h>
#include "OHStreamConnection.h"
#include "OHConnectionManager.h"
 
using namespace std;
 
extern errno_t errno;
 
typedef enum IPVersion {
    IPV4 = 4,
    IPV6 = 6
} IPVersion;
 
void handleSocketData(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
#define BUFFER_SIZE 1024
    NSLog(@"new connect!");
    CFSocketNativeHandle fd = *(const int *)data;
    if (fd < 0) {
        return;
    }
    CFReadStreamRef readStream = nil;
    CFWriteStreamRef writeStream = nil;
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, fd, &readStream, &writeStream);
    
    NSInputStream *inputStream = (__bridge_transfer NSInputStream *)readStream;
    NSOutputStream *outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    [inputStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
    [outputStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
    OHStreamConnection *connection = [OHStreamConnection new];
    connection.inputStream = inputStream;
    connection.outputStream = outputStream;
    OHConnectionManager *manager = (__bridge OHConnectionManager *)info;
    [manager addConnection:connection];
    [inputStream scheduleInRunLoop:NSRunLoop.currentRunLoop forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:NSRunLoop.currentRunLoop forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
}
 
void bindSocketAddress(CFSocketRef socket, NSUInteger port, IPVersion ipVersion) {
    CFSocketError error;
    CFDataRef addressData = nil;
    if (ipVersion == IPV4) {
        struct sockaddr_in addressV4 = {
            .sin_len = sizeof(struct sockaddr_in),
            .sin_port = htons(port),
            .sin_family = PF_INET,
            .sin_addr = {
                .s_addr = INADDR_ANY
            },
            0
        };
        addressData = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&addressV4, sizeof(struct sockaddr_in));
    } else if (ipVersion == IPV6) {
        struct sockaddr_in6 addressV6 = {
            .sin6_len = sizeof(struct sockaddr_in6),
            .sin6_family = PF_INET6,
            .sin6_port = htons(port),
            .sin6_addr = INADDR_ANY,
            0
        };
        addressData = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&addressV6, sizeof(struct sockaddr_in6));
    }
    
    
    error = CFSocketSetAddress(socket, addressData);
    if (error == kCFSocketError) {
        NSString *reason = @(strerror(errno));
        NSLog(@"%@", reason);
    }
    CFRelease(addressData);
    
    BOOL reuse = YES;
    CFSocketNativeHandle fd = CFSocketGetNative(socket);
    CFSocketSetSocketFlags(socket, kCFSocketCloseOnInvalidate);
    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (void *)&reuse, sizeof(BOOL));
    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (void *)&reuse, sizeof(BOOL));
}
 
int main() {
    CFSocketContext context = { 0, (__bridge void *)OHConnectionSharedManager, NULL, NULL, NULL };
    CFSocketCallBackType callbackType = kCFSocketAcceptCallBack;
    CFSocketRef socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, callbackType, handleSocketData, &context);
    CFSocketRef socketV6 = CFSocketCreate(kCFAllocatorDefault, PF_INET6, SOCK_STREAM, IPPROTO_TCP, callbackType, handleSocketData, &context);
    
    NSUInteger port = 9999;
    bindSocketAddress(socket, port, IPV4);
    bindSocketAddress(socketV6, port, IPV6);
    
    CFRunLoopSourceRef ipv4SocketSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socket, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), ipv4SocketSource, kCFRunLoopDefaultMode);
    CFRunLoopSourceRef ipv6SocketSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, socketV6, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), ipv6SocketSource, kCFRunLoopDefaultMode);
    
    NSLog(@"Server start *:%lu", (unsigned long)port);
    CFRunLoopRun();
}
