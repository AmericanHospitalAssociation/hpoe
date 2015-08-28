//
//  AHAFeed.m
//  ahaactioncenter
//
//  Created by Vince Davis on 4/7/15.
//  Copyright (c) 2015 AHA. All rights reserved.
//

#import "HPOEFeed.h"

@implementation HPOEFeed

-(id)init {
    self = [super init];
    if (self) {
        [self setValue:@"HPOETop" forKeyPath:@"propertyArrayMap.top"];
        [self setValue:@"HPOEResource" forKeyPath:@"propertyArrayMap.resources"];
        [self setValue:@"HPOEType" forKeyPath:@"propertyArrayMap.types"];
        [self setValue:@"HPOETopic" forKeyPath:@"propertyArrayMap.topics"];
    }
    return self;
}

@end
