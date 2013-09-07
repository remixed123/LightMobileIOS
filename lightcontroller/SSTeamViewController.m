//
//  SSTeamViewController.m
//  LightMobile
//
//  Created by Glenn Vassallo on 7/09/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import "SSTeamViewController.h"
#import "LightData.h"
#import "SSConnection.h"
#import "SSUtilities.h"
#import <QuartzCore/QuartzCore.h>

@interface SSTeamViewController ()

@end

@implementation SSTeamViewController

@synthesize tableView;
//@synthesize cell;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize fetchedResultsController = _fetchedResultsController;

@synthesize addDataButton;
@synthesize sequenceText;
@synthesize speedSlider;

int sliderSpeedTeam = 500;
NSString *effectTypeTeam = @"0000";
NSString *sortStringValue;
NSString *hexColorTeam;
NSString *stripeCountTeam;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
// Uncomment to create new database
//
//    NSManagedObjectContext *context = [self managedObjectContext];
//    NSManagedObject *lightData = [NSEntityDescription insertNewObjectForEntityForName:@"LightData" inManagedObjectContext:context];
//    [lightData setValue:@"Sports" forKey:@"type"];
//    [lightData setValue:@"PL" forKey:@"subtype"];
//    [lightData setValue:@"Liverpool" forKey:@"name"];
//    [lightData setValue:@"Red and white" forKey:@"colordescription"];
//    [lightData setValue:[NSNumber numberWithInt:2] forKey:@"stripecount"];
//    [lightData setValue:@"FF0000FFFFFF" forKey:@"hexcolor"];
//    [lightData setValue:@"0010" forKey:@"timeseperator"];
//    
//   
//    NSError *error;
//    if (![context save:&error]) {
//        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//    }
    
    //////////////////////////////////////////////
    // UI Configuration
    //////////////////////////////////////////////
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    sequenceText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    sequenceText.layer.borderWidth = 1.5;
    sequenceText.layer.cornerRadius = 8;
    
    //////////////////////////////////////////////
    // Connection Configuration
    //////////////////////////////////////////////
    conn = [[SSConnection alloc] init];
    utils = [[SSUtilities alloc] init];
    
    
    //////////////////////////////////////////////
    // Core Data - NSFetchResults - Loading the results from the database
    //////////////////////////////////////////////
    
    // Clean out any old data from a previous request
    self.fetchedResultsController = nil; // this destroys the old one
    //[self.tableView reloadData];
    
    // Load in new data for this request
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
    //self.title = @"STUFF";
    
    NSLog(@"viewDidLoad");
}

