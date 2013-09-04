//
//  SSSecondViewController.h
//  lightcontroller
//
//  Created by Glenn Vassallo on 24/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSColorWheel.h" 
#import "SSConnection.h"
#import "SSUtilities.h"

@interface SSSingleViewController : UIViewController  <NSStreamDelegate>
{
    SSColorWheel*   _colorWheel;
    SSConnection*   conn;
    SSUtilities*    utils;
    
    UISlider* _brightnessSlider;
    UIView* _wellView;
    
    UIButton* offButton;
    UIButton* allOnButton;
}

@property (strong, nonatomic) IBOutlet UILabel *redValue;
@property (strong, nonatomic) IBOutlet UILabel *greenValue;
@property (strong, nonatomic) IBOutlet UILabel *blueValue;

@property (nonatomic, retain) IBOutlet UIButton         *offButton;
@property (nonatomic, retain) IBOutlet UIButton         *allOnButton;

- (IBAction)off:(id)sender;
- (IBAction)allOn:(id)sender;


@end




