//
//  SSColorWheel.h
//  dmxcolorselect
//
//  Created by Glenn Vassallo on 24/08/13.
//  Copyright (c) 2013 Swift Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SSColorSetting.h"

@class SSColorWheel;

@protocol SSColorWheelDelegate <NSObject>
@required
- (void)colorWheelDidChangeColor:(SSColorWheel*)colorWheel;
@end


@interface SSColorWheel : UIView
{
    UIImage* _radialImage;
    float _radius;
    float _cursorRadius;
    CGPoint _touchPoint;
    float _brightness;
    bool _continuous;
    id <SSColorWheelDelegate> __unsafe_unretained delegate;
    //SSColorSetting* _colorAmount;
}

@property(nonatomic, assign)float radius;
@property(nonatomic, assign)float cursorRadius;
@property(nonatomic, assign)float brightness;
@property(nonatomic, assign)bool continuous;
@property(unsafe_unretained)id <SSColorWheelDelegate> delegate;
//@property(nonatomic, retain)SSColorSetting* _colorAmount;


- (void)updateImage;
- (UIColor*)currentColor;
- (float)redValue;
- (float)greenValue;
- (float)blueValue;
- (void)setCurrentColor:(UIColor*)color;

- (void)setTouchPoint:(CGPoint)point;

@end