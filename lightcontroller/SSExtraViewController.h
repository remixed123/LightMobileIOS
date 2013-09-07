//
//  SSTeamViewController.h
//  LightMobile
//
//  Created by Glenn Vassallo on 6/09/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSExtraViewController : UITableViewController

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;





@end
