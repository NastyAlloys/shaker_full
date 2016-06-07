//
//  NHImageCache.h
//  Pods
//
//  Created by Sergey Minakov on 22.10.15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^NHImageCacheBlock)(UIImage * _Nullable image);

@protocol NHImageCache <NSObject>

+ (instancetype)sharedCache;

- (void)setImage:(UIImage *)image forKey:(NSString *)key;
- (void)setImage:(UIImage *)image forKey:(NSString *)key inMemory:(BOOL)inMemory;
- (void)removeImageForKey:(NSString *)key;

- (nullable UIImage *)objectForKeyedSubscript:(NSString*)key;
- (void)setObject:(nullable UIImage *)obj forKeyedSubscript:(NSString*)key;

- (void)imageForKey:(NSString *)key imageBlock:(NHImageCacheBlock)block;
- (void)imageForKey:(NSString *)key inMemory:(BOOL)inMemory imageBlock:(NHImageCacheBlock)block;

- (void)clearCache;
@end

@interface NHImageCache : NSCache<NHImageCache>

@property (nonatomic, assign) NSSearchPathDirectory cacheDirectory;

- (instancetype)init;
- (instancetype)initWithMemoryCacheSize:(NSInteger)memorySize diskPath:(NSString *)path;

- (void)clearMemoryCache;
- (void)clearDiskCache;
@end

NS_ASSUME_NONNULL_END