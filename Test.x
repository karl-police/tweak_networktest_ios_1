%hook NSURLSession

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request {
    NSLog(@"[+] Request: %@", request);
    return %orig;
}

%end
