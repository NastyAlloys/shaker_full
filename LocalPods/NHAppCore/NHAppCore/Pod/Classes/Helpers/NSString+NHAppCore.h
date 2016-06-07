//
//  NSString+NHAppCore.h
//  Pods
//
//  Created by Sergey Minakov on 01.10.15.
//
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kNHDefaultPluralizeStringSeprator;

@interface NSString (NHExtension)

+ (nullable id)jsonObjectWithJson:(nullable NSString*)jsonString;
- (nullable id)jsonObject;

+ (nullable NSString *)pluralizeString:(nullable NSString *)string number:(double)number separator:(NSString *)separator;
+ (nullable NSString *)pluralizeString:(nullable NSString *)string number:(double)number;
- (nullable NSString *)pluralize:(double)number separator:(NSString *)separator;
- (nullable NSString *)pluralize:(double)number;


+ (NSString *)stringWithFormat:(NSString *)format array:(NSArray *)arguments;

@end

//
//@interface NSString (NH_MD5)
//
//- (NSString*)md5;
//
//@implementation NSString (ShakerMD5)
//
//- (NSString *)MD5 {
//    const char* stringPointer = [self UTF8String];
//    
//    unsigned char digest[CC_MD5_DIGEST_LENGTH];
//    
//    CC_MD5(stringPointer, (unsigned int)strlen(stringPointer), digest);
//    
//    NSMutableString *encriptedString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
//    
//    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
//        [encriptedString appendFormat:@"%02x",digest[i]];
//    
//    return encriptedString;
//}
//
//@end
//@end

NS_ASSUME_NONNULL_END