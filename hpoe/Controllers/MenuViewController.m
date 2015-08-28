//
//  MenuViewController.m
//  ahaactioncenter
//
//  Created by Server on 4/4/15.
//  Copyright (c) 2015 AHA. All rights reserved.
//

#import "MenuViewController.h"
#import "MainViewController.h"
#import "RATreeView.h"
#import "RATableViewCell.h"
#import "FontAwesomeKit.h"
#import "AppDelegate.h"
#import "HPOEManager.h"
#import "AboutViewController.h"

@interface MenuViewController () <RATreeViewDelegate, RATreeViewDataSource>
{
    UIColor *labelColor;
    int expandCount;
}

@property (strong, nonatomic) NSArray *data;
@property (retain, nonatomic) NSMutableArray *list;
@property (retain, nonatomic) NSDictionary *topics;
@property (weak, nonatomic) RATreeView *treeView;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"HPOE";
    labelColor = [UIColor colorWithRed:0.188 green:0.498 blue:0.886 alpha:1];
    HPOEManager *hpoe = [HPOEManager sharedInstance];
    //[hpoe getHPOEFeed:^(NSDictionary *dict, NSError *err) {
        //NSLog(@"completed");
        //NSArray *arr = (NSArray *)[dict valueForKeyPath:@"topics"];
        //NSLog(@"%@", arr);
        //_topics = (NSDictionary *)arr[0];
    _topics = hpoe.topics;
        //NSLog(@"%@", _topics);
        [self createTopics];
    
    FAKIonIcons *close = [FAKIonIcons iconWithCode:@"\uf126" size:30];
    [close addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[close imageWithSize:CGSizeMake(30, 30)]
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(collaspe)];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMenu:)
                                                 name:@"updateMenu"
                                               object:nil];
    
    RATreeView *treeView = [[RATreeView alloc] initWithFrame:self.view.bounds];
    
    //_data = [self menuItems];
    
    treeView.delegate = self;
    treeView.dataSource = self;
    treeView.treeFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine;
    treeView.backgroundColor = [UIColor clearColor];
    treeView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    treeView.embeddedTableView.backgroundColor = hpoe.hpoeRed;
    [treeView reloadData];
    //self.navigationController.view.backgroundColor = [UIColor clearColor];
    //[treeView setBackgroundColor:[UIColor colorWithWhite:0.97 alpha:0.5]];
    
    self.treeView = treeView;
    [self.view insertSubview:treeView atIndex:0];
    
    for (UIView *v in self.view.subviews) {
        //v.backgroundColor = [UIColor redColor];
    }
    
    //[self.treeView registerNib:[UINib nibWithNibName:NSStringFromClass([UITableViewCell class]) bundle:nil] forCellReuseIdentifier:@"Cell"];
    [self.treeView registerNib:[UINib nibWithNibName:NSStringFromClass([RATableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([RATableViewCell class])];
    //}];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    int systemVersion = [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue];
    if (systemVersion >= 7 && systemVersion < 8) {
        CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
        float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
        self.treeView.contentInset = UIEdgeInsetsMake(heightPadding, 0.0, 0.0, 0.0);
        self.treeView.contentOffset = CGPointMake(0.0, -heightPadding);
    }
    
    self.treeView.frame = self.view.bounds;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    //[[ProgressHUD sharedInstance] showHUDWithMessage:@"tesin"];
}

- (void)checkIfExpanded {
    if (expandCount > 0) {
        FAKIonIcons *close = [FAKIonIcons iconWithCode:@"\uf123" size:30];
        [close addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[close imageWithSize:CGSizeMake(30, 30)]
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(collaspe)];
    }
    else {
        FAKIonIcons *close = [FAKIonIcons iconWithCode:@"\uf126" size:30];
        [close addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[close imageWithSize:CGSizeMake(30, 30)]
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(collaspe)];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didSelectItemFromCollectionView" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateMenu" object:nil];
}

- (void)collaspe {
    expandCount = 0;
    [self checkIfExpanded];
    [_treeView reloadData];
}

- (void)updateMenu:(NSNotification *)notification
{
    //NSLog(@"update Menu");
    HPOEManager *hpoe = [HPOEManager sharedInstance];
    _topics = hpoe.topics;
    [self createTopics];
    [_treeView reloadData];
}

- (void)createTopics {
    _list = [[NSMutableArray alloc] init];
    NSMutableArray *allItems = [[NSMutableArray alloc] init];
    NSMutableSet *firstLvlKeys = [[NSMutableSet alloc] init];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    
    NSArray *keys = [_topics allKeys];
    
    //Create First Level
    for (NSString *key in keys) {
        NSDictionary *dict = (NSDictionary *)_topics[key];
        [allItems addObject:@{@"title" : dict[@"name"], @"id" : key, @"parent" : dict[@"parent_id"], @"storyboard" : @"general", @"level" : @"3", @"image" : @"", @"items" : @[]}];
        if ([dict[@"parent_id"] isEqual:[NSNull null]]) {
            [firstLvlKeys addObject:key];
            //NSLog(@"key %@", key);
        }
    }
    
    NSPredicate *firstLvlPred = [NSPredicate predicateWithFormat:@"parent == %@", [NSNull null]];
    NSArray *firstLevel = [[allItems filteredArrayUsingPredicate:firstLvlPred] sortedArrayUsingDescriptors:@[sort]];
    
    NSPredicate *secondLvlPred = [NSPredicate predicateWithFormat:@"parent IN %@", [firstLvlKeys allObjects]];
    NSArray *secondLevel = [[allItems filteredArrayUsingPredicate:secondLvlPred] sortedArrayUsingDescriptors:@[sort]];
    
    NSPredicate *thirdLvlPred = [NSPredicate predicateWithFormat:@"(NOT (parent IN %@)) AND (parent != %@)", [firstLvlKeys allObjects], [NSNull null]];
    NSArray *thirdLevel = [[allItems filteredArrayUsingPredicate:thirdLvlPred] sortedArrayUsingDescriptors:@[sort]];
    
    //NSLog(@"1st %@", firstLevel);
    //NSLog(@"2nd %@", secondLevel);
    //NSLog(@"3rd %@", thirdLevel);
    
    //create Menus
    NSMutableArray *tempLevel2 = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in secondLevel) {
        NSMutableDictionary *dict2 = [[NSMutableDictionary alloc] init];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"parent == %@", dict[@"id"]];
        NSArray *items = [thirdLevel filteredArrayUsingPredicate:pred];
        /*
        [dict2 setValue:[NSString stringWithFormat:@"%@ (%lu)", dict[@"title"], (unsigned long)items.count]
                 forKey:@"title"];
         */
        [dict2 setValue:dict[@"title"] forKey:@"title"];
        [dict2 setValue:dict[@"id"] forKey:@"id"];
        [dict2 setValue:dict[@"parent"] forKey:@"parent"];
        [dict2 setValue:dict[@"storyboard"] forKey:@"storyboard"];
        [dict2 setValue:@"2" forKey:@"level"];
        [dict2 setValue:@"" forKey:@"image"];
        [dict2 setValue:items
                 forKey:@"items"];
        //NSLog(@"dict %@", dict2);
        [tempLevel2 addObject:dict2];
    }
    
    NSMutableArray *tempLevel1 = [[NSMutableArray alloc] init];
    NSMutableArray *tempLevel4 = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in firstLevel) {
        NSMutableDictionary *dict2 = [[NSMutableDictionary alloc] init];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"parent == %@", dict[@"id"]];
        NSArray *items = [tempLevel2 filteredArrayUsingPredicate:pred];
        /*
        [dict2 setValue:[NSString stringWithFormat:@"%@ (%lu)", dict[@"title"], (unsigned long)items.count]
                 forKey:@"title"];
         */
        [dict2 setValue:dict[@"title"] forKey:@"title"];
        [dict2 setValue:dict[@"id"] forKey:@"id"];
        [dict2 setValue:dict[@"storyboard"] forKey:@"storyboard"];
        [dict2 setValue:@"1" forKey:@"level"];
        [dict2 setValue:@"" forKey:@"image"];
        [dict2 setValue:items
                 forKey:@"items"];
        //NSLog(@"dict %@", dict2);
        [tempLevel1 addObject:dict2];
    }
    
    NSMutableDictionary *homeDict = [[NSMutableDictionary alloc] init];
    [homeDict setValue:@"All Resources" forKey:@"title"];
    [homeDict setValue:@"1" forKey:@"id"];
    [homeDict setValue:@"home" forKey:@"storyboard"];
    [homeDict setValue:@"0" forKey:@"level"];
    [homeDict setValue:@"" forKey:@"image"];
    [homeDict setValue:@[] forKey:@"items"];
    [tempLevel1 insertObject:homeDict atIndex:0];
    
    NSMutableDictionary *tweetDict = [[NSMutableDictionary alloc] init];
    [tweetDict setValue:@"Twitter" forKey:@"title"];
    [tweetDict setValue:@"2" forKey:@"id"];
    [tweetDict setValue:@"twitter" forKey:@"storyboard"];
    [tweetDict setValue:@"0" forKey:@"level"];
    [tweetDict setValue:@"" forKey:@"image"];
    [tweetDict setValue:@[] forKey:@"items"];
    [tempLevel1 insertObject:tweetDict atIndex:tempLevel1.count];
    
    NSMutableDictionary *bookDict = [[NSMutableDictionary alloc] init];
    [bookDict setValue:@"Bookmarks" forKey:@"title"];
    [bookDict setValue:@"3" forKey:@"id"];
    [bookDict setValue:@"bookmarks" forKey:@"storyboard"];
    [bookDict setValue:@"0" forKey:@"level"];
    [bookDict setValue:@"" forKey:@"image"];
    [bookDict setValue:@[] forKey:@"items"];
    [tempLevel1 insertObject:bookDict atIndex:tempLevel1.count];
    
    NSMutableDictionary *aboutDict = [[NSMutableDictionary alloc] init];
    [bookDict setValue:@"About" forKey:@"title"];
    [bookDict setValue:@"3" forKey:@"id"];
    [bookDict setValue:@"about" forKey:@"storyboard"];
    [bookDict setValue:@"0" forKey:@"level"];
    [bookDict setValue:@"" forKey:@"image"];
    [bookDict setValue:@[] forKey:@"items"];
    [tempLevel1 insertObject:aboutDict atIndex:tempLevel1.count];
    //NSLog(@"levels %@", tempLevel1);
    _data = tempLevel1;
}

