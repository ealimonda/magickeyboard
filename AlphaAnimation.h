/*******************************************************************************************************************
 *                                     MagicKeyboard :: AlphaAnimation                                             *
 *******************************************************************************************************************
 * File:             AlphaAnimation.h                                                                              *
 * Copyright:        (c) 2011 alimonda.com; Emanuele Alimonda                                                      *
 *                   This software is free software: you can redistribute it and/or modify it under the terms of   *
 *                       the GNU General Public License as published by the Free Software Foundation, either       *
 *                       version 3 of the License, or (at your option) any later version.                          *
 *                   This software is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;    *
 *                       without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. *
 *                   See the GNU General Public License for more details.                                          *
 *                   You should have received a copy of the GNU General Public License along with this program.    *
 *                       If not, see <http://www.gnu.org/licenses/>                                                *
 *******************************************************************************************************************/

#import <Cocoa/Cocoa.h>

#pragma mark Constants
extern NSString * const AAFadeIn;
extern NSString * const AAFadeOut;

#pragma mark Interface
@interface AlphaAnimation : NSAnimation {
    NSView          *animatedObject;
    NSString        *effect;
}

#pragma mark Methods
- (id)initWithDuration:(NSTimeInterval)duration effect:(NSString *)effect object:(NSView *)object;

#pragma mark Properties
@property (retain) NSView *animatedObject;
@property (retain) NSString *effect;

@end
