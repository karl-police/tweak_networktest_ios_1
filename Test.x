#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <sys/socket.h>
#include <unistd.h>


%hook NSURLSession
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request {
    NSLog(@"[+] Request: %@", request);
    return %orig;
}

- (NSURLSessionWebSocketTask *)webSocketTaskWithRequest:(NSURLRequest *)request {
    NSLog(@"[NSURLSessionWebSocketTask] Request: %@", request);
    return %orig;
}
%end




NSString *bufferToString(const void *buf, size_t len) {
    NSData *data = [NSData dataWithBytes:buf length:len];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!str) {
        return [NSString stringWithFormat:@"<non-UTF8 data (%lu bytes)>", (unsigned long)len];
    }
    return str;
}


%hookf(ssize_t, send, int sockfd, const void *buf, size_t len, int flags) {
    NSString *out = bufferToString(buf, len);
    NSLog(@"[Socket SEND] fd=%d, bytes=%zu\n%@", sockfd, len, out);
    return %orig(sockfd, buf, len, flags);
}

%hookf(ssize_t, recv, int sockfd, void *buf, size_t len, int flags) {
    ssize_t received = %orig(sockfd, buf, len, flags);
    if (received > 0) {
        NSString *in = bufferToString(buf, received);
        NSLog(@"[Socket RECV] fd=%d, bytes=%zd\n%@", sockfd, received, in);
    }
    return received;
}
