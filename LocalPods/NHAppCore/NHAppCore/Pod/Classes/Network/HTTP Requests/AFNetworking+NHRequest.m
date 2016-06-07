//
//  AFNetworking+NHRequest.m
//  Pods
//
//  Created by Sergey Minakov on 17.10.15.
//
//

#import "AFNetworking+NHRequest.h"

@implementation AFHTTPRequestOperationManager (NHExtension)

- (AFHTTPRequestOperation *)performMethod:(NSString *)method
                                      url:(NSString *)url
                               parameters:(id)parameters
                                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
                             construction:(void (^)(id  <AFMultipartFormData> formData))construction; {
    
    NSMutableURLRequest *request;
    NSError *serializationError = nil;
    if (construction) {
        request = [self.requestSerializer multipartFormRequestWithMethod:method
                                                               URLString:[[NSURL URLWithString:url relativeToURL:self.baseURL] absoluteString]
                                                              parameters:parameters
                                               constructingBodyWithBlock:construction
                                                                   error:&serializationError];
    }
    else {
        request = [self.requestSerializer requestWithMethod:method
                                                  URLString:[[NSURL URLWithString:url relativeToURL:self.baseURL] absoluteString]
                                                 parameters:parameters
                                                      error:&serializationError];
    }
    
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    
    [self.operationQueue addOperation:operation];
    
    return operation;
}

@end

@implementation AFHTTPRequestOperation (NHExtension)

- (nullable AFHTTPRequestOperation *)progress:(NHProgressBlock)progress {
    [self setDownloadProgressBlock:^(NSUInteger bytesRead,
                                     long long totalBytesRead,
                                     long long totalBytesExpectedToRead) {
        double value = (totalBytesExpectedToRead)
        ? (double)totalBytesRead / (double)totalBytesExpectedToRead
        : 0;
        
        if (progress) {
            progress(value);
        }
    }];
    return self;
}

@end