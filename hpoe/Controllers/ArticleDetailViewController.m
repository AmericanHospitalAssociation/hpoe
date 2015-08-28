//
//  ArticleDetailViewController.m
//  
//
//  Created by Davis, Vincent on 7/1/15.
//
//

#import "ArticleDetailViewController.h"
#import "FontAwesomeKit.h"
#import "MDHTMLLabel.h"
#import "PBWebViewController.h"
#import "ProgressHUD.h"
#import "HPOEManager.h"
#import "AMPPreviewController.h"
#import "AMPreviewControllerViewController.h"

@interface ArticleDetailViewController () <MDHTMLLabelDelegate> {
    ProgressHUD *HUD;
}

@end

@implementation ArticleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSLog(@"item%@", _item);
    self.title = _item[@"name"];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSArray *bookmarks = [prefs arrayForKey:@"bookmarks"];
    if (bookmarks == nil) {
        bookmarks = [[NSArray alloc] init];
    }
    BOOL bookmarked = [bookmarks containsObject:[self cleanDictionary:_item]];
    NSString *code = (bookmarked) ? @"\uf4b3" : @"\uf4b2";
    FAKIonIcons *bookmark = [FAKIonIcons iconWithCode:code size:30];
    [bookmark addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[bookmark imageWithSize:CGSizeMake(30, 30)]
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(toogleBookmark:)];
    

    if (_item[@"url"] != [NSNull null]) {
        NSString *showStr = ([_item[@"url"] hasSuffix:@".pdf"]) ? @"SHOW PDF" : @"VIEW RESOURCE";
        UIBarButtonItem *buttonOne = [[UIBarButtonItem alloc] initWithTitle:showStr
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(show:)];
        
        UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        [self setToolbarItems:@[flex, buttonOne, flex]];
        //NSLog(@" more %@", _item[@"url"]);
    }
}

- (void)show:(id)sender {
    
    NSString *url = _item[@"url"];
    
    if (![url hasPrefix:@"http"]) {
        url = [NSString stringWithFormat:@"http://%@", url];
    }
    
    if ([url hasSuffix:@".pdf"]){
        AMPreviewControllerViewController *pc = [[AMPreviewControllerViewController alloc]
                                    initWithRemoteFile:[NSURL URLWithString:url]];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.navigationController pushViewController:pc animated:YES];
        }
        else {
            NSLog(@"pressent");
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:pc];
            pc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                                 target:pc
                                                                                                 action:@selector(dismiss)];
            [self presentViewController:nav animated:YES completion:nil];
        }
    }
    else {
        PBWebViewController *vc = [[PBWebViewController alloc] init];
        vc.URL = [NSURL URLWithString:url];
        //NSLog(@" more %@", url);
        // These are custom UIActivity subclasses that will show up in the UIActivityViewController
        // when the action button is clicked
        //PBSafariActivity *activity = [[PBSafariActivity alloc] init];
        //self.webViewController.applicationActivities = @[activity];
        
        // This property also corresponds to the same one on UIActivityViewController
        // Both properties do not need to be set unless you want custom actions
        vc.excludedActivityTypes = @[UIActivityTypePostToWeibo];
        
        // Push it
        [self.navigationController pushViewController:vc animated:YES];
        
        
    }
}

- (void)toogleBookmark:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSArray *bookmarks = [prefs arrayForKey:@"bookmarks"];
    BOOL bookmarked = [bookmarks containsObject:[self cleanDictionary:_item]];
    NSString *code = (bookmarked) ?  @"\uf4b2" : @"\uf4b3";
    FAKIonIcons *bookmark = [FAKIonIcons iconWithCode:code size:30];
    [bookmark addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[bookmark imageWithSize:CGSizeMake(30, 30)]
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(toogleBookmark:)];
    NSMutableArray *temp;
    
    if (bookmarks == nil) {
        temp = [[NSMutableArray alloc] init];
    }
    else {
        temp = [[NSMutableArray alloc] initWithArray:bookmarks];
    }
    
    NSDictionary *dict = [self cleanDictionary:_item];
    
    if (bookmarked) {
        [temp removeObject:dict];
    }
    else {
        [temp addObject:dict];
    }
    
    HUD = [ProgressHUD sharedInstance];
    NSString *msg = (bookmarked) ? @"Removing Bookmark" : @"Adding Bookmark";
    [HUD showHUDWithMessage:msg];
    [HUD showHUDSucces:YES withMessage:msg];
    
    [prefs setObject:(NSArray *)temp forKey:@"bookmarks"];
    [prefs synchronize];
}

