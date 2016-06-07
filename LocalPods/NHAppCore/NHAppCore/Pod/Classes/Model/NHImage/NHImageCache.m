//
//  NHImageCache.m
//  Pods
//
//  Created by Sergey Minakov on 22.10.15.
//
//

#import "NHImageCache.h"
#import "NHAppCoreHelper.h"

static const NSInteger kNHImageCacheSize = 30 * 1024 * 1024;

@interface NHImageCache ()

@property (nonatomic, copy) NSString *diskFolderPath;

@end

@implementation NHImageCache

+ (instancetype)sharedCache {
    static dispatch_once_t token;
    __strong static id instance = nil;
    dispatch_once(&token, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    return [self initWithMemoryCacheSize:kNHImageCacheSize diskPath:@"image.cache"];
}

- (instancetype)initWithMemoryCacheSize:(NSInteger)memorySize diskPath:(NSString *)path {
    self = [super init];
    
    if (self) {
        self.totalCostLimit = memorySize;
        _cacheDirectory = NSDocumentDirectory;
        _diskFolderPath = path;
    }
    
    return self;
}

- (void)imageForKey:(NSString *)key imageBlock:(NHImageCacheBlock)block {
    [self imageForKey:key inMemory:NO imageBlock:block];
}


- (void)imageForKey:(NSString *)key inMemory:(BOOL)inMemory imageBlock:(NHImageCacheBlock)block {
    UIImage *memoryCachedImage = [self objectForKey:key];
    
    if (memoryCachedImage) {
        if (block) {
            block(memoryCachedImage);
        }
    }
    else if (!inMemory && pathExistsForDirectory(self.cacheDirectory, [NSString stringWithFormat:@"%@/%@", self.diskFolderPath, key])) {
        queue_async(DISPATCH_QUEUE_PRIORITY_DEFAULT, ^{
            UIImage *image = [self diskImageForKey:key];
            [self addImageToMemory:image forKey:key];
            
            if (block) {
                block(image);
            }
        });
    }
    else {
        if (block) {
            block(nil);
        }
    }
}

- (nullable UIImage *)diskImageForKey:(NSString *)key {
    NSString *filePath = pathForDirectory(self.cacheDirectory, [NSString stringWithFormat:@"%@/%@", self.diskFolderPath, key]);
    
    NSData *imgData = [[NSData alloc] initWithContentsOfFile:filePath];
    return [[UIImage alloc] initWithData:imgData scale:[UIScreen mainScreen].scale];
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
    [self setImage:image forKey:key inMemory:NO];
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key inMemory:(BOOL)inMemory {
    queue_async(DISPATCH_QUEUE_PRIORITY_DEFAULT, ^(void){
        if (inMemory != true) {
            [self addImageToDisk:image forKey:key];
        }
        [self addImageToMemory:image forKey:key];
    });
}

- (void)removeImageForKey:(NSString *)key {
    [self removeImageFromMemoryForKey:key];
    [self removeImageFromDiskForKey:key];
}

- (void)addImageToMemory:(UIImage *)image forKey:(NSString *)key {
    if (image) {
        NSInteger imageCost = image.size.height * image.size.width;
        [self setObject:image forKey:key cost:imageCost];
    }
}

- (void)addImageToDisk:(UIImage *)image forKey:(NSString *)key {
    if (image) {
        NSString *filePath = createFileInDirectoryFolder(self.cacheDirectory, self.diskFolderPath, key);
        [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    }
}

- (void)removeImageFromMemoryForKey:(NSString *)key {
    [self removeObjectForKey:key];
}

- (void)removeImageFromDiskForKey:(NSString *)key {
    removeAtPathForDirectory(self.cacheDirectory, [NSString stringWithFormat:@"%@/%@", self.diskFolderPath, key]);
}

- (nullable UIImage *)objectForKeyedSubscript:(NSString*)key {
    return [self objectForKey:key];
}

- (void)clearCache {
    [self clearMemoryCache];
    [self clearDiskCache];
}

- (void)clearMemoryCache {
    [self removeAllObjects];
}
- (void)clearDiskCache {
    removeAtPathForDirectory(self.cacheDirectory, self.diskFolderPath);
}

- (void)setObject:(nullable UIImage *)obj forKeyedSubscript:(NSString*)key {
    if (obj) {
        [self setImage:obj forKey:key];
    }
    else {
        [self removeImageForKey:key];
    }
}

@end