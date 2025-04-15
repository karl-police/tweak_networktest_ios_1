#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <pthread.h>
#import <errno.h>


import <objc/NSObject.h>

@class MTGAsyncReadPacket, MTGAsyncSocketPreBuffer, MTGAsyncWritePacket, NSData, NSMutableArray, NSString, NSURL;
@protocol MTGAsyncSocketDelegate, OS_dispatch_queue, OS_dispatch_source;

@interface MTGAsyncSocket : NSObject
{
    unsigned int flags;
    unsigned short config;
    id <MTGAsyncSocketDelegate> delegate;
    NSObject<OS_dispatch_queue> *delegateQueue;
    int socket4FD;
    int socket6FD;
    int socketUN;
    NSURL *socketUrl;
    int stateIndex;
    NSData *connectInterface4;
    NSData *connectInterface6;
    NSData *connectInterfaceUN;
    NSObject<OS_dispatch_queue> *socketQueue;
    NSObject<OS_dispatch_source> *accept4Source;
    NSObject<OS_dispatch_source> *accept6Source;
    NSObject<OS_dispatch_source> *acceptUNSource;
    NSObject<OS_dispatch_source> *connectTimer;
    NSObject<OS_dispatch_source> *readSource;
    NSObject<OS_dispatch_source> *writeSource;
    NSObject<OS_dispatch_source> *readTimer;
    NSObject<OS_dispatch_source> *writeTimer;
    NSMutableArray *readQueue;
    NSMutableArray *writeQueue;
    MTGAsyncReadPacket *currentRead;
    MTGAsyncWritePacket *currentWrite;
    unsigned long long socketFDBytesAvailable;
    MTGAsyncSocketPreBuffer *preBuffer;
    CDStruct_4210025a streamContext;
    struct __CFReadStream *readStream;
    struct __CFWriteStream *writeStream;
    struct SSLContext *sslContext;
    MTGAsyncSocketPreBuffer *sslPreBuffer;
    unsigned long long sslWriteCachedLength;
    int sslErrCode;
    int lastSSLHandshakeError;
    void *IsOnSocketQueueOrTargetQueueKey;
    id userData;
    double alternateAddressDelay;
}

