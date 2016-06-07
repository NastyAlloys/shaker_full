//
//  NHSocket.h
//  Pods
//
//  Created by Sergey Minakov on 23.09.15.
//
//  Based on: https://github.com/square/SocketRocket
//  TODO:

#import <Foundation/Foundation.h>
#import <Security/SecCertificate.h>

typedef NS_ENUM(NSInteger, NHSRWebSocketReadyState) {
    NHSRWebSocketReadyStateConnecting = 0,
    NHSRWebSocketReadyStateOpen = 1,
    NHSRWebSocketReadyStateClosing = 2,
    NHSRWebSocketReadyStateClosed = 3,
};

typedef enum NHSRStatusCode : NSInteger {
    NHSRStatusCodeNormal = 1000,
    NHSRStatusCodeGoingAway = 1001,
    NHSRStatusCodeProtocolError = 1002,
    NHSRStatusCodeUnhandledType = 1003,
    // 1004 reserved.
    NHSRStatusNoStatusReceived = 1005,
    // 1004-1006 reserved.
    NHSRStatusCodeInvalidUTF8 = 1007,
    NHSRStatusCodePolicyViolated = 1008,
    NHSRStatusCodeMessageTooBig = 1009,
} NHSRStatusCode;

@class NHSRWebSocket;

extern NSTimeInterval const kNHSRDefaultTimeout;
extern NSInteger const kNHSRErrorHeartbeatTimedOut;
extern NSString *const kNHSRWebSocketErrorDomain;
extern NSString *const kNHSRHTTPResponseErrorKey;

#pragma mark - SRWebSocketDelegate

@protocol NHSRWebSocketDelegate;

#pragma mark - SRWebSocket

@interface NHSRWebSocket : NSObject <NSStreamDelegate>

@property (nonatomic, assign) BOOL selfSignedCertificates;
@property (nonatomic, assign) NSTimeInterval heartbeatInterval;

@property (nonatomic, weak) id <NHSRWebSocketDelegate> delegate;

@property (nonatomic, readonly) NHSRWebSocketReadyState readyState;
@property (nonatomic, readonly, retain) NSURL *url;

@property (nonatomic, readonly) CFHTTPMessageRef receivedHTTPHeaders;

// Optional array of cookies (NSHTTPCookie objects) to apply to the connections
@property (nonatomic, readwrite) NSArray * requestCookies;

// This returns the negotiated protocol.
// It will be nil until after the handshake completes.
@property (nonatomic, readonly, copy) NSString *protocol;

// Protocols should be an array of strings that turn into Sec-WebSocket-Protocol.
- (id)initWithURLRequest:(NSMutableURLRequest *)request protocols:(NSArray *)protocols;
- (id)initWithURLRequest:(NSMutableURLRequest *)request;

// Some helper constructors.
- (id)initWithURL:(NSURL *)url protocols:(NSArray *)protocols timeout:(NSTimeInterval)timeout;
- (id)initWithURL:(NSURL *)url protocols:(NSArray *)protocols;

- (id)initWithURL:(NSURL *)url timeout:(NSTimeInterval)timeout;
- (id)initWithURL:(NSURL *)url;

// Delegate queue will be dispatch_main_queue by default.
// You cannot set both OperationQueue and dispatch_queue.
- (void)setDelegateOperationQueue:(NSOperationQueue*) queue;
- (void)setDelegateDispatchQueue:(dispatch_queue_t) queue;

// By default, it will schedule itself on +[NSRunLoop SR_networkRunLoop] using defaultModes.
- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;
- (void)unscheduleFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode;

// SRWebSockets are intended for one-time-use only.  Open should be called once and only once.
- (void)open;

- (void)close;
- (void)closeWithCode:(NSInteger)code reason:(NSString *)reason;

// Send a UTF8 String or Data.
- (void)send:(id)data;

// Send Data (can be nil) in a ping message.
- (void)sendPing:(NSData *)data;

@end

#pragma mark - SRWebSocketDelegate

@protocol NHSRWebSocketDelegate <NSObject>

// message will either be an NSString if the server is using text
// or NSData if the server is using binary.
- (void)webSocket:(NHSRWebSocket *)webSocket didReceiveMessage:(id)message;

@optional

- (void)webSocketDidOpen:(NHSRWebSocket *)webSocket;
- (void)webSocket:(NHSRWebSocket *)webSocket didFailWithError:(NSError *)error;
- (void)webSocket:(NHSRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
- (void)webSocket:(NHSRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;

@end

#pragma mark - NSURLRequest (CertificateAdditions)

@interface NSURLRequest (NHAppCore_CertificateAdditions)

@property (nonatomic, retain, readonly) NSArray *NHSocket_SLLSertificates;

@end

#pragma mark - NSMutableURLRequest (CertificateAdditions)

@interface NSMutableURLRequest (NHAppCore_CertificateAdditions)

@property (nonatomic, retain) NSArray *NHSocket_SLLSertificates;

@end

#pragma mark - NSRunLoop (SRWebSocket)

@interface NSRunLoop (NHAppCore_SRWebSocket)

+ (NSRunLoop *)NHSocketRunLoop;

@end
