//
//  NHImageObject.m
//  Pods
//
//  Created by Sergey Minakov on 18.09.15.
//
//

#import "NHImageObject.h"
#import "NHAppCoreHelper.h"
#import "NHImageCache.h"

static const BOOL kNHImageSyncWithMainThread = YES;

@interface NHImageObjectStorageItem : NSObject

@property (nonatomic, strong) AFHTTPRequestOperation *operation;
@property (nonatomic, copy) NHImageBlock block;

@end

@implementation NHImageObjectStorageItem

- (instancetype)initWithOperation:(AFHTTPRequestOperation *)operation block:(NHImageBlock)block {
    self = [super init];
    
    if (self) {
        _operation = operation;
        _block = block;
    }
    
    return self;
}

@end

@interface NHImageObject ()

@property (nonatomic, copy, nullable) NSString *url;

@end

@implementation NHImageObject

+ (id<NHImageCache>)cache {
    return [[NHImageCache class] sharedCache];
}

+ (NSMutableDictionary<NSString *, NHImageObjectStorageItem *>*)storedOperations {
    static dispatch_once_t token;
    __strong static NSMutableDictionary<NSString *, NHImageObjectStorageItem *>* instance = nil;
    dispatch_once(&token, ^{
        instance = [[NSMutableDictionary<NSString *, NHImageObjectStorageItem *> alloc] init];
    });
    
    return instance;
}

+ (void)setStorageItem:(NHImageObjectStorageItem*)object forKey:(NSString *)key {
    if (!object) {
        [[self storedOperations] removeObjectForKey:key];
    }
    else {
        [self storedOperations][key] = object;
    }
}

+ (instancetype)convertFromObject:(id)object {
    return [[self alloc] initWithObject:object];
}

- (instancetype)initWithObject:(id)object {
    self = [super init];
    
    if (self) {
        if ([object isKindOfClass:[NSString class]]) {
            _url = object;
        }
        else if ([object isKindOfClass:[NSURL class]]) {
            _url = [object absoluteString];
        }
        else if ([object isKindOfClass:[NSDictionary class]]) {
            _url = object[@"url"];
        }
    }
    return self;
}

+ (nullable NSString *)storageKeyForURL:(NSString *)url {
    if (url) {
        return [[url stringByReplacingOccurrencesOfString:@"/" withString:@""] stringByReplacingOccurrencesOfString:@":" withString:@""];
    }
    
    return nil;
}

+ (nullable NSString *)storageKeyForURL:(NSString *)url size:(CGSize)size resizeMode:(NHImageObjectResizeMode)resizeMode {
    NSString *storageKey = [self storageKeyForURL:url];
    
    if (size.height
        && size.width
        && storageKey) {
        return [NSString stringWithFormat:@"%@-%@x%@-%@", storageKey, @(size.width), @(size.height), @(resizeMode)];
    }
    
    return storageKey;
}

- (nullable AFHTTPRequestOperation *)loadWithBlock:(NHImageBlock)block {
    return [self loadWithSize:CGSizeZero block:block];
}

- (nullable AFHTTPRequestOperation *)loadWithSize:(CGSize)size block:(NHImageBlock)block {
    return [[self class] loadWithURL:self.url size:size resizeMode:self.resizeMode block:block];
}

+ (nullable AFHTTPRequestOperation *)loadWithURL:(NSString*)url
                                           block:(NHImageBlock)block {
    return [self loadWithURL:url
                        size:CGSizeZero
                  resizeMode:NHImageObjectResizeModeScale
                       block:block];
}

+ (nullable AFHTTPRequestOperation *)loadWithURL:(NSString*)url
                                            size:(CGSize)size
                                      resizeMode:(NHImageObjectResizeMode)resizeMode
                                           block:(NHImageBlock)block {
    return [self loadWithURL:url size:size resizeMode:resizeMode inMemory:NO block:block];
}

+ (nullable AFHTTPRequestOperation *)loadWithURL:(NSString*)url
                                            size:(CGSize)size
                                      resizeMode:(NHImageObjectResizeMode)resizeMode
                                        inMemory:(BOOL)inMemory
                                           block:(NHImageBlock)block {
    
    if (!url) {
        if (block) {
            main_async(^{
                block(NO, nil);
            }, kNHImageSyncWithMainThread);
        }
        return nil;
    }
    
    __block AFHTTPRequestOperation *operation;
    
    NSString *storageKey = [self storageKeyForURL:url];
    NSString *resizedStorageKey;
    if (resizeMode != NHImageObjectResizeModeNone) {
        resizedStorageKey = [self storageKeyForURL:url
                                              size:size
                                        resizeMode:resizeMode];
    }
    
    [[self cache] imageForKey:storageKey
                     inMemory:inMemory
                   imageBlock:^(UIImage * _Nullable image) {
                       @autoreleasepool {
                           if (!image) {
                               operation = [self downloadImageWithURL:url size:size resizeMode:resizeMode inMemory:inMemory block:block];
                           }
                           else if (size.height && size.width && resizeMode != NHImageObjectResizeModeNone) {
                               [[self cache] imageForKey:resizedStorageKey
                                                inMemory:inMemory
                                              imageBlock:^(UIImage * _Nullable resizedImage) {
                                                 if (resizedImage) {
                                                     main_async(^{
                                                         block(YES, resizedImage);
                                                     }, kNHImageSyncWithMainThread);
                                                 }
                                                 else {
                                                     [self performImageResize:image
                                                                         size:size
                                                                         mode:resizeMode
                                                                     cacheKey:resizedStorageKey
                                                                     inMemory:inMemory
                                                                        block:block];
                                                 }
                                             }];
                           }
                           else {
                               if (block) {
                                   main_async(^{
                                       block(NO, image);
                                   }, kNHImageSyncWithMainThread);
                               }
                           }
                       }
                   }];
    
    return operation;
}

