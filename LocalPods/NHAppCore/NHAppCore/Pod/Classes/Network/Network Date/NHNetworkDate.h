//
//  NHServerDate.h
//  Pods
//
//  Created by Sergey Minakov on 19.09.15.
//
//  Based on: https://github.com/freak4pc/NSDate-ServerDate

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NHNetworkDate;

typedef void(^NHNetworkDateBlock)(NHNetworkDate * _Nullable networkDate, NSError * _Nullable error);

@interface NHNetworkDate : NSObject

@property (nonatomic, assign, readonly) BOOL isSynchronized;

+ (instancetype)sharedInstance;

- (instancetype)init;
- (instancetype)initWithUrl:(NSString*)serverUrl
                 timeFormat:(NSString*)timeFormat
           reachabilityHost:(NSString*)reachabilityHost NS_DESIGNATED_INITIALIZER;

- (void)synchronize;
- (void)synchronize:(BOOL)async;
- (void)synchronize:(BOOL)async block:(nullable NHNetworkDateBlock)block;
- (void)reset;
- (NSDate *)date;

@end

NS_ASSUME_NONNULL_END
