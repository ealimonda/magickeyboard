/*******************************************************************************************************************
 *                                     MagicKeyboard :: MKKeyboard                                                 *
 *******************************************************************************************************************
 * File:             MKDevice.m                                                                                    *
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

#import "MKDevice.h"
#import "MKFinger.h"

#pragma mark Private structures

const MTDeviceInfo multiTouchSampleDevice = {
	0x0,
	0x00007FFF,
	0x0,
	0x00000001,
	0x0,
	0x00000000,
	0x0,
	0x0,
	0x0,
	0x0,
	0x0,
	0x0,
	0x0,
	0x0,
	0x00000001,
	0x00000000,
	0x0,
	0x00007FFF,
};

#pragma mark Implementation
@implementation MKDevice

#pragma mark Initialization
- (id)init {
	self = [super init];
	if (self) {
		deviceID = -1;
		enabled = NO;
		memset(&device, 0, sizeof(device));
		// Initialization code here.
		devPtr = (int)(long)nil;
		fingers = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)initWithMTDeviceRef:(MTDeviceInfo *)dev ID:(NSInteger)devID {
	self = [self init];
	if (self) {
		deviceID = devID;
		memcpy(&device, dev, sizeof(device));
		devPtr = (int)(long)dev;
		for (int i = 0; i < kMultitouchFingersMax; i++) {
			[fingers insertObject:[MKFinger finger] atIndex:i];
		}
	}
	return self;
}

- (id)initSampleDevice {
	self = [self init];
	if (self) {
		memcpy(&device, &multiTouchSampleDevice, sizeof(device));
	}
	return self;
}

- (void)dealloc {
	[fingers release];
	[super dealloc];
}

+ (id)device {
	return [[[[self class] alloc] init] autorelease];
}

+ (id)deviceWithMTDeviceRef:(MTDeviceInfo *)dev ID:(NSInteger)devID {
	return [[[[self class] alloc] initWithMTDeviceRef:dev ID:devID] autorelease];
}

+ (id)sampleDevice {
	return [[[[self class] alloc] initSampleDevice] autorelease];
}

- (NSString *)getInfo {
	return [NSString stringWithFormat:@"MultiTouchDevice: {\n"
		"\t unk_v0 = %08x\n"
		"\t unk_k0 = %08x\n"
		"\t unk_v1 = %08x\n"
		"\t unk_k1 = %08x\n"
		"\t unk_v2 = %08x\n"
		"\t unk_k2 = %08x\n"
		"\taddress= %08x\n"
		"\t unk_v3 = %08x\n"
		"\tfamily = %08x\n"
		"\tbcdver = %08x\n"
		"\trows   = %08x\n"
		"\tcols   = %08x\n"
		"\twidth  = %08x\n"
		"\theight = %08x\n"
		"\t unk_k3 = %08x\n"
		"\t unk_k4 = %08x\n"
		"\t unk_v4 = %08x\n"
		"\t unk_k5 = %08x\n"
		"}",
		device.unk_v0,
		device.unk_k0,
		device.unk_v1,
		device.unk_k1,
		device.unk_v2,
		device.unk_k2,
		device.address,
		device.unk_v3,
		device.family,
		device.bcdver,
		device.rows,
		device.cols,
		device.width,
		device.height,
		device.unk_k3,
		device.unk_k4,
		device.unk_v4,
		device.unk_k5
	];
}

//- (uint32)unk_v0;
- (uint32)unk_k0 {
	return device.unk_k0;
}

//- (uint32)unk_v1;
- (uint32)unk_k1 {
	return device.unk_k1;
}

//- (uint32)unk_v2;
- (uint32)unk_k2 {
	return device.unk_k2;
}

//- (uint32)address;
//- (uint32)unk_v3;
- (uint32)family {
	return device.family;
}

//- (uint32)bcdver;
//- (uint32)rows;
//- (uint32)cols;
//- (uint32)width;
//- (uint32)height;
- (uint32)unk_k3 {
	return device.unk_k3;
}

- (uint32)unk_k4 {
	return device.unk_k4;
}

//- (uint32)unk_v4;
- (uint32)unk_k5 {
	return device.unk_k5;
}


#pragma mark Properties
@synthesize deviceID;
@synthesize enabled;
@synthesize fingers;
@synthesize devPtr;

@end
