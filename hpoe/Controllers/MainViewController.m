//
//  MainViewController.m
//  ahaactioncenter
//
//  Created by Server on 4/5/15.
//  Copyright (c) 2015 AHA. All rights reserved.
//

#import "MainViewController.h"
#import "FontAwesomeKit.h"
#import "SAScrollTableViewCell.h"
#import "AppDelegate.h"
#import "HPOEManager.h"
#import "ORGContainerCell.h"
#import "ORGContainerCellView.h"
#import "ArticleDetailViewController.h"
#import "TweetViewController.h"
#import "ArticleTableViewController.h"
#import "SearchTableViewController.h"
#import "ProgressHUD.h"
#import "AboutViewController.h"
#import <Google/Analytics.h>

@interface MainViewController ()
<UITableViewDataSource, UITableViewDelegate, SAScrollTableViewCellDelegate>
{
    HPOEManager *hpoe;
    NSArray *types;
    NSString *filterId;
    ProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"HPOE";
    filterId = @"";
    _tableview.delegate = self;
    _tableview.dataSource = self;
    
    // Register the table cell
    [_tableview registerClass:[ORGContainerCell class] forCellReuseIdentifier:@"ORGContainerCell"];
    
    // Add observer that will allow the nested collection cell to trigger the view controller select row at index path
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectItemFromCollectionView:) name:@"didSelectItemFromCollectionView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeFilter:)
                                                 name:@"changeFilter"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showTweets:)
                                                 name:@"showTweets"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showBookmarks:)
                                                 name:@"showBookmarks"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAbout:)
                                                 name:@"showAbout"
                                               object:nil];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    
    // Configure Refresh Control
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    // Configure View Controller
    [_tableview addSubview:refreshControl];
    
    hpoe = [HPOEManager sharedInstance];
    HUD = [ProgressHUD sharedInstance];
    [HUD showHUDWithMessage:@"Loading Content"];
    [hpoe getHPOEFeed:^(NSDictionary *dict, NSError *err) {
        //NSLog(@"types %@", hpoe.top);
        [self getResources];
        [self.tableview reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"updateMenu" object:nil userInfo:nil];
        [HUD showHUDSucces:YES withMessage:@"Loaded"];
    }];

    
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hpoe_inverted_logo"]];
    titleImageView.frame = CGRectMake(0, 0, 120, 35);
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = titleImageView;
    
    self.navigationController.toolbarHidden = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.navigationItem.leftBarButtonItem = [MainViewController dragButton];
    }
    
    FAKIonIcons *search = [FAKIonIcons iconWithCode:@"\uf4a5" size:30];
    [search addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[search imageWithSize:CGSizeMake(30, 30)]
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(search:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Main"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

+ (UIBarButtonItem *)dragButton {
    FAKIonIcons *drag = [FAKIonIcons iconWithCode:@"\uf130" size:30];
    [drag addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithImage:[drag imageWithSize:CGSizeMake(30, 30)]
                                                            style:UIBarButtonItemStylePlain
                                                           target:ad
                                                           action:@selector(openSideMenu)];
    return btn;
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    HUD = [ProgressHUD sharedInstance];

    [HUD showHUDWithMessage:@"Loading Content"];
    [hpoe getHPOEFeed:^(NSDictionary *dict, NSError *err) {
        //NSLog(@"types %@", hpoe.top);
        [self getResources];
        filterId = @"";
        [self.tableview reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"updateMenu" object:nil userInfo:nil];
        [HUD showHUDSucces:YES withMessage:@"Loaded"];
        [refreshControl endRefreshing];
    }];
}

- (void)search:(id)sender {
    SearchTableViewController *vc = (SearchTableViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"search"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:nav
                                            animated:YES
                                          completion:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSelectItemFromCollectionView" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeFilter" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showTweets" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showBookmarks" object:nil];
}

- (void)changeFilter:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    //NSLog(@"works %@", userInfo);
    filterId = userInfo[@"id"];
    [self getResources];
    [_tableview reloadData];
}

- (void)showTweets:(NSNotification *)notification
{
    TweetViewController *vc = [[TweetViewController alloc] init];    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
     [self.navigationController presentViewController:nav
                                             animated:YES
                                           completion:nil];
}

- (void)showBookmarks:(NSNotification *)notification
{
    ArticleTableViewController *vc = (ArticleTableViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"article"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:nav
                                            animated:YES
                                          completion:nil];
}

- (void)showAbout:(NSNotification *)notification
{
    AboutViewController *vc = (AboutViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"about"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navigationController presentViewController:nav
                                            animated:YES
                                          completion:nil];
}

- (NSArray *)setTopItems {
    return hpoe.top;
}

- (void)getResources {
    NSMutableSet *typeIds = [[NSMutableSet alloc] init];
    NSArray *tmp;
    if ([filterId isEqualToString:@""]) {
        tmp = hpoe.resources;
    }
    else {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"topics CONTAINS[cd] %@", filterId];
        tmp = [hpoe.resources filteredArrayUsingPredicate:pred];
        //NSLog(@"count %lu", (unsigned long)tmp.count);
    }
    for (NSDictionary *dict in tmp) {
        //NSDictionary *type = (NSDictionary *)hpoe.types[dict[@"type_id"]];
        //NSString *name = type[@"name"];
        [typeIds addObject:dict[@"type_id"]];
    }
    
    types = [typeIds allObjects];
    NSLog(@"%@",types);
}

