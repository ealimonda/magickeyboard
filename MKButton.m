//
//  MKButton.m
//  MagicKeyboard
//
//  Created by Michael Nemat on 10-08-15.
//  Copyright (c) 2010 Carleton University. All rights reserved.
//

#import "MKButton.h"


@implementation MKButton

-(NSString*)getLetter{
    return letter;
}
-(NSString*)getKeycode{
    return keycode;
}
-(bool)containsPoint:(NSPoint)aPoint:(int)circleWidth:(int)circleHeight{
    if ([letter isEqualToString:@"q"]){
     /*  NSLog(letter);
        NSLog(shift);
        NSLog([NSString stringWithFormat:@"%d",xStart]);
        NSLog([NSString stringWithFormat:@"%d",xEnd]);
        NSLog([NSString stringWithFormat:@"%d",yStart]);
        NSLog([NSString stringWithFormat:@"%d",yEnd]);
    */}
    if (aPoint.x >= (xStart - (circleWidth/2)) && (aPoint.x + (circleWidth /2)) <= xEnd && aPoint.y >= (yStart - (circleHeight/2)) && (aPoint.y+(circleHeight/2)) <=yEnd){
        return YES;
    } else {
        return NO;
    }
}
-(MKButton*) initWithXMLData:(NSString*)aLetter:(NSString*)aKeycode:(int)aXStart:(int)aXEnd:(int)aYStart:(int)aYEnd{
    self = [super init];
    if (self){
        letter = aLetter;
        keycode = aKeycode;
        xStart = aXStart;
        xEnd = aXEnd;
        yStart = aYStart;
        yEnd = aYEnd;
    }
    return self;
}
@synthesize xStart;
@synthesize xEnd;
@synthesize yStart;
@synthesize yEnd;
@synthesize keycode;
@synthesize letter;
@end
