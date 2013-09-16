//
//  SSFirstViewController.m
//  lightcontroller
//
//  Created by Glenn Vassallo on 24/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import "SSPatternViewController.h"
#import "SSColorSelectViewController.h"
#import "SSConnection.h"
#import "SSUtilities.h"
#import <QuartzCore/QuartzCore.h>
#import "testflight/TestFlight.h"

@interface SSPatternViewController ()

@end

@implementation SSPatternViewController

@synthesize colorMenu;
@synthesize sequenceText;
@synthesize tableView;
@synthesize speedSlider;

int redInt;
int greenInt;
int blueInt;
int selectedIndexReturn;

NSString *effectType = @"0000";
int sliderSpeed = 500;


-(void)setupArray
{
    int rowCount = 5;
    
    self.colorMenu = [[NSMutableArray alloc] initWithCapacity:rowCount];
    self.detailMenu = [[NSMutableArray alloc] initWithCapacity:rowCount];
    self.cellStatus = [[NSMutableArray alloc] initWithCapacity:rowCount];
    self.redCellValue = [[NSMutableArray alloc] initWithCapacity:rowCount];
    self.greenCellValue = [[NSMutableArray alloc] initWithCapacity:rowCount];
    self.blueCellValue = [[NSMutableArray alloc] initWithCapacity:rowCount];
    
    NSNumber *stripeNumber;
    //NSNumber *indexNumber;
    NSNumber *redCellValueNumber = [NSNumber numberWithInt:255];
    NSNumber *greenCellValueNumber = [NSNumber numberWithInt:255];
    NSNumber *blueCellValueNumber = [NSNumber numberWithInt:255];
    
    for (int i = 0 ; i < rowCount ; i++ )
    {
        stripeNumber = [NSNumber numberWithInt:i + 1];
               
        [self.colorMenu addObject:stripeNumber];
        [self.detailMenu addObject:@"not in use"];
        [self.cellStatus addObject:@"no"];
        [self.redCellValue addObject:redCellValueNumber];
        [self.greenCellValue addObject:greenCellValueNumber];
        [self.blueCellValue addObject:blueCellValueNumber];
        
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
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

    ///////////////////////////////////////
    conn = [[SSConnection alloc] init];
    utils = [[SSUtilities alloc] init];
    
    
    //////////////////////////////////////////////
    // Setup Array
    //////////////////////////////////////////////
    
    [self setupArray];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
    
    self.tabBarController.tabBar.hidden=NO;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue: %@", segue.identifier);
    
    // get the selected index
    NSInteger selectedIndex; // = [[self.tableView indexPathForSelectedRow] row];
    
    if ([[segue identifier] isEqualToString:@"colorSelectSegue"])
    {
        SSColorSelectViewController *colorSelectorViewController = segue.destinationViewController;
        colorSelectorViewController.delegate = self;
        colorSelectorViewController.redInt = redInt;
        colorSelectorViewController.greenInt = greenInt;
        colorSelectorViewController.blueInt = blueInt;

        selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        [segue.destinationViewController setForwardValues:redInt :greenInt :blueInt :selectedIndex];
        
        NSLog(@"prepareForSegue: selectedIndex: %i",selectedIndex);

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)selectEffect:(id)sender
{
	if(effectsSegment.selectedSegmentIndex == 0)
    {
        effectType = @"0000";
		sequenceText.text = @"Stationary";    
	}
    
	if(effectsSegment.selectedSegmentIndex == 1)
    {
        effectType = @"0001";
        sequenceText.text = @"Chase";
	}
    
    if(effectsSegment.selectedSegmentIndex == 2)
    {
        effectType = @"0002";
        sequenceText.text = @"Pulse";
	}
    
    if(effectsSegment.selectedSegmentIndex == 3)
    {
        effectType = @"0003";
        sequenceText.text = @"Strobe";
	}
    
}

//-(IBAction)adjustSpeed:(id)sender
//{
//    
//    
//}


- (IBAction) adjustSpeed:(UISlider *)sender
{
    sliderSpeed = (int) speedSlider.value;
    
    NSLog(@"adjustSpeed: sliderSpeed: %i",sliderSpeed);
}

-(IBAction)sendPacket:(id)sender
{
    [TestFlight passCheckpoint:@"CANDY_CANE_SENDPACKET_CP1"];
    
    NSString *colorHex = @"";
    
    int stripeCount = 0;
    
    for (int i = 0; i < 5; i++)
    {
        if ([[self.cellStatus objectAtIndex:i] isEqual: @"yes"])
        {
            colorHex = [NSString stringWithFormat:@"%@%@",colorHex,[utils createHexColorFromIntColors:[[self.redCellValue objectAtIndex:i] intValue]
                                                         :[[self.greenCellValue objectAtIndex:i] intValue]
                                                         :[[self.blueCellValue objectAtIndex:i] intValue]]];
            stripeCount = stripeCount + 1;
        }
    }

    NSString *hexTimeSeperation = [NSString stringWithFormat:@"%@",[utils intToHex2Byte:sliderSpeed]];
    NSString *hexStripeCount = [NSString stringWithFormat:@"%@",[utils intToHex:stripeCount]];
    NSString *hexEffectType = effectType;
    
    NSString *payLoad = [NSString stringWithFormat:@"%@%@%@%@",hexEffectType,hexTimeSeperation,hexStripeCount,colorHex];
    
    NSLog(@"sendPacket: hexEffectType: %@, hexTimeSeperation: %@, hexStripeCount: %@, colorHex: %@",hexEffectType,hexTimeSeperation,hexStripeCount,colorHex);
    
    NSString *lwdpPacket = [utils createLwdpPacket:@"20" :payLoad];
    
    NSLog(@"sendPacket: lwdpPacket: %@", lwdpPacket);
    
    [conn sendPacket:lwdpPacket];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5; //[self.colorMenu count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
        
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    [cell.detailTextLabel setTextColor:[UIColor blackColor]];
    
    cell.textLabel.text = [NSString stringWithFormat:@"c%i",[[self.colorMenu objectAtIndex:indexPath.row] intValue]];

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath
{
    //int menuNo = [[colorMenu indexOfObject:indexPath.item] intValue]

    cell.textLabel.text = [NSString stringWithFormat:@"%i",[[self.colorMenu objectAtIndex:indexPath.row] intValue]];
    cell.detailTextLabel.text = [self.detailMenu objectAtIndex:indexPath.row];
    
    if ([[self.cellStatus objectAtIndex:indexPath.row] isEqual: @"no"])
    {
        cell.backgroundColor = [UIColor lightGrayColor];
        cell.detailTextLabel.text = @"not in use";
    }
    else if (indexPath.item == selectedIndexReturn)
    {
        //cell.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:0.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        cell.backgroundColor = [UIColor colorWithRed:redInt/255.f green:greenInt/255.f blue:blueInt/255.f alpha:1];
        cell.detailTextLabel.text = @"flavour included";
    }
    
    NSLog(@"tableView : willDisplayCell:%@p",indexPath);
}


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
}


- (void)colorSelectViewController:(SSColorSelectViewController *)controller setupCellColor:(int)redIntv :(int)greenIntv :(int)blueIntv :(int)selectedIndexReturnv
{
	redInt = redIntv;
    greenInt = greenIntv;
    blueInt = blueIntv;
    selectedIndexReturn = selectedIndexReturnv;
	[self.navigationController popViewControllerAnimated:YES];
    
    [self.detailMenu replaceObjectAtIndex:selectedIndexReturn withObject:@"flavour included"];
    [self.cellStatus replaceObjectAtIndex:selectedIndexReturn withObject:@"yes"];
    [self.redCellValue replaceObjectAtIndex:selectedIndexReturn withObject:[NSNumber numberWithInt:redInt]];
    [self.greenCellValue replaceObjectAtIndex:selectedIndexReturn withObject:[NSNumber numberWithInt:greenInt]];
    [self.blueCellValue replaceObjectAtIndex:selectedIndexReturn withObject:[NSNumber numberWithInt:blueInt]];
    
    [tableView reloadData];
    
    NSLog(@"colorSelectViewController: setupCellColor: %i:%i:%i:%i",redInt,greenInt,blueInt,selectedIndexReturn);
}

- (void)colorSelectViewController:(SSColorSelectViewController *)controller removeCellColor:(int)selectedIndexReturnv
{
    selectedIndexReturn = selectedIndexReturnv;
	[self.navigationController popViewControllerAnimated:YES];
    
    [self.detailMenu replaceObjectAtIndex:selectedIndexReturn withObject:@"not in use"];
    [self.cellStatus replaceObjectAtIndex:selectedIndexReturn withObject:@"no"];
    
    [tableView reloadData];
    
    NSLog(@"colorSelectViewController: removeCellColor: %i",selectedIndexReturn);
}



@end
