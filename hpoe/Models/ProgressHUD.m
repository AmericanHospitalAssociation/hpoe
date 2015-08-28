//
//  ProgressHUD.m
//  ahaactioncenter
//
//  Created by Server on 4/5/15.
//  Copyright (c) 2015 AHA. All rights reserved.
//

#import "ProgressHUD.h"
#import "AppDelegate.h"
#import "MSDynamicsDrawerViewController.h"

@implementation ProgressHUD

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static ProgressHUD *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[ProgressHUD alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setupHUD];
    }
    return self;
}

- (void)setupHUD
{
    //if (HUD) {
        [HUD removeFromSuperview];
    //}
    
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    progressImage = [[M13ProgressViewImage alloc] init];
    [progressImage setProgressImage:[UIImage imageNamed:@"HPOE_app_logo"]];
    HUD = [[M13ProgressHUD alloc] initWithProgressView:progressImage];
    HUD.progressViewSize = CGSizeMake(120.0, 120.0);
    HUD.hudBackgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
    //[HUD setMaskType:M13ProgressHUDMaskTypeGradient];
    HUD.statusColor = [UIColor blackColor];
    HUD.shouldAutorotate = YES;
    [HUD setStatusPosition:M13ProgressHUDStatusPositionBelowProgress];
    
    HUD.maskType = M13ProgressHUDMaskTypeNone;
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        UISplitViewController *split = (UISplitViewController *)ad.splitViewController;
        [split.view addSubview:HUD];
    }
    else {
        UIWindow *window = ad.window;
        //MSDynamicsDrawerViewController *d = (MSDynamicsDrawerViewController *)window.rootViewController;
        //[d.view addSubview:HUD];
        [window addSubview:HUD];
    }
}

- (void)addHUDtoView {
    
}

- (void)removeHUD
{
    [hudTimer invalidate];
    [HUD hide:YES];
}

- (void)showHUDWithMessage:(NSString *)msg
{
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //[self setupHUD];
    [HUD setProgress:0.0 animated:YES];
    HUD.status = msg;
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        UISplitViewController *split = (UISplitViewController *)ad.splitViewController;
        [split.view bringSubviewToFront:HUD];
        HUD.center = split.view.center;
    }
    else {
        UIWindow *window = ad.window;
        //MSDynamicsDrawerViewController *d = (MSDynamicsDrawerViewController *)window.rootViewController;
        //[d.view bringSubviewToFront:HUD];
        HUD.center = window.center;
        [window bringSubviewToFront:HUD];
    }
    
    [HUD show:YES];
    hudTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                target:self
                                              selector:@selector(animateHUD)
                                              userInfo:nil repeats:YES];
}

- (void)showHUDSucces:(BOOL)good withMessage:(NSString *)msg
{
    [hudTimer invalidate];
    if (good)
    {
        [HUD setProgress:1.0 animated:NO];
    }
    else
    {
        [HUD setProgress:0.0 animated:NO];
    }
    HUD.status = msg;
    [self performSelector:@selector(removeHUD) withObject:nil afterDelay:1.5];
}

- (void)animateHUD
{
    progress = progress + 0.2;
    [HUD setProgress:progress animated:YES];
    if (progress > 1.0)
    {
        progress = 0.0;
        [HUD setProgress:progress animated:NO];
    }
}

@end