- (void) viewDidUnload
{
    // May need to uncomments to free up memory, but may dependend apon a number of factors
    //self.fetchedResultsController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) adjustSpeed:(UISlider *)sender
{
    sliderSpeedTeam = (int) speedSlider.value;
    
    NSLog(@"adjustSpeed: sliderSpeed: %i",sliderSpeedTeam);
}


-(IBAction)selectEffect:(id)sender
{
	if(effectsSegment.selectedSegmentIndex == 0)
    {
        effectTypeTeam = @"0000";
		sequenceText.text = @"Stationary";
	}
    
	if(effectsSegment.selectedSegmentIndex == 1)
    {
        effectTypeTeam = @"0001";
        sequenceText.text = @"Chase";
	}
    
    if(effectsSegment.selectedSegmentIndex == 2)
    {
        effectTypeTeam = @"0002";
        sequenceText.text = @"Pulse";
	}
    
    if(effectsSegment.selectedSegmentIndex == 3)
    {
        effectTypeTeam = @"0003";
        sequenceText.text = @"Strobe";
	}
    
    [self sendPacket:hexColorTeam :stripeCountTeam];
    
}

-(void)setSortType :(NSString*) sortString
{
    sortStringValue = sortString;
}

//////////  Getting the data from the database

- (NSFetchedResultsController *)fetchedResultsController
{
    
    if (_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }

    NSLog(@"addData-Begin");
    
    NSError *error;
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LightData" inManagedObjectContext:context];
    NSPredicate *predicate;
    if ([sortStringValue isEqualToString:@"Events"] || [sortStringValue isEqualToString:@"Nations"])
    {
        predicate = [NSPredicate predicateWithFormat:@"type like %@", sortStringValue ];
    }
    else
    {
        predicate = [NSPredicate predicateWithFormat:@"subtype like %@", sortStringValue ];
    }
    
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:100];
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *data in fetchedObjects)
    {
        NSLog(@"type: %@: subtype: %@: name: %@: colordescription: %@: stripecount: %@: hexcolor: %@: timeseperatorolor %@", [data valueForKey:@"type"], [data valueForKey:@"subtype"], [data valueForKey:@"name"],[data valueForKey:@"colordescription"], [data valueForKey:@"stripecount"], [data valueForKey:@"hexcolor"], [data valueForKey:@"timeseperator"]);
    }
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    
    [NSFetchedResultsController deleteCacheWithName:@"Root"];  // Delete the cache, as we will reload data dependent on what the user selects on the previous page/controller
    
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    // Need to remove comments when moved to actual delegate...
    return _fetchedResultsController;
    
    if (![context save:&error])
    {
           NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

//////////////  TABLE STUFF
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    id  sectionInfo =
    [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    
    //return 20;
    
    NSLog(@"numberOfRowsInSection: %i",[sectionInfo numberOfObjects]);
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    LightData *data = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = data.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", data.subtype];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    
//    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
//    [cell.detailTextLabel setTextColor:[UIColor blackColor]];
//    
//    cell.textLabel.text = [NSString stringWithFormat:@"c%i",[[self.colorMenu objectAtIndex:indexPath.row] intValue]];
//    
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    return cell;
   
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}


#pragma mark UITableViewDelegate
//- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
//{
//    //int menuNo = [[colorMenu indexOfObject:indexPath.item] intValue]
//    
//    cell.textLabel.text = [NSString stringWithFormat:@"%i",[[self.colorMenu objectAtIndex:indexPath.row] intValue]];
//    cell.detailTextLabel.text = [self.detailMenu objectAtIndex:indexPath.row];
//    
//    if ([[self.cellStatus objectAtIndex:indexPath.row] isEqual: @"no"])
//    {
//        cell.backgroundColor = [UIColor lightGrayColor];
//        cell.detailTextLabel.text = @"not in use";
//    }
//    else if (indexPath.item == selectedIndexReturn)
//    {
//        //cell.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:0.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
//        cell.backgroundColor = [UIColor colorWithRed:redInt/255.f green:greenInt/255.f blue:blueInt/255.f alpha:1];
//        cell.detailTextLabel.text = @"flavour included";
//    }
//    
//    NSLog(@"tableView : willDisplayCell:%@p",indexPath);
//}


// Override to support conditional editing of the table view.
- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return(YES);
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *cellName = cell.textLabel.text;
    NSString *cellSubtype = cell.detailTextLabel.text;
    
    NSError *error;
    NSManagedObjectContext *context = [self managedObjectContext];
    
    //NSManagedObject *failedBankInfo = [NSEntityDescription
    //                                   insertNewObjectForEntityForName:@"LightData"
    //                                   inManagedObjectContext:context];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LightData" inManagedObjectContext:context];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@", cellName ];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
   
    NSString *hexColor = @"FFFFFF";
    NSString *stripeCount = @"1";
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *info in fetchedObjects) {
        NSLog(@"didSelectRowAtIndexPath: hexcolor: %@", [info valueForKey:@"hexcolor"]);
        NSLog(@"didSelectRowAtIndexPath: stripecount: %@", [info valueForKey:@"stripecount"]);
        NSLog(@"didSelectRowAtIndexPath: colordescription: %@", [info valueForKey:@"colordescription"]);
        hexColor = [info valueForKey:@"hexcolor"];
        stripeCount = [info valueForKey:@"stripecount"];
        hexColorTeam = hexColor;
        stripeCountTeam = stripeCount;
    }
    
    NSLog(@"didSelectRowAtIndexPath: row: %i: name: %@: subtype: %@",indexPath.row, cellName, cellSubtype ); //  cell.textLabel.text  );
    
    [self sendPacket:hexColor :stripeCount ];
    
}


-(void)sendPacket :(NSString*) colorHex :(NSString*) stripeCount 
{
    
    int stripeCountInt = [stripeCount intValue];
    
    
    NSString *hexTimeSeperation = [NSString stringWithFormat:@"%@",[utils intToHex2Byte:sliderSpeedTeam]];
    NSString *hexStripeCount = [NSString stringWithFormat:@"%@",[utils intToHex:stripeCountInt]];
    NSString *hexEffectType = effectTypeTeam;
    NSString *payLoad = [NSString stringWithFormat:@"%@%@%@%@",hexEffectType,hexTimeSeperation,hexStripeCount,colorHex];
    
    NSLog(@"sendPacket: hexEffectType: %@, hexTimeSeperation: %@, hexStripeCount: %@, colorHex: %@",hexEffectType,hexTimeSeperation,hexStripeCount,colorHex);
    
    NSString *lwdpPacket = [utils createLwdpPacket:@"20" :payLoad];
    
    NSLog(@"sendPacket: lwdpPacket: %@", lwdpPacket);
    
    [conn sendPacket:lwdpPacket];
}

////////////////// CORE DATA

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SSLightDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"LightData.sqlite"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]])
    {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"LightData" ofType:@"sqlite"]];
        NSError* err = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&err]) {
            NSLog(@"Oops, could copy preloaded data");
        }
    }
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


//////  NSFetchedResults Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    //UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}


@end
