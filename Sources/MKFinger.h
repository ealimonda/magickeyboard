//
//  MKFinger.h
//  MagicKeyboard
//
//  Created by Syaoran on 2011-08-08.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKFinger : NSObject {
	BOOL active;
	NSImageView *tapView;
	double last;
}

+ (id)finger;

@property (assign,getter=isActive) BOOL active;
@property (retain) NSImageView *tapView;
@property (assign) double last;

@end
