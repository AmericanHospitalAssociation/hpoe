//
//  ProgressHUD.h
//  ahaactioncenter
//
//  Created by Server on 4/5/15.
//  Copyright (c) 2015 AHA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M13ProgressHUD.h"
#import "M13ProgressViewRing.h"
#import "M13ProgressViewImage.h"

@interface ProgressHUD : NSObject
{
    M13ProgressHUD *HUD;
    M13ProgressViewImage *progressImage;
    double progress;
    NSTimer *hudTimer;
}

+ (id)sharedInstance;

- (void)showHUDWithMessage:(NSString *)msg;
- (void)showHUDSucces:(BOOL)good withMessage:(NSString *)msg;

@end
