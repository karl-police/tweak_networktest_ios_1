#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <pthread.h>
#import <errno.h>

#import <objc/NSObject.h>

%group NetTestHooks


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


%hook NSURLRequest
- (instancetype)initWithRequest:(NSURLRequest *)request {
    NSLog(@"[Hook] initWithRequest: %@", request);
    return %orig;
}
%end

%hook NSOutputStream
- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len {
    NSLog(@"[NSOutputStream] Writing %lu bytes", (unsigned long)len);
    return %orig(buffer, len);
}
%end



// specific

/*%hook MTGAsyncSocket
- (void)writeData:(NSData *)data withTimeout:(double)timeout tag:(long long)tag {
    NSLog(@"[MTGAsyncSocket][WRITE] %lu bytes: %@", (unsigned long)data.length, data);
    %orig(data, timeout, tag);
}

- (void)setDelegate:(id<MTGAsyncSocketDelegate>)delegate {
    NSLog(@"[MTGAsyncSocket] setDelegate: %@", NSStringFromClass([delegate class]));
    %orig;
}

- (_Bool)connectToHost:(id)host onPort:(unsigned short)port withTimeout:(double)timeout error:(id *)err {
    NSLog(@"[MTGAsyncSocket] Connecting to host: %@, port: %d", host, port);
    return %orig(host, port, timeout, err);
}
%end*/



// Similar thing
// https://github.com/mintexists/ImpostorConfig/blob/main/Tweak.x

NSString *bufferToString(const void *buf, size_t len) {
    NSData *data = [NSData dataWithBytes:buf length:len];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!str) {
        return [NSString stringWithFormat:@"<non-UTF8 data (%lu bytes)>", (unsigned long)len];
    }
    return str;
}




%hookf(int, connect, int sockfd, const struct sockaddr *addr, socklen_t addrlen) {
    struct sockaddr_in *in = (struct sockaddr_in *)addr;
    //if (in->sin_family == AF_INET && in->sin_port == htons(443)) {
        NSLog(@"[+] Connecting to IP: %s:%d", inet_ntoa(in->sin_addr), ntohs(in->sin_port));
    //}
    return %orig;
}
%hookf(ssize_t, sendto, int socket, const void *buffer, size_t length, int flags, const struct sockaddr *dest_addr, socklen_t addrlen) {
    NSLog(@"[sendto] Called: %zu bytes", length);
    NSString *str = [[NSString alloc] initWithBytes:buffer length:length encoding:NSUTF8StringEncoding];
    NSLog(@"[sendto] Data: %@", str);

    return %orig(socket, buffer, length, flags, dest_addr, addrlen);
}

%hookf(int, getaddrinfo, const char *node, const char *service, const struct addrinfo *hints, struct addrinfo **res) {
    NSLog(@"[getaddrinfo] Resolving: %s:%s", node, service);
    return %orig;
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

%end // end group


%ctor {
    %init(NetTestHooks)
}
