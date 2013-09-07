//
//  SSTeamViewController.h
//  LightMobile
//
//  Created by Glenn Vassallo on 7/09/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SSUtilities.h"
#import "SSConnection.h"


@interface SSTeamViewController : UIViewController <UIPageViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, NSFetchedResultsSectionInfo>
{
    UITableView         *tableView;
    UITableViewCell     *tableViewCell;
    
    SSConnection*   conn;
    SSUtilities*    utils;
    
    IBOutlet UIButton*   addDataButton;
    IBOutlet UISegmentedControl *effectsSegment;
    IBOutlet UISlider           *speedSlider;

}

@property (nonatomic, retain) IBOutlet UITableViewCell *cell;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UISlider *speedSlider;
@property (strong, nonatomic) IBOutlet UILabel    *sequenceText;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, retain) IBOutlet UIButton  *addDataButton;

-(IBAction)done:(id)sender;
-(IBAction)selectEffect:(id)sender;
-(IBAction)adjustSpeed:(id)sender;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)setSortType :(NSString*) sortString;

@end
