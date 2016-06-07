//
//  NSString+NHAppCore.m
//  Pods
//
//  Created by Sergey Minakov on 01.10.15.
//
//

#import "NSString+NHAppCore.h"

NSString * const kNHDefaultPluralizeStringSeprator = @"; ";

@implementation NSString (NHExtension)

+ (nullable id)jsonObjectWithJson:(nullable NSString*)jsonString {
    if ([jsonString length]) {
        return [NSJSONSerialization JSONObjectWithData:[jsonString
                                                        dataUsingEncoding:NSUTF8StringEncoding]
                                               options:NSJSONReadingAllowFragments
                                                 error:nil];
    }
    
    return nil;
}

- (nullable id)jsonObject {
    return [[self class] jsonObjectWithJson:self];
}

+ (nullable NSString *)pluralizeString:(nullable NSString *)string number:(double)number separator:(NSString *)separator {
    
    if ([string length]) {
        NSArray *separatedArray = [string componentsSeparatedByString:separator];
        
        if ([separatedArray count]) {
            NSString *(^pluralizeBlock)(NSArray *array,
                                        NSInteger index) = ^NSString *(NSArray *array,
                                                                       NSInteger index) {
                for (NSInteger arrayIndex = index; arrayIndex >= 0; arrayIndex--) {
                    if ([array count] > arrayIndex) {
                        return array[arrayIndex];
                    }
                }
                
                return nil;
            };
            
            NSInteger pluralizationNumber = round(number);
            if (pluralizationNumber == 1) {
                return pluralizeBlock(separatedArray, 0);
            }
            else {
                pluralizationNumber = pluralizationNumber % 100;
                
                if (pluralizationNumber == 1) {
                    return pluralizeBlock(separatedArray, 1);
                }
                else if (pluralizationNumber >= 11 && pluralizationNumber <= 14) {
                    return pluralizeBlock(separatedArray, 3);
                }
                else {
                    pluralizationNumber = pluralizationNumber % 10;
                    
                    if (pluralizationNumber == 1) {
                        return pluralizeBlock(separatedArray, 1);
                    }
                    else if (pluralizationNumber >= 2 && pluralizationNumber <= 4) {
                        return pluralizeBlock(separatedArray, 2);
                    }
                    else {
                        return pluralizeBlock(separatedArray, 3);
                    }
                }
            }
        }
    }
    
    return string;
}

+ (nullable NSString *)pluralizeString:(nullable NSString *)string number:(double)number {
    return [self pluralizeString:string number:number separator:kNHDefaultPluralizeStringSeprator];
}
- (nullable NSString *)pluralize:(double)number separator:(NSString *)separator {
    return [[self class] pluralizeString:self number:number separator:separator];
}

- (nullable NSString *)pluralize:(double)number {
    return [self pluralize:number separator:kNHDefaultPluralizeStringSeprator];
}

+ (NSString *)stringWithFormat:(NSString *)format array:(NSArray *)arguments {
    return [NSString stringWithFormat:format,
            arguments.count > 0 ? arguments[0] : nil,
            arguments.count > 1 ? arguments[1] : nil,
            arguments.count > 2 ? arguments[2] : nil,
            arguments.count > 3 ? arguments[3] : nil,
            arguments.count > 4 ? arguments[4] : nil,
            arguments.count > 5 ? arguments[5] : nil,
            arguments.count > 6 ? arguments[6] : nil,
            arguments.count > 7 ? arguments[7] : nil,
            arguments.count > 8 ? arguments[8] : nil,
            arguments.count > 9 ? arguments[9] : nil];
}

@end