//
//  SSFirstViewController.m
//  lightcontroller
//
//  Created by Glenn Vassallo on 24/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import "SSSequenceViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SSTeamViewController.h"

@interface SSSequenceViewController ()

@end

@implementation SSSequenceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor darkGrayColor];

}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden=NO;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue: %@", segue.identifier);
    
    if ([segue.identifier isEqualToString:@"Events"]) {
        [segue.destinationViewController setSortType:@"Events"];
    } else if ([segue.identifier isEqualToString:@"Nations"]) {
        [segue.destinationViewController setSortType:@"Nations"];
    } else if ([segue.identifier isEqualToString:@"NFL"]) {
        [segue.destinationViewController setSortType:@"NFL"];
    } else if ([segue.identifier isEqualToString:@"MLB"]) {
        [segue.destinationViewController setSortType:@"MLB"];
    } else if ([segue.identifier isEqualToString:@"NBA"]) {
        [segue.destinationViewController setSortType:@"NBA"];
    } else if ([segue.identifier isEqualToString:@"MLS"]) {
        [segue.destinationViewController setSortType:@"MLS"];
    } else if ([segue.identifier isEqualToString:@"NHL"]) {
        [segue.destinationViewController setSortType:@"NHL"];
    } else if ([segue.identifier isEqualToString:@"CFL"]) {
        [segue.destinationViewController setSortType:@"CFL"];
    } else if ([segue.identifier isEqualToString:@"NRL"]) {
        [segue.destinationViewController setSortType:@"NRL"];
    } else if ([segue.identifier isEqualToString:@"AFL"]) {
        [segue.destinationViewController setSortType:@"AFL"];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
