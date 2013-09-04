//
//  SSConfigViewController.h
//  lightcontroller
//
//  Created by Glenn Vassallo on 3/09/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSAppDelegate.h"
#import "SSConnection.h"
#import "SSUtilities.h"
#import "GCDAsyncSocket.h"

@interface SSConfigViewController : UIViewController
{
    
    UIButton*                   connectNowButton;

    NSInputStream               *inputStream;
    NSOutputStream              *outputStream;
    GCDAsyncSocket              *asyncSocket;
    
    SSConnection                *conn;
    SSUtilities                 *utils;
}

@property (strong, nonatomic) IBOutlet UILabel     *versionText;

@property (nonatomic, retain) IBOutlet UIButton         *connectNowButton;
@property (strong, nonatomic) IBOutlet UILabel          *statusDescription;

@property (strong, nonatomic) IBOutlet UITextField      *ipAddressText;
@property (strong, nonatomic) IBOutlet UITextField      *portNumberText;

- (IBAction)connectNow:(id)sender;

@end