- (NSArray *)getItems:(NSArray *)items forParent:(NSPredicate *)pred {
    return items;
}

#pragma mark TreeView Data Source
- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item
{
    NSDictionary *row = (NSDictionary *)item;
    //NSLog(@"%@ - %@", row[@"title"], row[@"level"]);
    RATableViewCell *cell = [self.treeView dequeueReusableCellWithIdentifier:NSStringFromClass([RATableViewCell class])];
    [cell setupWithTitle:row[@"title"] level:row[@"level"]];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    BOOL expanded = [_treeView isCellExpanded:cell];
    NSString *chevronCode = (expanded) ? @"\uf123" : @"\uf126" ;
    FAKIonIcons *chevron = [FAKIonIcons iconWithCode:chevronCode size:15];
    [chevron addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[chevron imageWithSize:CGSizeMake(15, 15)]];
    
    NSArray *items = (NSArray *)row[@"items"];
    if (items.count > 0) {
        cell.accessoryView = iv;
    }
    else {
        cell.accessoryView = nil;
    }
    /*
    if ([row[@"level"] intValue] == 1)
    {
        FAKIonIcons *icon = [FAKIonIcons iconWithCode:row[@"image"] size:30];
        [icon addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor]];
        cell.imageView.image = [icon imageWithSize:CGSizeMake(30, 30)];
    }
    else
    {
        cell.imageView.image = nil;
    }
    */
    return cell;
}

