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

@interface TMMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) TMDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
