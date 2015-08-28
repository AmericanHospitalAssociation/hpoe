//
//  ArticleTableViewController.m
//  
//
//  Created by Davis, Vincent on 7/7/15.
//
//

#import "ArticleTableViewController.h"
#import "ArticleDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "FontAwesomeKit.h"
#import "HPOEManager.h"

@interface ArticleTableViewController ()
{
    NSArray *list;
}

@end

@implementation ArticleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Bookmarks";
    
    FAKIonIcons *close = [FAKIonIcons iconWithCode:@"\uf406" size:30];
    [close addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[close imageWithSize:CGSizeMake(30, 30)]
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    list = [prefs arrayForKey:@"bookmarks"];
    [self.tableView reloadData];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)randomImage {
    int randNum = rand() % (56 - 1) + 1;
    NSString *imgName = [NSString stringWithFormat:@"hpoe-%d", randNum];
    return [UIImage imageNamed:imgName];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    HPOEManager *hpoe = [HPOEManager sharedInstance];
    NSDictionary *row = list[indexPath.row];
    UILabel *mainLabel = (UILabel *)[cell viewWithTag:200];
    mainLabel.text = row[@"name"];
    UIImageView *iv = (UIImageView *)[cell viewWithTag:100];
    NSString *url = (row[@"image_url"] == [NSNull null]) ? @"" : row[@"image_url"];
    [iv setImageWithURL:[NSURL URLWithString:url]];
    //iv.image = [self randomImage];
    NSString *str = (row[@"description"] == [NSNull null]) ? @"" : row[@"description"];
    UILabel *descLabel = (UILabel *)[cell viewWithTag:300];
    descLabel.text = str;
    NSString *str2 = (row[@"published"] == [NSNull null]) ? @"" : row[@"published"];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:400];
    dateLabel.textColor = hpoe.hpoeRed;
    dateLabel.text = str2;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *row = list[indexPath.row];
    ArticleDetailViewController *vc = (ArticleDetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"articleDetail"];
    vc.item = row;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"delete");
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *temp = [[NSMutableArray alloc] initWithArray:[prefs arrayForKey:@"bookmarks"]];
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [temp removeObjectAtIndex:indexPath.row];
    list = (NSArray *)temp;
    [tableView reloadData];
    [tableView endUpdates];
    [prefs setObject:list forKey:@"bookmarks"];
}


@end
