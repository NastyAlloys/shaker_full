//
//  NSDate+NHNetworkDate.m
//  Pods
//
//  Created by Sergey Minakov on 23.09.15.
//
//

#import "NSDate+NHNetworkDate.h"
#import "NHNetworkDate.h"

@implementation NSDate (NHNetworkDate)

+ (NSDate *)networkDate {
    return [[NHNetworkDate sharedInstance] date];
}

@end
