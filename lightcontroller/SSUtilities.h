//
//  SSUtilities.h
//  lightcontroller
//
//  Created by Glenn Vassallo on 30/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SSUtilities : NSObject
{

}

- (NSString*)createHexColorFromIntColors:(int)redInt :(int)greenInt :(int)blueInt;
- (NSString*)colorInHex:(NSString*)redHex :(NSString*)greenHex :(NSString*)blueHex;
- (NSString*)intToHex:(int)intValue;
- (NSString*)intToHex2Byte:(int)intValue;
- (NSString*)createLwdpPacket:(NSString*)packetType :(NSString*)colorHex;
- (NSString*)returnPinNumber;

@end
