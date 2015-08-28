//
//  ActionCenterManager.m
//  ahaactioncenter
//
//  Created by Server on 4/4/15.
//  Copyright (c) 2015 AHA. All rights reserved.
//

#import "HPOEManager.h"
#import "AppDelegate.h"

static NSString *HPOEFeedLink = @"http://www.hpoe.org/inc-hpoe/dhtml/hpoemobileapp.dhtml";

@implementation HPOEManager

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static HPOEManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[HPOEManager alloc] init];
    });
    return sharedInstance;
}

-(id)init {
    self = [super init];
    if (self) {
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        _hpoeBlue = [self colorFromHexString:@"#00529b"];
        _hpoeLightBlue = [self colorFromHexString:@"#4db1ef"];
        _hpoeGreen = [self colorFromHexString:@"#55b49a"];
        _hpoeBlue2 = [self colorFromHexString:@"#1982d1"];
        _hpoeOrange = [self colorFromHexString:@"#e77a47"];
        _hpoeRed = [self colorFromHexString:@"#ae1e43"];
        _hpoeTeal = [self colorFromHexString:@"#0096b3"];
    }
    return self;
}

#pragma mark - Share Methods
+ (UIBarButtonItem *)dragButton {
    FAKIonIcons *drag = [FAKIonIcons iconWithCode:@"\uf130" size:30];
    [drag addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithImage:[drag imageWithSize:CGSizeMake(30, 30)]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(openPane)];
    return btn;
}

+ (UIBarButtonItem *)splitButton {
    FAKIonIcons *drag = [FAKIonIcons iconWithCode:@"\uf264" size:30];
    [drag addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithImage:[drag imageWithSize:CGSizeMake(30, 30)]
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(closeMenu)];
    return btn;
}

+ (UIBarButtonItem *)refreshButton {
    FAKIonIcons *refresh = [FAKIonIcons iconWithCode:@"\uf49a" size:30];
    [refresh addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithImage:[refresh imageWithSize:CGSizeMake(30, 30)]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:nil
                                                                             action:nil];
    return btn;
}

+ (void)openPane
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[ad openSideMenu];
}

+ (void)closeMenu
{
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //UISplitViewController *split = (UISplitViewController *)ad.splitViewController;
    //[ad toggleMenu];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (BOOL)isReachable {
    AFNetworkReachabilityManager *reach = [AFNetworkReachabilityManager sharedManager];
    [reach startMonitoring];
    BOOL reachable = [reach isReachable];
    //NSLog(@"%i reach", reachable);
    if (!reachable) {
        //[[ProgressHUD sharedInstance] showHUDSucces:NO withMessage:@"No Internet"];
        /*
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"NO Internet Connection" message:@"Please Try agin once you have an internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [av show];
         */
    }
    return reachable;
}

#pragma mark - HPOE Methods
- (void)getHPOEFeed:(CompletionHPOEFeed)completion
{
    NSString *strUrl = HPOEFeedLink;
    NSURL *url = [NSURL URLWithString:strUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:20.0];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
        //NSLog(@"dict %@", dict);
        /*
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        AHAFeed *feed = [[AHAFeed alloc] initWithJSONData:jsonData];
         */
        //_feeds = (NSArray *)dict[@"FEED_PAYLOAD"];
        //_alerts = (NSArray *)dict[@"FEED_NOTIFICATIONS"];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"published" ascending:NO];
        
        _top = [(NSArray *)[dict valueForKeyPath:@"top"] sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        _resources = [(NSArray *)[dict valueForKeyPath:@"resources"] sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        NSArray *arr2 = [(NSArray *)[dict valueForKeyPath:@"topics"] sortedArrayUsingDescriptors:@[sort]];
        //NSLog(@"---------------%@-------------", arr2);
        _topics = (NSDictionary *)arr2[0];
        
        NSArray *arr3 = [(NSArray *)[dict valueForKeyPath:@"types"] sortedArrayUsingDescriptors:@[sort]];
        //NSLog(@"---------------%@-------------", arr3);
        _types = (NSDictionary *)arr3[0];
        
        completion(dict, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
    
    [operation start];
}

@end
