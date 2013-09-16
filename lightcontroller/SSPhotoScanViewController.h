//
//  SSPhotoScanViewController.h
//  LightMobile
//
//  Created by Glenn Vassallo on 15/09/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzCore/QuartzCore.h"
#import "UIColor-Expanded.h"
#import "SSUtilities.h"
#import "SSConnection.h"

@interface SSPhotoScanViewController : UIViewController
{
    __block NSMutableDictionary *colorCodes;
    
    IBOutlet UIImageView *imageView;
    IBOutlet UIView *view;
    
    SSConnection                *conn;
    SSUtilities                 *utils;
}

@property (nonatomic,strong) IBOutlet UIImageView    *imageView;
@property (nonatomic,strong) IBOutlet UIImage        *image;
@property (nonatomic, strong) IBOutlet UIView        *view;

//@property (strong, nonatomic) IBOutlet UIView *colorView;
//@property (strong, nonatomic) IBOutlet UILabel *R;
//@property (strong, nonatomic) IBOutlet UILabel *G;
//@property (strong, nonatomic) IBOutlet UILabel *B;
//@property (strong, nonatomic) IBOutlet UILabel *hexCode;
//@property (strong, nonatomic) IBOutlet UILabel *c;
//@property (strong, nonatomic) IBOutlet UILabel *m;
//@property (strong, nonatomic) IBOutlet UILabel *y;
//@property (strong, nonatomic) IBOutlet UILabel *k;
//@property (strong, nonatomic) IBOutlet UILabel *hsb;


- (IBAction)endPhotoScan:(id)sender;
- (IBAction)effect1:(id)sender;
- (IBAction)effect2:(id)sender;

@end
