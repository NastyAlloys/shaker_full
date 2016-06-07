//
//  NHModelObject.m
//  Pods
//
//  Created by Sergey Minakov on 17.09.15.
//
//

#import "NHModelObject.h"
#import "NHKeychain.h"

@implementation NHModelObject

+ (instancetype)convertFromObject:(id)object {
    return nil;
}

+ (NSSortDescriptor*)sortDescriptor {
    return [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
}

@end
