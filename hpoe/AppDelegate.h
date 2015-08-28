//
//  AppDelegate.h
//  hpoe
//
//  Created by Vince Davis on 4/29/15.
//  Copyright (c) 2015 American Hospital Association. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSDynamicsDrawerViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MSDynamicsDrawerViewController *dynamicsDrawerViewController;
@property (strong, nonatomic) UISplitViewController *splitViewController;

- (void)openSideMenu;
- (void)closeMenu;


@end

