//
//  NHUserSettings.h
//  Pods
//
//  Created by Sergey Minakov on 17.09.15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface NHSettings : NSObject

@property (nonatomic, copy, readonly, nullable) NSString *settingsGroup;

- (instancetype)init;
- (instancetype)initWithGroup:(nullable NSString *)group;

- (BOOL)setBool:(BOOL)value forKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;

- (BOOL)setSetting:(NSInteger)value forKey:(NSString *)key;
- (NSInteger)settingForKey:(NSString *)key;

- (BOOL)removeSettingForKey:(NSString *)key;
- (BOOL)resetSettings;

- (nullable NSNumber *)objectForKeyedSubscript:(NSString*)key;
- (void)setObject:(nullable NSNumber *)obj forKeyedSubscript:(NSString*)key;

@end
NS_ASSUME_NONNULL_END
