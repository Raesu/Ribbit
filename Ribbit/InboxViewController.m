//
//  InboxTableViewController.m
//  Ribbit
//
//  Created by Ryan Summe on 6/6/15.
//  Copyright (c) 2015 Ryan Summe. All rights reserved.
//

#import "InboxViewController.h"
#import "LogInViewController.h"
#import "ImageViewController.h"

@interface InboxViewController ()

@end

@implementation InboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.moviePlayer = [[MPMoviePlayerController alloc] init];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    
    if ([PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:@"Message"];
        [query whereKey:@"recipientIds" equalTo:[[PFUser currentUser] objectId]];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (error) {
                NSLog(@"%@", error);
            } else {
                self.messages = objects;
                [self.tableView reloadData];
            }
        }];
    } else {
        [self performSegueWithIdentifier:@"showLogIn" sender:self];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messages count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *message = [self.messages objectAtIndex:indexPath.row];
    cell.textLabel.text = [message objectForKey:@"senderName"];
    
    NSString *fileType = [message objectForKey:@"fileType"];
    if ([fileType isEqualToString:@"image"]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_image"];
    } else cell.imageView.image = [UIImage imageNamed:@"icon_video"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedMessage = [self.messages objectAtIndex:indexPath.row];
    
    NSString *fileType = [self.selectedMessage objectForKey:@"fileType"];
    if ([fileType isEqualToString:@"image"]) {
        [self performSegueWithIdentifier:@"showImage" sender:self];
    } else {
        PFFile *videoFile = [self.selectedMessage objectForKey:@"file"];
        NSURL *fileURL = [NSURL URLWithString:[videoFile url]];
        self.moviePlayer.contentURL = fileURL;
        [self.moviePlayer prepareToPlay];
        
        // deprecated :(
        // [self.moviePlayer thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:YES];
    }
    
    NSMutableArray *recipientIds = [NSMutableArray arrayWithArray:[self.selectedMessage objectForKey:@"recipientIds"]];
    
    if ([recipientIds count] == 1) {
        [self.selectedMessage deleteInBackground];
    } else {
        [recipientIds removeObject:[[PFUser currentUser] objectId]];
        [self.selectedMessage setObject:recipientIds forKey:@"recipientIds"];
        [self.selectedMessage deleteInBackground];
    }
    
}

- (IBAction)logOut:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogIn" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"showLogIn"]) {
        LogInViewController *lVC = (LogInViewController *)[segue destinationViewController];
        [lVC setHidesBottomBarWhenPushed:YES];
        // [[lVC navigationItem] setHidesBackButton:YES animated:NO];
    } else if ([segue.identifier isEqualToString:@"showImage"]) {
        ImageViewController *iVC = (ImageViewController *)[segue destinationViewController];
        [iVC setHidesBottomBarWhenPushed:YES];
        [iVC setMessage:self.selectedMessage];
    }
}

@end
