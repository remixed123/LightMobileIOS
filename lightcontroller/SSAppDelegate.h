//
//  SSAppDelegate.h
//  lightcontroller
//
//  Created by Glenn Vassallo on 24/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSConnection.h"
#import "testflight/TestFlight.h"

@class GCDAsyncSocket;
@class SSSpecialViewController;
@class SSConnection;

@interface SSAppDelegate : UIResponder 
{
    UIWindow* _window;
    //UIViewController*     _dataViewController;
    UIViewController        *SSSpecialViewController;
    //UIViewController        *SSAdminViewController;
    SSConnection            *conn;
}

//@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) IBOutlet UIWindow				    *window;
@property (nonatomic, retain) IBOutlet SSSpecialViewController	*mainViewController;

//@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


@end
