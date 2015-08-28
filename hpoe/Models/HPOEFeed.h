//
//  HPOEFeed.h
//  ahaactioncenter
//
//  Created by Vince Davis on 6/1/15.
//  Copyright (c) 2015 AHA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+ObjectMap.h"
#import "HPOETop.h"
//#import "HPOEResource.h"
//#import "HPOEType.h"
//#import "HPOETopic.h"

@interface HPOEFeed : NSObject

@property(nonatomic, retain)NSArray *top;
@property(nonatomic, retain)NSArray *resources;
@property(nonatomic, retain)NSArray *types;
@property(nonatomic, retain)NSArray *topics;
@property(nonatomic, retain)NSString *date;

@end
