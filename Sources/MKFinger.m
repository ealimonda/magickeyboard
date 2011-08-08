//
//  MKFinger.m
//  MagicKeyboard
//
//  Created by Syaoran on 2011-08-08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MKFinger.h"

@implementation MKFinger

- (id)init {
	self = [super init];
	if (self) {
		active = NO;
		tapView = nil;
		last = 0L;
	}
	return self;
}

- (void)dealloc {
	[tapView release];
	[super dealloc];
}

+ (id)finger {
	return [[[[self class] alloc] init] autorelease];
}

@synthesize active;
@synthesize tapView;
@synthesize last;

@end