+ (AFHTTPRequestOperation *)downloadImageWithURL:(NSString *)url
                                            size:(CGSize)size
                                      resizeMode:(NHImageObjectResizeMode)resizeMode
                                        inMemory:(BOOL)inMemory
                                           block:(NHImageBlock)block {
    NSString *storageKey = [self storageKeyForURL:url];
    
    NHImageObjectStorageItem *storageItem = [self storedOperations][storageKey];
    AFHTTPRequestOperation *operation;
    NHImageBlock storageBlock;
    
    if (!storageItem
        || storageItem.operation.isFinished
        || storageItem.operation.isCancelled) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFImageResponseSerializer serializer];
        
        storageBlock = [self imageBlockForURL:url size:size resizeMode:resizeMode inMemory:inMemory block:block];
        
        operation = [manager GET:url
                      parameters:nil
                         success:nil failure:nil];
    }
    else {
        operation = storageItem.operation;
        NHImageBlock currentBlock = storageItem.block;
        NHImageBlock newBlock = [self imageBlockForURL:url size:size resizeMode:resizeMode inMemory:inMemory block:block];
        
        storageBlock = ^(BOOL cached, UIImage *image) {
            if (currentBlock) {
                currentBlock(NO, image);
            }
            
            if (newBlock) {
                newBlock(NO, image);
            }
        };
    }
    
    if (operation) {
        NSString *storageKey = [self storageKeyForURL:url];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            main_async(^{
                storageBlock(NO, responseObject);
            }, kNHImageSyncWithMainThread);
            
            [self setStorageItem:nil forKey:storageKey];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            main_async(^{
                storageBlock(NO, nil);
            }, kNHImageSyncWithMainThread);
            [self setStorageItem:nil forKey:storageKey];
        }];
        
        [[self class] setStorageItem:[[NHImageObjectStorageItem alloc] initWithOperation:operation block:storageBlock] forKey:storageKey];
    }
    
    return operation;
}


+ (void)performImageResize:(UIImage*)image
                      size:(CGSize)size
                      mode:(NHImageObjectResizeMode)mode
                  cacheKey:(nonnull NSString*)cacheKey
                  inMemory:(BOOL)inMemory
                     block:(NHImageBlock)block {
    queue_async(DISPATCH_QUEUE_PRIORITY_DEFAULT, ^{
        @autoreleasepool {
            UIImage *resizedImage;
            
            switch (mode) {
                case NHImageObjectResizeModeFit:
                    resizedImage = [image resizedToFitSize:size];
                    break;
                case NHImageObjectResizeModeFill:
                    resizedImage = [image resizedToFillSize:size];
                    break;
                default:
                    resizedImage = [image resizedToSize:size];
                    break;
            }
            
            [[self cache] setImage:resizedImage forKey:cacheKey inMemory:inMemory];
            
            if (block) {
                main_async(^{
                    block(NO, resizedImage);
                }, kNHImageSyncWithMainThread);
            }
            
        }
        
    });
}

+ (nonnull NHImageBlock)imageBlockForURL:(NSString *)url size:(CGSize)size resizeMode:(NHImageObjectResizeMode)resizeMode inMemory:(BOOL)inMemory block:(NHImageBlock)block {
    
    NSString *storageKey = [self storageKeyForURL:url];
    
    if (size.height && size.width) {
        NSString *cacheKey = [self storageKeyForURL:url size:size resizeMode:resizeMode];
        
        return ^(BOOL cached, UIImage *image){
            [[self cache] setImage:image forKey:storageKey inMemory:inMemory];
            
            if (image && block) {
                if (resizeMode == NHImageObjectResizeModeNone) {    
                    block(NO, image);
                } else {
                    [self performImageResize:image
                                        size:size
                                        mode:resizeMode
                                    cacheKey:cacheKey
                                    inMemory:inMemory
                                       block:block];
                }
            }
            else if (block) {
                block(NO, nil);
            }
        };
    }
    
    return ^(BOOL cached, UIImage *image){
        [[self cache] setImage:image forKey:storageKey inMemory:inMemory];
        
        if (block) {
            block(NO, image);
        }
    };
}

@end