- (NSDictionary *)cleanDictionary:(NSDictionary *)d {
    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithDictionary:d];
    if (d[@"ams_code"] == [NSNull null]) {
        tmpDict[@"ams_code"] = @"";
    }
    if (d[@"parent_id"] == [NSNull null]) {
        tmpDict[@"parent_id"] = @"";
    }
    if (d[@"description"] == [NSNull null]) {
        tmpDict[@"description"] = @"";
    }
    if (d[@"image_url"] == [NSNull null]) {
        tmpDict[@"image_url"] = @"";
    }
    if (d[@"description"] == [NSNull null]) {
        tmpDict[@"description"] = @"";
    }
    
    return (NSDictionary *)tmpDict;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    HPOEManager *hpoe = [HPOEManager sharedInstance];
    NSString *name;
    if (section == 0) {
        name = @"Name";
    }
    else if (section == 99) {
        name = @"Published Date";
    }
    else if (section == 99) {
        name = @"Organization";
    }
    else if (section == 1) {
        name = @"Description";
    }
    else {
        name = @"Synopsis";
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 21)];
    label.textColor = [UIColor whiteColor];
    label.text = name;
    label.backgroundColor = hpoe.hpoeBlue;
    
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        MDHTMLLabel *htmlLabel = [[MDHTMLLabel alloc] init];
        htmlLabel.delegate = self;
        htmlLabel.htmlText = (_item[@"synopsis"] == [NSNull null]) ? @"" : _item[@"synopsis"];
        NSStringDrawingContext *ctx = [NSStringDrawingContext new];

        CGRect textRect = [htmlLabel.htmlText boundingRectWithSize:self.tableView.frame.size
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:htmlLabel.font}
                                                           context:ctx];
        return textRect.size.height + 25;
    }
    else if (indexPath.section == 1) {
        if (_item[@"description"] == [NSNull null]) {
            return 44;
        }
        NSString *txt = _item[@"description"];
        NSStringDrawingContext *ctx = [NSStringDrawingContext new];
        CGRect textRect = [txt boundingRectWithSize:self.tableView.frame.size
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:21]}
                                                           context:ctx];
        return textRect.size.height;
    }
    else {
        return 44;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"  Title";
    }
    else if (section == 99) {
        return @"  Published Date";
    }
    else if (section == 99) {
        return @"  Organization";
    }
    else if (section == 1) {
        return @"  Description";
    }
    else {
        return @"  Synopsis";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    

    if (indexPath.section == 0) {
        cell.textLabel.text = (_item[@"name"] == [NSNull null]) ? @"" : _item[@"name"];
    }
    else if (indexPath.section == 99) {
        cell.textLabel.text = (_item[@"published"] == [NSNull null]) ? @"" : _item[@"published"];
    }
    else if (indexPath.section == 99) {
        cell.textLabel.text = (_item[@"organization"] == [NSNull null]) ? @"" : _item[@"organization"];
    }
    else if (indexPath.section == 1) {
        cell.textLabel.text = (_item[@"description"] == [NSNull null]) ? @"" : _item[@"description"];
        cell.textLabel.numberOfLines = 0;
    }
    else {
        cell.textLabel.text = @"";
        CGRect frame = cell.contentView.bounds;
        frame.origin.x = 10;
        frame.size.width = frame.size.width - 20;
        MDHTMLLabel *htmlLabel = [[MDHTMLLabel alloc] initWithFrame:frame];
        htmlLabel.delegate = self;
        htmlLabel.numberOfLines = 0;
        htmlLabel.shadowColor = [UIColor whiteColor];
        htmlLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        htmlLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        htmlLabel.linkAttributes = @{NSForegroundColorAttributeName: [UIColor blueColor],
                                     NSFontAttributeName: [UIFont boldSystemFontOfSize:htmlLabel.font.pointSize],
                                     NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        
        htmlLabel.activeLinkAttributes = @{NSForegroundColorAttributeName: [UIColor redColor],
                                           NSFontAttributeName: [UIFont boldSystemFontOfSize:htmlLabel.font.pointSize],
                                           NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        NSString *synopsis;
        if (_item[@"synopsis"] != [NSNull null]) {
            synopsis = [_item[@"synopsis"] stringByReplacingOccurrencesOfString:@"-&nbsp;" withString:@""];
            synopsis = [_item[@"synopsis"] stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
        }
        htmlLabel.htmlText = (_item[@"synopsis"] == [NSNull null]) ? @"" : synopsis;
        [cell.contentView addSubview:htmlLabel];
        NSLog(@" synopsis %@", htmlLabel.htmlText);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MDHTMLLabelDelegate methods
- (void)HTMLLabel:(MDHTMLLabel *)label didSelectLinkWithURL:(NSURL *)URL
{
    NSLog(@"Did select link with URL: %@", URL.absoluteString);
}

- (void)HTMLLabel:(MDHTMLLabel *)label didHoldLinkWithURL:(NSURL *)URL
{
    //NSLog(@"Did hold link with URL: %@", URL.absoluteString);
    /*
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Did hold link with URL:"
                                                        message:URL.absoluteString
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
     */
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
