//
//  SSConnection.m
//  lightcontroller
//
//  Created by Glenn Vassallo on 30/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import "SSConnection.h"
#import "GCDAsyncSocket.h"
#import "SSSpecialViewController.h"
#import "SSGlobalSettings.h"

//#define HOST @"192.168.1.10";
//#define PORT 8999

@implementation SSConnection



- (void)initNetworkCommunication {
    
    SSGlobalSettings *connSettings = [SSGlobalSettings sharedManager];
    NSString *ipAddress = connSettings.ipAddress;
    int portNumber = connSettings.portNumber;
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ipAddress, portNumber, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    
    NSLog(@"initNetworkCommunication: %@:%i", ipAddress,portNumber);
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
}


- (void)sendPacket:(NSString*)singlePacket
{
    
    SSGlobalSettings *connSettings = [SSGlobalSettings sharedManager];
    NSString *ipAddress = connSettings.ipAddress;
    int portNumber = connSettings.portNumber;
    
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
    //NSString *ipAddress = [self ipAddress];
    
    NSError *err = nil;
    if (![asyncSocket connectToHost:ipAddress onPort:portNumber error:&err]) // Asynchronous!
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"sendPacket: %@", err);
    }
    else
    {
        NSLog(@"sendPacket:Connected");
    }

    
    NSString *requestStr = [NSString stringWithFormat:@"%@",singlePacket];
    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [asyncSocket writeData:requestData withTimeout:-1 tag:1];
    [asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
    
    NSLog(@"sendPacket: singlePacket: %@",singlePacket);
}


@end
