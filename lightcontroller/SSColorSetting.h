//
//  SSColorSetting.h
//  lightcontroller
//
//  Created by Glenn Vassallo on 24/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SSColorSetting;

@interface SSColorSetting : NSObject
{
    int redAmount;
    int greenAmount;
    int blueAmount;
}

- (void)setRedAmount:(int)r;
- (void)setGreenAmount:(int)g;
- (void)setBlueAmount:(int)b;
- (int)getRedAmount;
- (int)getGreenAmount;
- (int)getBlueAmount;

@end