+ (id)ZeroData;
+ (id)LFData;
+ (id)CRData;
+ (id)CRLFData;
+ (_Bool)getHost:(id *)arg1 port:(unsigned short *)arg2 family:(char *)arg3 fromAddress:(id)arg4;
+ (_Bool)getHost:(id *)arg1 port:(unsigned short *)arg2 fromAddress:(id)arg3;
+ (_Bool)isIPv6Address:(id)arg1;
+ (_Bool)isIPv4Address:(id)arg1;
+ (unsigned short)portFromAddress:(id)arg1;
+ (id)hostFromAddress:(id)arg1;
+ (id)urlFromSockaddrUN:(const struct sockaddr_un *)arg1;
+ (unsigned short)portFromSockaddr6:(const struct sockaddr_in6 *)arg1;
+ (unsigned short)portFromSockaddr4:(const struct sockaddr_in *)arg1;
+ (id)hostFromSockaddr6:(const struct sockaddr_in6 *)arg1;
+ (id)hostFromSockaddr4:(const struct sockaddr_in *)arg1;
+ (id)lookupHost:(id)arg1 port:(unsigned short)arg2 error:(id *)arg3;
+ (void)unscheduleCFStreams:(id)arg1;
+ (void)scheduleCFStreams:(id)arg1;
+ (void)cfstreamThread:(id)arg1;
+ (void)stopCFStreamThreadIfNeeded;
+ (void)startCFStreamThreadIfNeeded;
+ (void)ignore:(id)arg1;
+ (id)gaiError:(int)arg1;
+ (id)socketFromConnectedSocketFD:(int)arg1 delegate:(id)arg2 delegateQueue:(id)arg3 socketQueue:(id)arg4 error:(id *)arg5;
+ (id)socketFromConnectedSocketFD:(int)arg1 delegate:(id)arg2 delegateQueue:(id)arg3 error:(id *)arg4;
+ (id)socketFromConnectedSocketFD:(int)arg1 socketQueue:(id)arg2 error:(id *)arg3;
- (void).cxx_destruct;
- (struct SSLContext *)sslContext;
- (_Bool)enableBackgroundingOnSocketWithCaveat;
- (_Bool)enableBackgroundingOnSocket;
- (_Bool)enableBackgroundingOnSocketWithCaveat:(_Bool)arg1;
- (struct __CFWriteStream *)writeStream;
- (struct __CFReadStream *)readStream;
- (int)socket6FD;
- (int)socket4FD;
- (int)socketFD;
- (void)performBlock:(CDUnknownBlockType)arg1;
- (void)unmarkSocketQueueTargetQueue:(id)arg1;
- (void)markSocketQueueTargetQueue:(id)arg1;
@property _Bool autoDisconnectOnClosedReadStream;
- (_Bool)openStreams;
- (void)removeStreamsFromRunLoop;
- (_Bool)addStreamsToRunLoop;
- (_Bool)registerForStreamCallbacksIncludingReadWrite:(_Bool)arg1;
- (_Bool)createReadAndWriteStream;
- (void)cf_startTLS;
- (void)cf_abortSSLHandshake:(id)arg1;
- (void)cf_finishSSLHandshake;
- (void)ssl_shouldTrustPeer:(_Bool)arg1 stateIndex:(int)arg2;
- (void)ssl_continueSSLHandshake;
- (void)ssl_startTLS;
- (int)sslWriteWithBuffer:(const void *)arg1 length:(unsigned long long *)arg2;
- (int)sslReadWithBuffer:(void *)arg1 length:(unsigned long long *)arg2;
- (void)maybeStartTLS;
- (void)startTLS:(id)arg1;
- (void)doWriteTimeoutWithExtension:(double)arg1;
- (void)doWriteTimeout;
- (void)setupWriteTimerWithTimeout:(double)arg1;
- (void)endCurrentWrite;
- (void)completeCurrentWrite;
- (void)doWriteData;
- (void)maybeDequeueWrite;
- (float)progressOfWriteReturningTag:(long long *)arg1 bytesDone:(unsigned long long *)arg2 total:(unsigned long long *)arg3;
- (void)writeData:(id)arg1 withTimeout:(double)arg2 tag:(long long)arg3;
- (void)doReadTimeoutWithExtension:(double)arg1;
- (void)doReadTimeout;
- (void)setupReadTimerWithTimeout:(double)arg1;
- (void)endCurrentRead;
- (void)completeCurrentRead;
- (void)doReadEOF;
- (void)doReadData;
- (void)flushSSLBuffers;
- (void)maybeDequeueRead;
- (float)progressOfReadReturningTag:(long long *)arg1 bytesDone:(unsigned long long *)arg2 total:(unsigned long long *)arg3;
- (void)readDataToData:(id)arg1 withTimeout:(double)arg2 buffer:(id)arg3 bufferOffset:(unsigned long long)arg4 maxLength:(unsigned long long)arg5 tag:(long long)arg6;
- (void)readDataToData:(id)arg1 withTimeout:(double)arg2 maxLength:(unsigned long long)arg3 tag:(long long)arg4;
- (void)readDataToData:(id)arg1 withTimeout:(double)arg2 buffer:(id)arg3 bufferOffset:(unsigned long long)arg4 tag:(long long)arg5;
- (void)readDataToData:(id)arg1 withTimeout:(double)arg2 tag:(long long)arg3;
- (void)readDataToLength:(unsigned long long)arg1 withTimeout:(double)arg2 buffer:(id)arg3 bufferOffset:(unsigned long long)arg4 tag:(long long)arg5;
- (void)readDataToLength:(unsigned long long)arg1 withTimeout:(double)arg2 tag:(long long)arg3;
- (void)readDataWithTimeout:(double)arg1 buffer:(id)arg2 bufferOffset:(unsigned long long)arg3 maxLength:(unsigned long long)arg4 tag:(long long)arg5;
- (void)readDataWithTimeout:(double)arg1 buffer:(id)arg2 bufferOffset:(unsigned long long)arg3 tag:(long long)arg4;
- (void)readDataWithTimeout:(double)arg1 tag:(long long)arg2;
- (void)resumeWriteSource;
- (void)suspendWriteSource;
- (void)resumeReadSource;
- (void)suspendReadSource;
- (_Bool)usingSecureTransportForTLS;
- (_Bool)usingCFStreamForTLS;
- (void)setupReadAndWriteSourcesForNewlyConnectedSocket:(int)arg1;
- (id)getInterfaceAddressFromUrl:(id)arg1;
- (void)getInterfaceAddress4:(id *)arg1 address6:(id *)arg2 fromDescription:(id)arg3 port:(unsigned short)arg4;
@property(readonly) _Bool isSecure;
@property(readonly) _Bool isIPv6;
@property(readonly) _Bool isIPv4;
@property(readonly) NSData *localAddress;
@property(readonly) NSData *connectedAddress;
- (unsigned short)localPortFromSocket6:(int)arg1;
- (unsigned short)localPortFromSocket4:(int)arg1;
- (id)localHostFromSocket6:(int)arg1;
- (id)localHostFromSocket4:(int)arg1;
- (id)connectedUrlFromSocketUN:(int)arg1;
- (unsigned short)connectedPortFromSocket6:(int)arg1;
- (unsigned short)connectedPortFromSocket4:(int)arg1;
- (id)connectedHostFromSocket6:(int)arg1;
- (id)connectedHostFromSocket4:(int)arg1;
- (unsigned short)localPort6;
- (unsigned short)localPort4;
- (id)localHost6;
- (id)localHost4;
- (unsigned short)connectedPort6;
- (unsigned short)connectedPort4;
- (id)connectedHost6;
- (id)connectedHost4;
@property(readonly) unsigned short localPort;
@property(readonly) NSString *localHost;
@property(readonly) NSURL *connectedUrl;
@property(readonly) unsigned short connectedPort;
@property(readonly) NSString *connectedHost;
@property(readonly) _Bool isConnected;
@property(readonly) _Bool isDisconnected;
- (id)otherError:(id)arg1;
- (id)connectionClosedError;
- (id)writeTimeoutError;
- (id)readTimeoutError;
- (id)readMaxedOutError;
- (id)connectTimeoutError;
- (id)sslError:(int)arg1;
- (id)errnoError;
- (id)errorWithErrno:(int)arg1 reason:(id)arg2;
- (id)badParamError:(id)arg1;
- (id)badConfigError:(id)arg1;
- (void)maybeClose;
- (void)disconnectAfterReadingAndWriting;
- (void)disconnectAfterWriting;
- (void)disconnectAfterReading;
- (void)disconnect;
- (void)closeWithError:(id)arg1;
- (void)doConnectTimeout;
- (void)endConnectTimeout;
- (void)startConnectTimeout:(double)arg1;
- (void)didNotConnect:(int)arg1 error:(id)arg2;
- (void)didConnect:(int)arg1;
- (_Bool)connectWithAddressUN:(id)arg1 error:(id *)arg2;
- (_Bool)connectWithAddress4:(id)arg1 address6:(id)arg2 error:(id *)arg3;
- (void)closeUnusedSocket:(int)arg1;
- (void)closeSocket:(int)arg1;
- (void)connectSocket:(int)arg1 address:(id)arg2 stateIndex:(int)arg3;
- (int)createSocket:(int)arg1 connectInterface:(id)arg2 errPtr:(id *)arg3;
- (_Bool)bindSocket:(int)arg1 toInterface:(id)arg2 error:(id *)arg3;
- (void)lookup:(int)arg1 didFail:(id)arg2;
- (void)lookup:(int)arg1 didSucceedWithAddress4:(id)arg2 address6:(id)arg3;
- (_Bool)connectToNetService:(id)arg1 error:(id *)arg2;
- (_Bool)connectToUrl:(id)arg1 withTimeout:(double)arg2 error:(id *)arg3;
- (_Bool)connectToAddress:(id)arg1 viaInterface:(id)arg2 withTimeout:(double)arg3 error:(id *)arg4;
- (_Bool)connectToAddress:(id)arg1 withTimeout:(double)arg2 error:(id *)arg3;
- (_Bool)connectToAddress:(id)arg1 error:(id *)arg2;
- (_Bool)connectToHost:(id)arg1 onPort:(unsigned short)arg2 viaInterface:(id)arg3 withTimeout:(double)arg4 error:(id *)arg5;
- (_Bool)connectToHost:(id)arg1 onPort:(unsigned short)arg2 withTimeout:(double)arg3 error:(id *)arg4;
- (_Bool)connectToHost:(id)arg1 onPort:(unsigned short)arg2 error:(id *)arg3;
- (_Bool)preConnectWithUrl:(id)arg1 error:(id *)arg2;
- (_Bool)preConnectWithInterface:(id)arg1 error:(id *)arg2;
- (_Bool)doAccept:(int)arg1;
- (_Bool)acceptOnUrl:(id)arg1 error:(id *)arg2;
- (_Bool)acceptOnInterface:(id)arg1 port:(unsigned short)arg2 error:(id *)arg3;
- (_Bool)acceptOnPort:(unsigned short)arg1 error:(id *)arg2;
@property(retain) id userData;
@property double alternateAddressDelay;
@property(getter=isIPv4PreferredOverIPv6) _Bool IPv4PreferredOverIPv6;
@property(getter=isIPv6Enabled) _Bool IPv6Enabled;
@property(getter=isIPv4Enabled) _Bool IPv4Enabled;
- (void)synchronouslySetDelegate:(id)arg1 delegateQueue:(id)arg2;
- (void)setDelegate:(id)arg1 delegateQueue:(id)arg2;
- (void)setDelegate:(id)arg1 delegateQueue:(id)arg2 synchronously:(_Bool)arg3;
- (void)getDelegate:(id *)arg1 delegateQueue:(id *)arg2;
- (void)synchronouslySetDelegateQueue:(id)arg1;
@property(retain) NSObject<OS_dispatch_queue> *delegateQueue;
- (void)setDelegateQueue:(id)arg1 synchronously:(_Bool)arg2;
- (void)synchronouslySetDelegate:(id)arg1;
@property __weak id <MTGAsyncSocketDelegate> delegate;
- (void)setDelegate:(id)arg1 synchronously:(_Bool)arg2;
- (void)dealloc;
- (id)initWithDelegate:(id)arg1 delegateQueue:(id)arg2 socketQueue:(id)arg3;
- (id)initWithDelegate:(id)arg1 delegateQueue:(id)arg2;
- (id)initWithSocketQueue:(id)arg1;
- (id)init;

@end


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

%hook MTGAsyncSocket
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
%end



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
