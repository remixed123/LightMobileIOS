//
//  SSGlobalSettings.h
//  lightcontroller
//
//  Created by Glenn Vassallo on 31/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSConnection.h"

@interface SSGlobalSettings : NSObject
{
    NSString    *ipAddress;
    int         portNumber;
}

@property (nonatomic, retain) NSString* ipAddress;
@property (nonatomic) int portNumber;

+ (id)sharedManager;
- (id)init;

@end
