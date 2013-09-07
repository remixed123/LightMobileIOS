//
//  SSTabBarViewController.m
//  LightMobile
//
//  Created by Glenn Vassallo on 8/09/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import "SSTabBarViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SSTabBarViewController () <UITabBarControllerDelegate>

@end

@implementation SSTabBarViewController

int tabIndexSelected = 0;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
}


-(void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"didSelectViewController: toIndex: %d",tabBarController.selectedIndex);
    NSLog(@"didSelectViewController: fromIndex: %d",[self.tabBarController.viewControllers indexOfObject:self]);
    
    NSUInteger fromIndex = tabIndexSelected;  //[self.tabBarController.viewControllers indexOfObject:self];
    NSUInteger toIndex = tabBarController.selectedIndex;
    
    [UIView transitionWithView:self.view
                      duration:0.75
                       //options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionTransitionCrossDissolve
                       options: toIndex > fromIndex ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight
                    animations:^(void){
                        [super viewWillAppear:YES];
                    } completion:^(BOOL finished){
                    }];
    tabIndexSelected = tabBarController.selectedIndex;    
}


@end