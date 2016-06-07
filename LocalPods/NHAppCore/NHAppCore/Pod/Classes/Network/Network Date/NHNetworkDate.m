//
//  NHServerDate.m
//  Pods
//
//  Created by Sergey Minakov on 19.09.15.
//
//  Based on: https://github.com/freak4pc/NSDate-ServerDate

#import "NHNetworkDate.h"
#import <Reachability/Reachability.h>

static NSString * const kNHNetworkTimeServer = @"https://google.com";
static NSString * const kNHNetworkTimeFormat = @"EEE, dd MMM yyyy HH:mm:ss z";
static NSString * const kNHNetworkTimeReachabilityHost = @"www.google.com";

@interface NHNetworkDate ()

@property (nonatomic, copy) NSString *timeServer;
@property (nonatomic, copy) NSString *timeFormat;

@property (nonatomic, assign) BOOL isSynchronized;

@property (nonatomic, strong) Reachability *serverReachability;
@property (nonatomic, assign) NSTimeInterval networkTimeOffset;

@property (nonatomic, strong) id enterForeground;

@end

@implementation NHNetworkDate

+ (instancetype)sharedInstance
{
    static dispatch_once_t token;
    __strong static NHNetworkDate *instance = nil;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    return [self initWithUrl:kNHNetworkTimeServer
                  timeFormat:kNHNetworkTimeFormat
            reachabilityHost:kNHNetworkTimeReachabilityHost];
}

- (instancetype)initWithUrl:(NSString*)serverUrl
                 timeFormat:(NSString*)timeFormat
           reachabilityHost:(NSString*)reachabilityHost {
    self = [super init];
    
    if (self) {
        _timeServer = serverUrl;
        _timeFormat = timeFormat;
        
        _serverReachability = [Reachability reachabilityWithHostName:reachabilityHost];
        
        
        __weak typeof(self) weakSelf = self;
        _serverReachability.reachableBlock = ^(Reachability *reachability){
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf synchronize:YES];
            [reachability stopNotifier];
        };
        _enterForeground = [[NSNotificationCenter defaultCenter]
                            addObserverForName:UIApplicationWillEnterForegroundNotification
                            object:nil
                            queue:nil
                            usingBlock:^(NSNotification * _Nonnull note) {
                                __strong __typeof(weakSelf) strongSelf = weakSelf;
                                [strongSelf synchronize:YES];
                            }];
    }
    
    return self;
}

- (void)synchronize {
    [self synchronize:NO];
}

- (void)synchronize:(BOOL)async {
    [self synchronize:async block:nil];
}

- (void)synchronize:(BOOL)async block:(nullable NHNetworkDateBlock)block {
    if ([self.serverReachability isReachable]) {
        __weak __typeof(self) weakSelf = self;
        
        void(^responseBlock)(NSHTTPURLResponse *response,
                             NSError *error) = ^(NSHTTPURLResponse *response,
                                                 NSError *error){
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (!error) {
                NSString *responseDate = [response allHeaderFields][@"Date"];
                
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                dateFormat.dateFormat = self.timeFormat;
                dateFormat.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
                
                NSDate *serverDate = [dateFormat dateFromString:responseDate];
                strongSelf.networkTimeOffset = [serverDate timeIntervalSinceNow];
                strongSelf.isSynchronized = YES;
                
                if (block) {
                    block(strongSelf, error);
                }
            }
            else {
                [strongSelf restartReachability];
                
                if (block) {
                    block(strongSelf, error);
                }
            }
        };
        
        NSHTTPURLResponse *response;
        NSError *error;
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.timeServer]];
        request.HTTPMethod = @"HEAD";
        request.timeoutInterval = 10;
        
        if (async) {
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue new]
                                   completionHandler:^(NSURLResponse * _Nullable response,
                                                       NSData * _Nullable data,
                                                       NSError * _Nullable error) {
                                       responseBlock((NSHTTPURLResponse*)response, error);
                                   }];   
        }
        else {
            [NSURLConnection sendSynchronousRequest:request
                                  returningResponse:&response
                                              error:&error];
            responseBlock(response, error);
        }
    }
    else {
        [self restartReachability];
    }
}

- (void)reset {
    [self.serverReachability stopNotifier];
    self.networkTimeOffset = 0;
    self.isSynchronized = NO;
}

- (void)restartReachability {
    [self.serverReachability stopNotifier];
    [self.serverReachability startNotifier];
}

- (NSDate *)date {
    return [[NSDate date] dateByAddingTimeInterval:self.networkTimeOffset];
}

- (void)dealloc {
    [self.serverReachability stopNotifier];
    self.serverReachability = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self.enterForeground];
}

@end