- (void)treeView:(RATreeView *)treeView didExpandRowForItem:(id)item {
    expandCount = expandCount + 1;
    [self checkIfExpanded];
    NSDictionary *row = (NSDictionary *)item;
    UITableViewCell *cell = [_treeView cellForItem:item];
    BOOL expanded = [_treeView isCellExpanded:cell];
    NSString *chevronCode = (expanded) ? @"\uf123" : @"\uf126" ;
    FAKIonIcons *chevron = [FAKIonIcons iconWithCode:chevronCode size:15];
    [chevron addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[chevron imageWithSize:CGSizeMake(15, 15)]];
    NSArray *items = (NSArray *)row[@"items"];
    if (items.count > 0) {
        cell.accessoryView = iv;
    }
    else {
        cell.accessoryView = nil;
    }
}

- (void)treeView:(RATreeView *)treeView didCollapseRowForItem:(id)item {
    expandCount = expandCount - 1;
    [self checkIfExpanded];
    NSDictionary *row = (NSDictionary *)item;
    UITableViewCell *cell = [_treeView cellForItem:item];
    BOOL expanded = [_treeView isCellExpanded:cell];
    NSString *chevronCode = (expanded) ? @"\uf123" : @"\uf126" ;
    FAKIonIcons *chevron = [FAKIonIcons iconWithCode:chevronCode size:15];
    [chevron addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[chevron imageWithSize:CGSizeMake(15, 15)]];
    NSArray *items = (NSArray *)row[@"items"];
    if (items.count > 0) {
        cell.accessoryView = iv;
    }
    else {
        cell.accessoryView = nil;
    }
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [_data count];
    }
    
    NSDictionary *row = (NSDictionary *)item;
    NSArray *children = (NSArray *)row[@"items"];
    return children.count;
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    NSDictionary *row = (NSDictionary *)item;
    if (item == nil) {
        return [_data objectAtIndex:index];
    }
    NSArray *children = (NSArray *)row[@"items"];
    return children[index];
}

