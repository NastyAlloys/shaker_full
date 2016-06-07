//
//  NSDate+NHAppCore.m
//  Pods
//
//  Created by Sergey Minakov on 01.10.15.
//
//

#import "NSDate+NHAppCore.h"

@implementation NSDate (NHExtension)

+ (NSDate *)dateByAddingToDate:(NSDate *)date day:(NSInteger)day week:(NSInteger)week month:(NSInteger)month year:(NSInteger)year {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = day;
    components.weekOfYear = week;
    components.month = month;
    components.year = year;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:components toDate:date options:0];
}
+ (NSDate *)dateByAddingToDate:(NSDate *)date hour:(NSInteger)hour minute:(NSInteger)minute {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.hour = hour;
    components.minute = minute;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateByAddingComponents:components toDate:date options:0];
}

- (NSDate *)addDay:(NSInteger)day week:(NSInteger)week month:(NSInteger)month year:(NSInteger)year {
    return [[self class] dateByAddingToDate:self day:day week:week month:month year:year];
}
- (NSDate *)addHour:(NSInteger)hour minute:(NSInteger)minute {
    return [[self class] dateByAddingToDate:self hour:hour minute:minute];
}
- (NSDate *)addDay:(NSInteger)day {
    return [self addDay:day week:0 month:0 year:0];
}
- (NSDate *)addWeek:(NSInteger)week {
    return [self addDay:0 week:week month:0 year:0];
}
- (NSDate *)addMonth:(NSInteger)month {
    return [self addDay:0 week:0 month:month year:0];
}
- (NSDate *)addYear:(NSInteger)year {
    return [self addDay:0 week:0 month:0 year:year];
}

+ (NSDate *)startForCalendarUnit:(NSCalendarUnit)calendarUnit date:(NSDate *)date {
    NSDate *resultDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar rangeOfUnit:calendarUnit
                startDate:&resultDate
                 interval:nil
                  forDate:date];
    
    return resultDate;
}

+ (NSDate *)dayStartForDate:(NSDate *)date {
    return [self startForCalendarUnit:NSCalendarUnitDay date:date];
}

+ (NSDate *)weekStartForDate:(NSDate *)date {
    return [self startForCalendarUnit:NSCalendarUnitWeekOfYear date:date];
}

+ (NSDate *)monthStartForDate:(NSDate *)date {
    return [self startForCalendarUnit:NSCalendarUnitMonth date:date];
}

+ (NSDate *)yearStartForDate:(NSDate *)date {
    return [self startForCalendarUnit:NSCalendarUnitYear date:date];
}

- (NSDate *)startForCalendarUnit:(NSCalendarUnit)calendarUnit {
    return [[self class] startForCalendarUnit:calendarUnit date:self];
}

- (NSDate *)dayStart {
    return [[self class] dayStartForDate:self];
}

- (NSDate *)weekStart {
    return [[self class] weekStartForDate:self];
}

- (NSDate *)monthStart {
    return [[self class] monthStartForDate:self];
}

- (NSDate *)yearStart {
    return [[self class] yearStartForDate:self];
}

- (NSDateComponents *)components {
    return [[NSCalendar currentCalendar]
            components:NSCalendarUnitMinute
            |NSCalendarUnitHour
            |NSCalendarUnitDay
            |NSCalendarUnitWeekOfYear
            |NSCalendarUnitMonth
            |NSCalendarUnitYear
            fromDate:self];
}

- (NSDateComponents *)componentsToDate:(NSDate *)date {
    return [[NSCalendar currentCalendar]
            components:NSCalendarUnitMinute
            |NSCalendarUnitHour
            |NSCalendarUnitDay
            |NSCalendarUnitWeekOfYear
            |NSCalendarUnitMonth
            |NSCalendarUnitYear
            fromDate:self
            toDate:date
            options:0];
}

@end
