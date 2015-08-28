//
//  HPOETop.h
//  ahaactioncenter
//
//  Created by Vince Davis on 4/7/15.
//  Copyright (c) 2015 AHA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+ObjectMap.h"

@interface HPOETop : NSObject

@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *synopsis;
@property (nonatomic, retain) NSString *featured;
@property (nonatomic, retain) NSNumber *description;
@property (nonatomic, retain) NSString *image_url;
@property (nonatomic, retain) NSString *published;
@property (nonatomic, retain) NSString *organization;
@property (nonatomic, retain) NSString *type_id;
@property (nonatomic, retain) NSString *Why;
@property (nonatomic, retain) NSString *parent_id;
@property (nonatomic, retain) NSString *topics;

@end
