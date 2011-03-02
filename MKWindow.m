//
//  MSWindow.m
//  MagicKeyboard
//
//  Created by Michael Nemat on 10-08-15.
//  Copyright (c) 2010 Carleton University. All rights reserved.
//

#import "MKWindow.h"


@implementation MKWindow

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    
    [super dealloc];
}

- (BOOL)canBecomeKeyWindow{
    return NO;
}

- (BOOL)canBecomeMainWindow{
    return NO;
}
-(BOOL) acceptsFirstResponder {
	return NO;
}


@end

