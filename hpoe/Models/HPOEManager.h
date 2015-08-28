//
//  ActionCenterManager.h
//  ahaactioncenter
//
//  Created by Server on 4/4/15.
//  Copyright (c) 2015 AHA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "FontAwesomeKit.h"
/**
 `HPOEManager` is a class that pulls in data from Solstice rest to get contact info
 */
@interface HPOEManager : NSObject

typedef void (^CompletionHPOEFeed)(NSDictionary *dict, NSError *error);


@property(nonatomic, retain)NSArray *feeds, *alerts;

/**
 Shared instance
 */
+ (id)sharedInstance;

- (void)getHPOEFeed:(CompletionHPOEFeed)completion;

+ (UIBarButtonItem *)splitButton;
+ (UIBarButtonItem *)dragButton;
+ (UIBarButtonItem *)refreshButton;

@property (nonatomic, retain)NSDictionary *topics;
@property (nonatomic, retain)NSArray *top;
@property (nonatomic, retain)NSDictionary *types;
@property (nonatomic, retain)NSArray *resources;
@property (nonatomic, retain)UIColor *hpoeBlue, *hpoeBlue2, *hpoeTeal, *hpoeLightBlue, *hpoeOrange, *hpoeGreen, *hpoeRed;


@end
