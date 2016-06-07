//
//  AFNetworking+NHRequest.h
//  Pods
//
//  Created by Sergey Minakov on 17.10.15.
//
//

#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^NHProgressBlock)(CGFloat value);

@interface AFHTTPRequestOperationManager (NHExtension)

- (nullable AFHTTPRequestOperation *)performMethod:(NSString *)method
                                      url:(NSString *)url
                               parameters:(nullable id)parameters
                                  success:(nullable void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                  failure:(nullable void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
                             construction:(nullable void (^)(id  <AFMultipartFormData> formData))construction;

@end

@interface AFHTTPRequestOperation (NHExtension)

- (nullable AFHTTPRequestOperation *)progress:(NHProgressBlock)progress;

@end

NS_ASSUME_NONNULL_END