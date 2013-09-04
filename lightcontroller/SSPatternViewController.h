//
//  SSFirstViewController.h
//  lightcontroller
//
//  Created by Glenn Vassallo on 24/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSConnection.h"
#import "SSColorSelectViewController.h"


@interface SSPatternViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSStreamDelegate, SSColorSelectViewControllerDelegate>
{
    UITableView         *tableView;
    UITableViewCell     *tableViewCell;
    
   	IBOutlet UIButton           *sendPacketButton;
    IBOutlet UISegmentedControl *effectsSegment;
    IBOutlet UISlider           *speedSlider;
    
    SSConnection*   conn;
    SSUtilities*    utils;
}

@property (nonatomic, retain) IBOutlet UITableViewCell *cell;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UISlider *speedSlider;

@property (strong, nonatomic) IBOutlet UILabel    *sequenceText;

@property (nonatomic, retain) NSMutableArray *colorMenu;
@property (nonatomic, retain) NSMutableArray *detailMenu;
@property (nonatomic, retain) NSMutableArray *cellStatus;
@property (nonatomic, retain) NSMutableArray *redCellValue;
@property (nonatomic, retain) NSMutableArray *greenCellValue;
@property (nonatomic, retain) NSMutableArray *blueCellValue;

@property(nonatomic) int *redValue;
@property(nonatomic) int *greenValue;
@property(nonatomic) int *blueValue;

-(void)setupArray;

-(IBAction)sendPacket:(id)sender;
-(IBAction)selectEffect:(id)sender;
-(IBAction)adjustSpeed:(id)sender;

@end
