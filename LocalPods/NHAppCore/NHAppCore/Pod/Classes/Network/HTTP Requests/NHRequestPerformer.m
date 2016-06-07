//
//  NHRequestPerformer.m
//  Pods
//
//  Created by Sergey Minakov on 21.09.15.
//
//

#import "NHRequestPerformer.h"
#import "NHRequest.h"
#import "NHAppCoreHelper.h"

@interface NHRequestPerformer ()

@property (nonatomic, strong, nonnull) NSOperationQueue *queue;
@property (nonatomic, strong, nonnull) AFHTTPRequestOperationManager *manager;

@end

@implementation NHRequestPerformer

+ (instancetype)sharedPerformer
{
    static dispatch_once_t token;
    __strong static NHRequestPerformer *instance = nil;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

+ (AFHTTPRequestOperationManager *)manager {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    return manager;
}

- (instancetype)init {
    return [self initWithName:nil];
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
        _queue.name = name;
        
        _manager = [[self class] manager];
    }
    return self;
}

- (AFHTTPRequestOperation *)sendRequest:(NHRequest *)request
                          queueResponse:(BOOL)queueResponse {
    
    __weak typeof(self) weakSelf = self;
    NHRequestPerformerSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation,
                                                    id response,
                                                    NSInteger statusCode){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (queueResponse
            && request.successBlock) {
            NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
                request.successBlock(response, statusCode);
            }];
            blockOperation.queuePriority = operation ? operation.queuePriority : NSOperationQueuePriorityNormal;
            
            [strongSelf.queue addOperation:blockOperation];
        }
        else if (request.successBlock) {
            queue_async(DISPATCH_QUEUE_PRIORITY_DEFAULT, ^{
                request.successBlock(response, statusCode);
            });
        }
    };
    
    NHRequestPerformerFailBlock failBlock = ^(AFHTTPRequestOperation *operation,
                                              NSInteger statusCode,
                                              NSError *error){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (queueResponse
            && request.failBlock) {
            NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
                request.failBlock(statusCode, error);
            }];
            blockOperation.queuePriority = operation ? operation.queuePriority : NSOperationQueuePriorityNormal;
            
            [strongSelf.queue addOperation:blockOperation];
        }
        else if (request.failBlock) {
            queue_async(DISPATCH_QUEUE_PRIORITY_DEFAULT, ^{
                request.failBlock(statusCode, error);
            });
        }
    };
    
    NSString *url;
    if ([request.path length]) {
        url = [request.path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    else {
        failBlock(nil, -1, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil]);
        return nil;
    }
    
    [self.manager.requestSerializer setTimeoutInterval:(request.timeout > 0 ? request.timeout : 60)];
    
    return [[self class] performRequestWithManager:self.manager
                                            method:request.method
                                              path:url
                                        parameters:request.parameters
                                      successBlock:successBlock
                                         failBlock:failBlock
                                 constructionBlock:request.constructionBlock];
}

+ (nullable AFHTTPRequestOperation *)performRequestWithManager:(nonnull AFHTTPRequestOperationManager *)manager
                                                        method:(NHRequestMethod)method
                                                          path:(nullable NSString *)path
                                                    parameters:(nullable NSDictionary *)parameters
                                                  successBlock:(nonnull NHRequestPerformerSuccessBlock)successBlock
                                                     failBlock:(nonnull NHRequestPerformerFailBlock)failBlock
                                             constructionBlock:(nullable NHRequestConstructionBlock)constructionBlock {
    
    NSString *methodString;
    switch (method) {
        case NHRequestMethodGET:
            methodString = @"GET";
            break;
        case NHRequestMethodPOST:
            methodString = @"POST";
            break;
        case NHRequestMethodDELETE:
            methodString = @"DELETE";
            break;
        case NHRequestMethodPUT:
            methodString = @"PUT";
            break;
        case NHRequestMethodPATCH:
            methodString = @"PATCH";
            break;
        default:
            break;
    }
    
    if (!methodString) {
        return nil;
    }
    
    return [manager performMethod:methodString
                              url:path
                       parameters:parameters
                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                              successBlock(operation, responseObject, operation.response.statusCode);
                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              failBlock(operation, operation.response.statusCode, error);
                          } construction:constructionBlock];
}
@end

