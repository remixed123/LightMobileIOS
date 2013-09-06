//
//  LightData.h
//  LightMobile
//
//  Created by Glenn Vassallo on 6/09/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LightData : NSManagedObject

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * subtype;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * stripecount;
@property (nonatomic, retain) NSString * hexcolor;
@property (nonatomic, retain) NSString * timeseperator;
@property (nonatomic, retain) NSString * subtypedetails;

@end
