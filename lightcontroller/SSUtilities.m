//
//  SSUtilities.m
//  lightcontroller
//
//  Created by Glenn Vassallo on 30/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import "SSUtilities.h"

@implementation SSUtilities


- (NSString*)createHexColorFromIntColors:(int)redInt :(int)greenInt :(int)blueInt
{

    NSString *redHex;
    NSString *greenHex;
    NSString *blueHex;
    
    redHex = [self intToHex:redInt];
    greenHex = [self intToHex:greenInt];
    blueHex = [self intToHex:blueInt];
    
    NSLog(@"createHexColorFromIntColors: redHex: %@, greenHex: %@, blueHex: %@", redHex, greenHex, blueHex);
    
    return [self colorInHex:redHex :greenHex :blueHex];
    
}

- (NSString*)colorInHex:(NSString*)redHex :(NSString*)greenHex :(NSString*)blueHex;
{
    return [NSString stringWithFormat:@"%@%@%@", redHex, greenHex, blueHex];
    
}

- (NSString*)intToHex :(int)intValue
{
    NSString *hexString;
    
    if (intValue < 16)
    {
        hexString = [NSString stringWithFormat:@"0%X",intValue];
    }
    else
    {
        hexString = [NSString stringWithFormat:@"%X", intValue];
    }
    
    return hexString;
}

- (NSString*)intToHex2Byte:(int)intValue
{
    NSString *hexString;
    
    if (intValue < 16)
    {
        hexString = [NSString stringWithFormat:@"000%X",intValue];
    }
    else if (intValue < 256)
    {
        hexString = [NSString stringWithFormat:@"00%X",intValue];
    }
    else if (intValue < 4096)
    {
        hexString = [NSString stringWithFormat:@"0%X",intValue];
    }
    else
    {
        hexString = [NSString stringWithFormat:@"%X", intValue];
    }
    
    return hexString;
}


- (NSString*)createLwdpPacket:(NSString*)groupType :(NSString*)payLoad
{
    return [NSString stringWithFormat:@"%@%@%@%@%@",@"45", self.returnPinNumber, self.returnUniverse, groupType, payLoad];

}

- (NSString*)returnPinNumber
{
    return @"0000";  //this will need to be updated to read the pin number set via the gui and saved in NSDefaults
}

- (NSString*)returnUniverse
{
    return @"01"; //universe not implimented yet, this is here to provide future support.
}


@end
