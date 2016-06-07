//
//  NHRequestPerformer.h
//  Pods
//
//  Created by Sergey Minakov on 21.09.15.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "NHRequest.h"

typedef void(^NHRequestPerformerSuccessBlock)(AFHTTPRequestOperation * _Null_unspecified operation,
                                              id _Nullable response,
                                              NSInteger statusCode);
typedef void(^NHRequestPerformerFailBlock)(AFHTTPRequestOperation * _Null_unspecified operation,
                                           NSInteger statusCode,
                                           NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@protocol NHRequestPerformer <NSObject>

+ (AFHTTPRequestOperationManager *)manager;
+ (instancetype)sharedPerformer;
- (nullable AFHTTPRequestOperation *)sendRequest:(NHRequest*)request queueResponse:(BOOL)queueResponse;

@end

@interface NHRequestPerformer : NSObject<NHRequestPerformer>

@property (nonatomic, strong, nonnull, readonly) NSOperationQueue *queue;
@property (nonatomic, strong, nonnull, readonly) AFHTTPRequestOperationManager *manager;

- (instancetype)init;
- (instancetype)initWithName:(nullable NSString *)name;

+ (nullable AFHTTPRequestOperation *)performRequestWithManager:(nonnull AFHTTPRequestOperationManager *)manager
                                                        method:(NHRequestMethod)method
                                                          path:(nullable NSString *)path
                                                    parameters:(nullable NSDictionary *)parameters
                                                  successBlock:(nonnull NHRequestPerformerSuccessBlock)successBlock
                                                     failBlock:(nonnull NHRequestPerformerFailBlock)failBlock
                                             constructionBlock:(nullable NHRequestConstructionBlock)constructionBlock;
@end

NS_ASSUME_NONNULL_END