- (BOOL)treeView:(RATreeView *)treeView canEditRowForItem:(id)item {
    return NO;
}

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item
{
    NSDictionary *row = (NSDictionary *)item;
    //[treeView deselectRowForItem:item animated:YES];
    
    //[[KGModal sharedInstance] showWithContentView:v andAnimated:YES];
    if (![row[@"storyboard"] isEqualToString:@""])
    {
        if ([row[@"storyboard"] isEqualToString:@"general"]) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:row[@"id"] forKey:@"id"];
            [[NSNotificationCenter defaultCenter] postNotificationName: @"changeFilter" object:nil userInfo:userInfo];
        }
        if ([row[@"storyboard"] isEqualToString:@"home"]) {
            [self collaspe];
            AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [ad closeMenu];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"" forKey:@"id"];
            [[NSNotificationCenter defaultCenter] postNotificationName: @"changeFilter" object:nil userInfo:userInfo];
        }
        if ([row[@"storyboard"] isEqualToString:@"twitter"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName: @"showTweets" object:nil userInfo:nil];
        }
        if ([row[@"storyboard"] isEqualToString:@"bookmarks"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName: @"showBookmarks" object:nil userInfo:nil];
        }
        if ([row[@"storyboard"] isEqualToString:@"about"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName: @"showAbout" object:nil userInfo:nil];
        }
        //NSLog(@"Storyboard %@ %@", row[@"storyboard"], row);
        //[self transitionToViewController:row];
    }
    
    NSArray *items = (NSArray *)row[@"items"];
    if (items.count == 0) {
        AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [ad closeMenu];
    }
}

- (void)transitionToViewController:(NSDictionary *)dict
{
    UINavigationController *nav;
    NSString *storyboard = dict[@"storyboard"];
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    MSDynamicsDrawerViewController *dynamic = (MSDynamicsDrawerViewController *)ad.dynamicsDrawerViewController;
    [dynamic setPaneViewController:nav animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
