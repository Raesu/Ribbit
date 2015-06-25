//
//  FriendsTableViewController.h
//  Ribbit
//
//  Created by Ryan Summe on 6/6/15.
//  Copyright (c) 2015 Ryan Summe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendsViewController : UITableViewController

@property (strong, nonatomic) PFRelation *friendsRelation;
@property (strong, nonatomic) NSArray *friends;

@end
