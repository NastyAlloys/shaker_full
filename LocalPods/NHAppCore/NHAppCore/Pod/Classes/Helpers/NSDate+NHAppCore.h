//
//  NSDate+NHAppCore.h
//  Pods
//
//  Created by Sergey Minakov on 01.10.15.
//
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (NHExtension)

+ (nullable NSDate *)dateByAddingToDate:(nullable NSDate *)date day:(NSInteger)day week:(NSInteger)week month:(NSInteger)month year:(NSInteger)year;
+ (nullable NSDate *)dateByAddingToDate:(nullable NSDate *)date hour:(NSInteger)hour minute:(NSInteger)minute;

+ (nullable NSDate *)startForCalendarUnit:(NSCalendarUnit)calendarUnit date:(NSDate *)date;
+ (nullable NSDate *)dayStartForDate:(nullable NSDate *)date;
+ (nullable NSDate *)weekStartForDate:(nullable NSDate *)date;
+ (nullable NSDate *)monthStartForDate:(nullable NSDate *)date;
+ (nullable NSDate *)yearStartForDate:(nullable NSDate *)date;

- (nullable NSDate *)addDay:(NSInteger)day week:(NSInteger)week month:(NSInteger)month year:(NSInteger)year;
- (nullable NSDate *)addHour:(NSInteger)hour minute:(NSInteger)minute;
- (nullable NSDate *)addDay:(NSInteger)day;
- (nullable NSDate *)addWeek:(NSInteger)week;
- (nullable NSDate *)addMonth:(NSInteger)month;
- (nullable NSDate *)addYear:(NSInteger)year;

- (nullable NSDate *)startForCalendarUnit:(NSCalendarUnit)calendarUnit;
- (nullable NSDate *)dayStart;
- (nullable NSDate *)weekStart;
- (nullable NSDate *)monthStart;
- (nullable NSDate *)yearStart;

- (NSDateComponents *)components;
- (NSDateComponents *)componentsToDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
