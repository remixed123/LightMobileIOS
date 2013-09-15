//
//  SSPhotoScanViewController.h
//  LightMobile
//
//  Created by Glenn Vassallo on 15/09/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSPhotoScanViewController : UIViewController
{
    //UIImage* imageView;
}

@property (nonatomic,strong) UIImageView    *imageView;
@property (nonatomic,strong) UIImage        *image;
@property (nonatomic, strong) UIView        *view;

- (IBAction)endPhotoScan:(id)sender;


@end
