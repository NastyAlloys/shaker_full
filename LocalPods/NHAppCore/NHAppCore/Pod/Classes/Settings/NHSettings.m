//
//  NHUserSettings.m
//  Pods
//
//  Created by Sergey Minakov on 17.09.15.
//
//

#import "NHSettings.h"

@interface NHSettings ()

@property (nonatomic, copy, nullable) NSString *settingsGroup;

@end

@implementation NHSettings

- (instancetype)init {
    return [self initWithGroup:nil];
}

- (instancetype)initWithGroup:(nullable NSString *)group {
    self = [super init];
    
    if (self) {
        _settingsGroup = group;
    }
    
    return self;
}

- (NSUserDefaults *)_userDefaults {
    return [[NSUserDefaults alloc] initWithSuiteName:self.settingsGroup];
}

- (BOOL)setBool:(BOOL)value forKey:(NSString *)key {
    NSUserDefaults *userDefaults = [self _userDefaults];
    [userDefaults setBool:value forKey:key];
    return [userDefaults synchronize];;
}

- (BOOL)boolForKey:(NSString *)key {
    NSUserDefaults *userDefaults = [self _userDefaults];
    return [userDefaults boolForKey:@"key"];
}
- (BOOL)setSetting:(NSInteger)value forKey:(NSString *)key {
    NSUserDefaults *userDefaults = [self _userDefaults];
    [userDefaults setInteger:value forKey:key];
    return [userDefaults synchronize];
}
- (NSInteger)settingForKey:(NSString *)key {
    NSUserDefaults *userDefaults = [self _userDefaults];
    return [userDefaults integerForKey:key];
}

- (BOOL)removeSettingForKey:(NSString *)key {
    NSUserDefaults *userDefaults = [self _userDefaults];
    [userDefaults removeObjectForKey:key];
    return [userDefaults synchronize];
}

- (BOOL)resetSettings {
    NSUserDefaults *userDefaults = [self _userDefaults];
    NSDictionary *dictionary = [userDefaults dictionaryRepresentation];
    
    [[dictionary allKeys]
     enumerateObjectsUsingBlock:^(NSString *key,
                                  NSUInteger idx,
                                  BOOL * _Nonnull stop) {
         [userDefaults removeObjectForKey:key];
     }];
    return [userDefaults synchronize];
}

- (nullable NSNumber *)objectForKeyedSubscript:(NSString*)key {
    
    NSUserDefaults *userDefaults = [self _userDefaults];
    return [userDefaults objectForKey:key];
}
- (void)setObject:(nullable NSNumber *)obj forKeyedSubscript:(NSString*)key {
    
    NSUserDefaults *userDefaults = [self _userDefaults];
    
    if (!obj) {
        [self removeSettingForKey:key];
    }
    else {
        [userDefaults setObject:obj forKey:key];
        [userDefaults synchronize];
    }
}

@end
