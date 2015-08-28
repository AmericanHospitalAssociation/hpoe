//
//  TweetViewController.m
//  
//
//  Created by Davis, Vincent on 7/6/15.
//
//

#import "TweetViewController.h"
#import "FontAwesomeKit.h"
#import "MainViewController.h"

static NSString * const TweetTableReuseIdentifier = @"TweetCell";

@interface TweetViewController ()
<TWTRTweetViewDelegate>

@property (nonatomic, strong) NSArray *tweets; // Hold all the loaded tweets

@end

@implementation TweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"HRETtweets";
    [[Twitter sharedInstance] logInGuestWithCompletion:^(TWTRGuestSession *guestSession, NSError *error) {
        if (guestSession) {
            TWTRAPIClient *APIClient = [[Twitter sharedInstance] APIClient];
            TWTRUserTimelineDataSource *userTimelineDataSource = [[TWTRUserTimelineDataSource alloc] initWithScreenName:@"HRETtweets" APIClient:APIClient];
            self.dataSource = userTimelineDataSource;
        } else {
            NSLog(@"error: %@", [error localizedDescription]);
        }
    }];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        FAKIonIcons *close = [FAKIonIcons iconWithCode:@"\uf130" size:30];
        [close addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[close imageWithSize:CGSizeMake(30, 30)]
                                                                                 style:UIBarButtonItemStyleDone
                                                                                target:self
                                                                                action:@selector(dismiss)];
    }
    else {
        FAKIonIcons *close = [FAKIonIcons iconWithCode:@"\uf406" size:30];
        [close addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[close imageWithSize:CGSizeMake(30, 30)]
                                                                                 style:UIBarButtonItemStyleDone
                                                                                target:self
                                                                                action:@selector(dismiss)];
    }
    
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tweets count];
}

- (TWTRTweetTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweet *tweet = self.tweets[indexPath.row];
    
    TWTRTweetTableViewCell *cell = (TWTRTweetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:TweetTableReuseIdentifier forIndexPath:indexPath];
    [cell configureWithTweet:tweet];
    cell.tweetView.delegate = self;
    
    return cell;
}

// Calculate the height of each row
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TWTRTweet *tweet = self.tweets[indexPath.row];
    
    return [TWTRTweetTableViewCell heightForTweet:tweet width:CGRectGetWidth(self.view.bounds)];
}
@end
