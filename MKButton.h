//
//  MKButton.h
//  MagicKeyboard
//
//  Created by Michael Nemat on 10-08-15.
//  Copyright (c) 2010 Carleton University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MKButton : NSObject {
    int xStart;
    int xEnd;
    int yStart;
    int yEnd;
    NSString* keycode;
    NSString* letter;
}
-(MKButton*) initWithXMLData:(NSString*)aLetter:(NSString*)aShift:(int)aXStart:(int)aXEnd:(int)aYStart:(int)aYEnd;

-(NSString*)getLetter;
-(NSString*)getKeycode;
-(bool)containsPoint:(NSPoint)aPoint:(int)circleWidth:(int)circleHeight;

@property int xStart;
@property int xEnd;
@property int yStart;
@property int yEnd;
@property (retain,getter=getKeycode) NSString* keycode;
@property (retain,getter=getLetter) NSString* letter;
@end
