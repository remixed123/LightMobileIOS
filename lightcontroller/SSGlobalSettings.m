//
//  SSGlobalSettings.m
//  lightcontroller
//
//  Created by Glenn Vassallo on 31/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import "SSGlobalSettings.h"

@implementation SSGlobalSettings

#import "SSConnection.h"

@synthesize ipAddress;
@synthesize portNumber;


+ (id)sharedManager
{
    static SSConnection *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init
{
    if (self = [super init])
    {
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        
        if ([def objectForKey:@"ipAddress"]==nil)
        {   
            ipAddress = @"";
            portNumber = 8999;
            
            [[NSUserDefaults standardUserDefaults]setObject:ipAddress forKey:@"ipAddress"];
            [[NSUserDefaults standardUserDefaults]setInteger:portNumber forKey:@"portNumber"];
            
            [def synchronize];

        }
        else
        {
            self.ipAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"ipAddress"];
            self.portNumber = [[NSUserDefaults standardUserDefaults] integerForKey:@"portNumber"];
        }
    }
    return self;
}

@end
