//
//  NHWebSocket.m
//  Pods
//
//  Created by Sergey Minakov on 30.09.15.
//
//

#import "NHWebSocket.h"
#import <Reachability/Reachability.h>

NSInteger const kNHWebSocketReconnectionInterval = 5;

@interface NHWebSocket ()

@property (nonatomic, copy, nullable) NSString *host;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, copy, nullable) NSDictionary *parameters;
@property (nonatomic, assign) NSTimeInterval reconnectionInterval;

@property (nonatomic, strong, nullable) NHSRWebSocket *socket;
@property (nonatomic, strong, readonly) Reachability *reachability;

@end

@implementation NHWebSocket

- (instancetype)init {
    self = [super init];
    
    if (self) {
        
    }
        
    return self;
}

- (instancetype)initWithHost:(NSString *)host {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (instancetype)host:(NSString *)host {
    return self;
}
- (instancetype)port:(NSInteger)port {
    return self;
}
- (instancetype)parameters:(NSDictionary *)parameters {
    return self;
}
- (instancetype)reconnectionInterval:(NSTimeInterval)interval {
    return self;
}

- (void)connect {
    
}
- (void)disconnect {
    
}
- (void)send:(nullable id)data {
    
}

@end
