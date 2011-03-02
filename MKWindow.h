//
//  MSWindow.h
//  MagicKeyboard
//
//  Created by Michael Nemat on 10-08-15.
//  Copyright (c) 2010 Carleton University. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MKWindow : NSWindow {
@private
    
}
- (BOOL)canBecomeMainWindow;
- (BOOL)canBecomeKeyWindow;
@end
