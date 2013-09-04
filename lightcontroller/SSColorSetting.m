//
//  SSColorSetting.m
//  lightcontroller
//
//  Created by Glenn Vassallo on 24/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import "SSColorSetting.h"

@implementation SSColorSetting

- (void)setRedAmount:(int)r
{
    redAmount = r;
}

- (void)setGreenAmount:(int)g
{
    greenAmount = g;
}

- (void)setBlueAmount:(int)b
{
    blueAmount = b;
}

- (int)getRedAmount
{
    return redAmount;
}

- (int)getGreenAmount
{
    return greenAmount;
}

- (int)getBlueAmount
{
    return blueAmount;
}


@end
