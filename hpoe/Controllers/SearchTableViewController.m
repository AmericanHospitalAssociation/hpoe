//
//  SearchTableViewController.m
//  
//
//  Created by Davis, Vincent on 7/7/15.
//
//

#import "SearchTableViewController.h"
#import "HPOEManager.h"
#import "ArticleDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "FontAwesomeKit.h"

@interface SearchTableViewController ()<UISearchBarDelegate> {
    HPOEManager *hpoe;
    NSArray *list;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;

@end

@implementation SearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Search";
    _searchbar.delegate = self;
    hpoe = [HPOEManager sharedInstance];
    
    FAKIonIcons *close = [FAKIonIcons iconWithCode:@"\uf406" size:30];
    [close addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[close imageWithSize:CGSizeMake(30, 30)]
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(dismiss)];
    [self registerForKeyboardNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIToolbar *)dismissBar {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                          target:self
                                                                          action:@selector(dismissKeyboard:)];
    [toolbar setItems:@[done] animated:YES];
    
    return toolbar;
}

- (void)dismissKeyboard:(id)sender {
    [_searchbar resignFirstResponder];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

#pragma mark Keyboard Notifications
- (void)keyboardWasShown:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    //_message.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
    //_message.scrollIndicatorInsets = _message.contentInset;
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    //_message.contentInset = UIEdgeInsetsZero;
    //_message.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"description contains[cd] %@ OR name contains[cd] %@ OR synopsis contains[cd] %@ OR organization contains[cd] %@ OR keywords contains[cd] %@", searchText, searchText, searchText, searchText, searchText];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"published" ascending:NO];
    list = [[hpoe.resources filteredArrayUsingPredicate:pred] sortedArrayUsingDescriptors:@[sortDescriptor]];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDictionary *row = list[indexPath.row];
    UILabel *mainLabel = (UILabel *)[cell viewWithTag:200];
    mainLabel.text = row[@"name"];
    NSString *str = (row[@"description"] == [NSNull null]) ? @"" : row[@"description"];
    UILabel *descLabel = (UILabel *)[cell viewWithTag:300];
    descLabel.text = str;
    NSString *str2 = (row[@"published"] == [NSNull null]) ? @"" : row[@"published"];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:400];
    dateLabel.textColor = hpoe.hpoeRed;
    dateLabel.text = str2;
    //UIImageView *iv = (UIImageView *)[cell viewWithTag:100];
    //NSString *url = (row[@"image_url"] == [NSNull null]) ? @"" : row[@"image_url"];
    //[iv setImageWithURL:[NSURL URLWithString:url]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *row = list[indexPath.row];
    ArticleDetailViewController *vc = (ArticleDetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"articleDetail"];
    vc.item = row;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
