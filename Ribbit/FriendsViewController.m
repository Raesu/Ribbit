//
//  FriendsTableViewController.m
//  Ribbit
//
//  Created by Ryan Summe on 6/6/15.
//  Copyright (c) 2015 Ryan Summe. All rights reserved.
//

#import "FriendsViewController.h"
#import "EditFriendsViewController.h"
#import "GravatarUrlBuilder.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    }

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"];

    
    PFQuery *query = [self.friendsRelation query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            self.friends = objects;
            [self.tableView reloadData];
        }
    }];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.friends count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    PFUser *friend = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = friend.username;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSString *email = [friend objectForKey:@"email"];
        NSURL *gravatarURL = [GravatarUrlBuilder getGravatarUrl:email];
        NSData *imageData = [NSData dataWithContentsOfURL:gravatarURL];
        
        if (imageData != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.image = [UIImage imageWithData:imageData];
                [cell setNeedsLayout];
            });
        }
    });
    
    cell.imageView.image = [UIImage imageNamed:@"icon_person"];
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqual:@"showFriendEdit"]) {
        EditFriendsViewController *nextTVC = (EditFriendsViewController *)[segue destinationViewController];
        nextTVC.friends = [NSMutableArray arrayWithArray:self.friends];
        NSLog(@"Executed");
    }
}


@end
