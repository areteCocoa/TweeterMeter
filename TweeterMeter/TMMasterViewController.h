//
//  TMMasterViewController.h
//  TweeterMeter
//
//  Created by Thomas Ring on 12/21/13.
//  Copyright (c) 2013 Thomas Ring. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMDetailViewController;

#import <CoreData/CoreData.h>
#import "TMCreateTermViewController.h"

@interface TMMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, TMCreateTermViewControllerDelegate>

@property (strong, nonatomic) TMDetailViewController *detailViewController;
@property (strong, nonatomic) IBOutlet UITableView *masterTableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
