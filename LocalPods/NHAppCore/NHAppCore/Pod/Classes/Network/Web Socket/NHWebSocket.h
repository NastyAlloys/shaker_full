//
//  NHWebSocket.h
//  Pods
//
//  Created by Sergey Minakov on 30.09.15.
//
//

@import Foundation;
#import "NHSRWebSocket.h"

extern NSInteger const kNHWebSocketReconnectionInterval;

@class NHWebSocket;

NS_ASSUME_NONNULL_BEGIN

@protocol NHWebSocketDelegate <NSObject>

@optional

- (void)nhWebSocket:(NHWebSocket *)socket didConnectToUrl:(NSURL *)url;
- (void)nhWebSocket:(NHWebSocket *)socket didCloseWithCode:(NSInteger)code;
- (void)nhWebSocket:(NHWebSocket *)socket connectionToUrlDidTimedOut:(NSURL *)url;
- (void)nhWebSocket:(NHWebSocket *)socket didReceiveMessage:(id)message;
- (void)nhWebSocket:(NHWebSocket *)socket didFailWithError:(NSError *)error;

@end


@interface NHWebSocket : NSObject

@property (nonatomic, weak) id<NHWebSocketDelegate> delegate;

@property (nonatomic, copy, nullable, readonly) NSString *host;
@property (nonatomic, assign, readonly) NSInteger port;
@property (nonatomic, copy, nullable, readonly) NSDictionary *parameters;
@property (nonatomic, assign, readonly) NSTimeInterval reconnectionInterval;

@property (nonatomic, strong, nullable, readonly) NHSRWebSocket *socket;

- (instancetype)init;
- (instancetype)initWithHost:(NSString *)host;

- (instancetype)host:(NSString *)host;
- (instancetype)port:(NSInteger)port;
- (instancetype)parameters:(NSDictionary *)parameters;
- (instancetype)reconnectionInterval:(NSTimeInterval)interval;

- (void)connect;
- (void)disconnect;
- (void)send:(nullable id)data;

@end

NS_ASSUME_NONNULL_END