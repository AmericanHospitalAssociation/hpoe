//
//  AppDelegate.m
//  hpoe
//
//  Created by Vince Davis on 4/29/15.
//  Copyright (c) 2015 American Hospital Association. All rights reserved.
//

#import "AppDelegate.h"
#import "MSDynamicsDrawerViewController.h"
#import "MSDynamicsDrawerStyler.h"
#import "MenuViewController.h"
#import "MainViewController.h"
#import "REFrostedViewController.h"
#import "HPOEManager.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import <Crashlytics/Crashlytics.h>
#import <Google/Analytics.h>

@interface AppDelegate ()

@property (nonatomic, retain)REFrostedViewController *frostedViewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //[[Twitter sharedInstance] startWithConsumerKey:@"11bNMMWPauhD6sk1qBZX8ThML" consumerSecret:@"ILbHjRn4VycCs3ZLegQ6nSBduMjatCr0YYvtIESZrvRFe1qjyT"];
    //[Fabric with:@[[Twitter sharedInstance]]];
    [Fabric with:@[CrashlyticsKit, TwitterKit]];
    
    HPOEManager *hpoe = [HPOEManager sharedInstance];
    
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    

    //Setup Global Colors
    [[UINavigationBar appearance] setBarTintColor:hpoe.hpoeRed];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UIToolbar appearance] setTintColor:[UIColor whiteColor]]; // this will change the back button tint
    [[UIToolbar appearance] setBarTintColor:hpoe.hpoeRed];
    //[[UIToolbar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    MenuViewController *menuViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"menu"];
    menuViewController.dynamicsDrawerViewController = self.dynamicsDrawerViewController;
    UINavigationController *menuNav = [[UINavigationController alloc] initWithRootViewController:menuViewController];
    menuNav.toolbarHidden = NO;
    
    MainViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"main"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.toolbarHidden = NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _splitViewController = [[UISplitViewController alloc] init];
        _splitViewController.viewControllers = @[menuNav, nav];
        _splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
        _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _window.rootViewController = _splitViewController;
    }
    else {
        _frostedViewController = [[REFrostedViewController alloc]
                                  initWithContentViewController:nav
                                  menuViewController:menuNav];
        _frostedViewController.direction = REFrostedViewControllerDirectionLeft;
        _frostedViewController.panGestureEnabled = YES;
        _frostedViewController.liveBlur = YES;
        _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _window.rootViewController = _frostedViewController;
    }
    // Create frosted view controller
    //
    
    // Make it a root controller
    //
    
    /*
    // Setup Side Menu
    _dynamicsDrawerViewController = [MSDynamicsDrawerViewController new];
    
    MSDynamicsDrawerResizeStyler *resize = [MSDynamicsDrawerResizeStyler styler];
    resize.minimumResizeRevealWidth = 40.0;
    [_dynamicsDrawerViewController addStylersFromArray:@[[MSDynamicsDrawerScaleStyler styler], [MSDynamicsDrawerFadeStyler styler], [MSDynamicsDrawerParallaxStyler styler], resize] forDirection:MSDynamicsDrawerDirectionLeft];
    
    [_dynamicsDrawerViewController setDrawerViewController:menuNav forDirection:MSDynamicsDrawerDirectionLeft];
    
    _dynamicsDrawerViewController.paneViewController = nav;
    // End Side Menu Setup
     //_window.rootViewController = _dynamicsDrawerViewController;
    */
    
    [_window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - Side Menu Methods
- (void)openSideMenu
{
    [_frostedViewController presentMenuViewController];
    
    
    /*
    [_dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen
                                       animated:YES
                          allowUserInterruption:YES
                                     completion:nil];
     */
}

- (void)closeMenu {
    [_frostedViewController hideMenuViewController];
}

- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController
{
    //barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    //[self.navigationItem setLeftBarButtonItem:barButtonItem
    //animated:YES];
    //self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    //[self.navigationItem setLeftBarButtonItem:nil animated:YES];
    //self.masterPopoverController = nil;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
