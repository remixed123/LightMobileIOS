//
//  SSConnection.h
//  lightcontroller
//
//  Created by Glenn Vassallo on 30/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCDAsyncSocket;
@class SSConnection;

@interface SSConnection : NSObject
{
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    GCDAsyncSocket *asyncSocket;
    
    //NSString    *ipAddress;
    //int         portNumber;
}

//@property (nonatomic, retain) NSString* ipAddress;
//@property (nonatomic) int portNumber;


- (void)initNetworkCommunication;
- (void)sendPacket:(NSString*)singlePacket;


@end
