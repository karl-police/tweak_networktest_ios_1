#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import <netdb.h>
#import <pthread.h>
#import <errno.h>
#import <stdint.h>

#import <substrate.h>
#import <mach-o/dyld.h>


typedef int64_t (*FuncType)(int64_t a1, int64_t a2, int64_t a3);
FuncType targetFunction = NULL;


%group NetTestHooks

@interface SimpleButtonManager : NSObject

@property (nonatomic, strong) UIButton *button;  // Main button
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;  // Dragging gesture recognizer

+ (instancetype)sharedInstance;
- (void)createButton;
- (void)removeButton;
- (void)buttonTouchedDown;
- (void)buttonTouchedUp;

@end

@implementation SimpleButtonManager

+ (instancetype)sharedInstance {
    static SimpleButtonManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SimpleButtonManager alloc] init];
    });
    return instance;
}

- (void)createButton {
  if (!self.button) {
      self.button = [UIButton buttonWithType:UIButtonTypeCustom];
      self.button.frame = CGRectMake(11, 198, 82, 82);
      self.button.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.37];
      self.button.layer.cornerRadius = 10; // Not circular, slightly rounded corners
      self.button.layer.masksToBounds = YES;
      self.button.layer.borderColor = [UIColor colorWithWhite:0.45 alpha:1.0].CGColor;
      self.button.layer.borderWidth = 3.33;
      self.button.alpha = 0.45;

      [self.button addTarget:self action:@selector(buttonTouchedDown) forControlEvents:UIControlEventTouchDown];
      [self.button addTarget:self action:@selector(buttonTouchedUp) forControlEvents:UIControlEventTouchUpInside];
      [self.button addTarget:self action:@selector(buttonTouchedUp) forControlEvents:UIControlEventTouchUpOutside];

      // Add dragging gesture
      self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
      [self.button addGestureRecognizer:self.panGestureRecognizer];

      // Using connectedScenes to get the window in iOS 13 and later
      UIWindow *window = nil;
      for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
          if (scene.activationState == UISceneActivationStateForegroundActive) {
              window = ((UIWindowScene *)scene).windows.firstObject;
              break;
          }
      }

      if (window) {
          [window addSubview:self.button];
      } else {
          NSLog(@"No active window found.");
      }
  }
}

- (void)removeButton {
  if (self.button) {
      [self.button removeGestureRecognizer:self.panGestureRecognizer];
      [self.button removeFromSuperview];
      self.button = nil; // Clear reference
  }
}

- (void)buttonTouchedDown {
  self.button.layer.borderColor = [UIColor colorWithWhite:0.1 alpha:1.0].CGColor;
  NSLog(@"Hello");
  //targetFunction(1, 2, 3);
}

- (void)buttonTouchedUp {
  self.button.layer.borderColor = [UIColor colorWithWhite:0.45 alpha:1.0].CGColor;
}

- (void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer {
  if (self.button) {
      CGPoint translation = [panGestureRecognizer translationInView:self.button.superview];
      self.button.center = CGPointMake(self.button.center.x + translation.x, self.button.center.y + translation.y);
      [panGestureRecognizer setTranslation:CGPointZero inView:self.button.superview];
  }
}

@end

%hook ControlsWidget
- (void)setupControls {
    %orig;
    // Create the button
    [[SimpleButtonManager sharedInstance] createButton];
}
%end

%hook MenuMain
- (bool)isRootState {
  bool result = %orig;

    // Remove the button when isRootState is called
    [[SimpleButtonManager sharedInstance] removeButton];

    return result;
}
%end
// eeeee



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

int64_t (*old_function)(int64_t result, int a2, int64_t a3);
int64_t new_function(int64_t result, int a2, int64_t a3) {
    NSLog(@"[new_function_test] %lld | %d | %lld", result, a2, a3);
    return old_function(result, a2, a3); // orig
}

int64_t (*old_func2)(int64_t a1);
int64_t new_func2(int64_t a1) {
    NSLog(@"[new_func2_test] %lld", a1);
    return old_func2(a1); // orig
}


// The original objc_msgSend.
static id (*orig_objc_msgSend)(id, SEL, ...) = NULL;

id replacementObjc_msgSend(id self, SEL _sel, ...) {
    NSLog(@"[objc_msgSend Hook] [%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_sel));

    va_list args;
    va_start(args, _sel);
    id result = orig_objc_msgSend(self, _sel, args);
    va_end(args);
    return result;
}

%ctor {
    %init(NetTestHooks)

    MSHookFunction(&objc_msgSend, (id (*)(id, SEL, ...))&replacementObjc_msgSend, &orig_objc_msgSend);

    @autoreleasepool
    {
        // for some reason you can keep the "0x100000000" part
        // Test
        uintptr_t _sub_func1 = (_dyld_get_image_vmaddr_slide(0) + 0x100081848);
        NSLog(@"_sub_func1: %04x", *(uint32_t *)_sub_func1);
        MSHookFunction( (void *)_sub_func1, (void *)new_function, (void **)&old_function );
    
        uintptr_t _sub_func2 = (_dyld_get_image_vmaddr_slide(0) + 0x10026EE1C);
        NSLog(@"_sub_func2: %04x", *(uint32_t *)_sub_func2);
        MSHookFunction( (void *)_sub_func2, (void *)new_function, (void **)&old_function );

        uintptr_t call_test1 = (_dyld_get_image_vmaddr_slide(0) + 0x100194E6C);
        targetFunction = (FuncType)(call_test1);
    }
}
