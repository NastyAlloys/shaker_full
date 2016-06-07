//
//  NHRequest.h
//  Pods
//
//  Created by Sergey Minakov on 17.09.15.
//
//

@import Foundation;
#import "NHRequest.h"
#import "AFNetworking+NHRequest.h"

typedef id<AFMultipartFormData> NHRequestConstructor;
//@class NHRequestConstructor;
@class NHRequestPerformer;
@protocol NHRequestPerformer;

typedef NS_ENUM(NSUInteger, NHRequestMethod) {
    NHRequestMethodGET,
    NHRequestMethodPOST,
    NHRequestMethodPUT,
    NHRequestMethodDELETE,
    NHRequestMethodPATCH,
};

//(header, body)
typedef void (^NHRequestSuccessBlock)(id _Nullable response, NSInteger statusCode);
typedef void (^NHRequestFailBlock)(/*id _Nullable response, */NSInteger statusCode, NSError  * _Nullable error);
typedef void (^NHRequestConstructionBlock)(NHRequestConstructor _Nonnull constructor);

NS_ASSUME_NONNULL_BEGIN

@interface NHRequest : NSObject<NSCopying>

@property (nonatomic, assign, readonly) NHRequestMethod method;
//@property (nonatomic, copy, nullable, readonly) NSString *host;
@property (nonatomic, copy, nullable, readonly) NSString *path;
@property (nonatomic, copy, nullable, readonly) NSDictionary *parameters;
@property (nonatomic, copy, nullable, readonly) NHRequestSuccessBlock successBlock;
@property (nonatomic, copy, nullable, readonly) NHRequestFailBlock failBlock;
@property (nonatomic, copy, nullable, readonly) NHRequestConstructionBlock constructionBlock;
@property (nonatomic, assign, readonly) NSTimeInterval timeout;

+ (Class<NHRequestPerformer>)performerClass;

- (instancetype)init;
- (instancetype)initWithMethod:(NHRequestMethod)method
                          url:(NSString*)url;

- (instancetype)initWithMethod:(NHRequestMethod)method
                          url:(NSString*)url
                    parameters:(nullable NSDictionary*)parameters;

- (instancetype)initWithMethod:(NHRequestMethod)method
                          url:(NSString*)url
                    parameters:(nullable NSDictionary*)parameters
                  successBlock:(nullable NHRequestSuccessBlock)successBlock;

- (instancetype)initWithMethod:(NHRequestMethod)method
                          url:(NSString*)url
                    parameters:(nullable NSDictionary*)parameters
                  successBlock:(nullable NHRequestSuccessBlock)successBlock
                     failBlock:(nullable NHRequestFailBlock)failBlock;

- (instancetype)method:(NHRequestMethod)method;
//- (instancetype)host:(NSString *)host;
- (instancetype)path:(NSString *)path;
- (instancetype)parameters:(NSDictionary*)parameters;
- (instancetype)success:(NHRequestSuccessBlock)block;
- (instancetype)fail:(NHRequestFailBlock)block;
- (instancetype)constuct:(NHRequestConstructionBlock)block;
- (instancetype)timeout:(NSTimeInterval)timeout;

- (nullable AFHTTPRequestOperation *)send;
- (nullable AFHTTPRequestOperation *)sendWithPerformer:(nullable NHRequestPerformer *)performer;
- (nullable AFHTTPRequestOperation *)sendWithPerformer:(nullable NHRequestPerformer *)performer queueResponse:(BOOL)queue;

@end

NS_ASSUME_NONNULL_END