- (NSArray *)getResourcesForType:(NSString *)type {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"type_id == %@", type];
    NSArray *filtered = [hpoe.resources filteredArrayUsingPredicate:pred];
    //NSLog(@"list %@", filtered);
    return filtered;
}

#pragma mark - UITableView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _tableview.frame.size.width, 21)];
    label.backgroundColor = [UIColor clearColor];
    if (section == 0) {
        label.textColor = [UIColor whiteColor];
        label.text = @"User Favorites";
        label.backgroundColor = hpoe.hpoeOrange;
    }
    else {
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = hpoe.hpoeRed;
        NSDictionary *type = (NSDictionary *)hpoe.types[[types objectAtIndex:(section - 1)]];
        NSString *name = type[@"name"];
        label.text = name;
        if ([name isEqualToString:@"Case Studies"]) {
            label.backgroundColor = hpoe.hpoeTeal;
        }
        if ([name isEqualToString:@"Chair Files"]) {
            label.backgroundColor = hpoe.hpoeOrange;
        }
        if ([name isEqualToString:@"HPOE Live Webinars"]) {
            label.backgroundColor = hpoe.hpoeRed;
        }
        if ([name isEqualToString:@"Guides/Reports"]) {
            label.backgroundColor = hpoe.hpoeRed;
        }
    }
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 21.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 180.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1 + types.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const cellIdentifier = @"Cell";
    
    ORGContainerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ORGContainerCell"];
    //NSDictionary *cellData = [self.sampleData objectAtIndex:[indexPath section]];
    if (indexPath.section == 0) {
        [cell setCollectionData:[self setTopItems]];
    }
    else {
        NSString *type_id = [types objectAtIndex:(indexPath.section - 1)];
        [cell setCollectionData:[self getResourcesForType:type_id]];
    }

    return cell;
}

#pragma mark - SAScrollTableViewCellDelegate
- (void)scrollTableViewCell:(SAScrollTableViewCell *)scrollTableViewCell didSelectMediaAtIndexPath:(NSIndexPath *)indexPath atRow:(NSInteger)row {
    //NSLog(@"[SAScrollTableViewCell] row:%d, media selected:%d", (int)row, (int)indexPath.row);
    NSDictionary *dict;
    if (indexPath.row == 0) {
        dict = (NSDictionary *)hpoe.top[row];
    }
    else {
        
    }
    
    ArticleDetailViewController *vc = (ArticleDetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"articleDetail"];
    vc.item = dict;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - NSNotification to select table cell
- (void) didSelectItemFromCollectionView:(NSNotification *)notification
{
    NSDictionary *cellData = [notification object];
    if (cellData)
    {
        //NSLog(@"selected %@", cellData);
        
        ArticleDetailViewController *vc = (ArticleDetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"articleDetail"];
        vc.item = cellData;
         
        //TweetViewController *vc = [[TweetViewController alloc] init];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
