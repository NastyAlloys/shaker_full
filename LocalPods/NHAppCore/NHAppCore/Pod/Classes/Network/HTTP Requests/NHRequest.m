//
//  NHRequest.m
//  Pods
//
//  Created by Sergey Minakov on 17.09.15.
//
//

#import "NHRequest.h"
#import "NHRequestPerformer.h"

@interface NHRequest ()

@property (nonatomic, assign) NHRequestMethod method;
//@property (nonatomic, copy, nullable) NSString *host;
@property (nonatomic, copy, nullable) NSString *path;
@property (nonatomic, copy, nullable) NSDictionary *parameters;
@property (nonatomic, copy, nullable) NHRequestSuccessBlock successBlock;
@property (nonatomic, copy, nullable) NHRequestFailBlock failBlock;
@property (nonatomic, copy, nullable) NHRequestConstructionBlock constructionBlock;
@property (nonatomic, assign) NSTimeInterval timeout;

@end

@implementation NHRequest

- (id)copyWithZone:(NSZone *)zone {
    NHRequest *request = [[[self class] alloc] init];
    request.method = self.method;
//    request.host = [self.host copy];
    request.path = [self.path copy];
    request.parameters = [self.parameters copy];
    request.successBlock = [self.successBlock copy];
    request.failBlock = [self.failBlock copy];
    request.constructionBlock = [self.constructionBlock copy];
    request.timeout = self.timeout;
    return request;
}

+ (Class<NHRequestPerformer>)performerClass {
    return [NHRequestPerformer class];
}

- (instancetype)init {
    self = [super init];
    
    return self;
}

- (instancetype)initWithMethod:(NHRequestMethod)method
                           url:(NSString*)url {
    return [self initWithMethod:method
                            url:url
                     parameters:nil];
}

- (instancetype)initWithMethod:(NHRequestMethod)method
                           url:(NSString*)url
                    parameters:(nullable NSDictionary*)parameters {
    return [self initWithMethod:method
                            url:url
                     parameters:parameters
                   successBlock:nil];
}

- (instancetype)initWithMethod:(NHRequestMethod)method
                           url:(NSString*)url
                    parameters:(nullable NSDictionary*)parameters
                  successBlock:(nullable NHRequestSuccessBlock)successBlock {
    return [self initWithMethod:method
                            url:url
                     parameters:parameters
                   successBlock:successBlock
                      failBlock:nil];
}

- (instancetype)initWithMethod:(NHRequestMethod)method
                           url:(NSString*)url
                    parameters:(nullable NSDictionary*)parameters
                  successBlock:(nullable NHRequestSuccessBlock)successBlock
                     failBlock:(nullable NHRequestFailBlock)failBlock {
    self = [super init];
    
    if (self) {
        _method = method;
        _path = url;
        _parameters = parameters;
        _successBlock = successBlock;
        _failBlock = failBlock;
    }
    
    return self;
}

- (instancetype)method:(NHRequestMethod)method {
    self.method = method;
    return self;
}
//- (instancetype)host:(NSString *)host {
//    self.host = host;
//    return self;
//}
- (instancetype)path:(NSString *)path {
    self.path = path;
    return self;
}
- (instancetype)parameters:(NSDictionary*)parameters {
    self.parameters = parameters;
    return self;
}
- (instancetype)success:(NHRequestSuccessBlock)block {
    self.successBlock = block;
    return self;
}
- (instancetype)fail:(NHRequestFailBlock)block {
    self.failBlock = block;
    return self;
}
- (instancetype)constuct:(NHRequestConstructionBlock)block {
    self.constructionBlock = block;
    return self;
}

- (instancetype)timeout:(NSTimeInterval)timeout {
    self.timeout = timeout;
    return self;
}

- (nullable AFHTTPRequestOperation *)send {
    return [self sendWithPerformer:nil];
}
- (nullable AFHTTPRequestOperation *)sendWithPerformer:(nullable NHRequestPerformer *)performer {
    return [self sendWithPerformer:performer queueResponse:NO];
}
- (nullable AFHTTPRequestOperation *)sendWithPerformer:(nullable NHRequestPerformer *)performer queueResponse:(BOOL)queue {
    return [(performer ?: [[[self class] performerClass] sharedPerformer]) sendRequest:self queueResponse:queue];
}

@end
