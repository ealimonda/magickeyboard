/*******************************************************************************************************************
 *                                     MagicKeyboard :: MKKeyboard                                                 *
 *******************************************************************************************************************
 * File:             MKDevice.h                                                                                    *
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

#import <Foundation/Foundation.h>

#pragma mark Definitions and Constants
#define kMultitouchFingersMax 11
enum DeviceFamilies {
	kDeviceFamilyMBPTrackpad   = 0x00000062,
	kDeviceFamilyMagicMouse    = 0x00000070,
	kDeviceFamilyMagicTrackpad = 0x00000080,
};

#pragma mark Private structures
typedef struct {
	float x, y;
} mtPoint;

typedef struct {
	mtPoint pos, vel;
} mtReadout;

typedef struct {
	int frame;
	double timestamp;
	int identifier, state, foo3, foo4;
	mtReadout normalized;
	float size;
	int zero1;
	float angle, majorAxis, minorAxis; // ellipsoid
	mtReadout mm;
	int zero2[2];
	float unk2;
} Touch;

struct MTDeviceInfo {
	uint32 unk_v0; // C8 B3 76 70  on both Mouse and Trackpad, but changes on other computers (i.e.: C8 23 FC 70)
	uint32 unk_k0; // FF 7F 00 00
	uint32 unk_v1; // 80 0E 01 00, then it changed to 80 10 01 00.  What is this?
	uint32 unk_k1; // 01 00 00 00 - Could be Endianness
	uint32 unk_v2; // 0F 35 00 00, 03 76 00 00, 03 6E 00 00 / 03 37 00 00, 03 77 00 00
	uint32 unk_k2; // 00 00 00 00
	uint32 address; // Last 4 bytes of the device address (or serial number?), as reported by the System Profiler Bluetooth tab
	uint32 unk_v3; // 00 00 00 04, some times 00 00 00 03 - Last byte might be Parser Options?
	// (uint64)address = Multitouch ID
	uint32 family; // Family ID
	uint32 bcdver; // bcdVersion
	uint32 rows; // Sensor Rows
	uint32 cols; // Sensor Columns
	uint32 width; // Sensor Surface Width
	uint32 height; // Sensor Surface Height
	uint32 unk_k3; // 01 00 00 00 - Could be Endianness
	uint32 unk_k4; // 00 00 00 00
	uint32 unk_v4; // 90 04 75 70, 90 74 FA 70
	uint32 unk_k5; // FF 7F 00 00
};

typedef struct MTDeviceInfo MTDeviceInfo;

#pragma mark Interface
@interface MKDevice : NSObject {
	NSUInteger deviceID;
	BOOL enabled;
	struct MTDeviceInfo device;
	int devPtr;
	NSMutableArray *fingers;
}

- (id)initWithMTDeviceRef:(MTDeviceInfo *)dev ID:(NSInteger)devID;

- (id)initSampleDevice;

+ (id)device;
+ (id)deviceWithMTDeviceRef:(MTDeviceInfo *)dev ID:(NSInteger)devID;

+ (id)sampleDevice;

- (NSString *)getInfo;

- (NSString *)deviceType;

- (BOOL)isValid;
- (BOOL)isUsable;

//- (uint32)unk_v0;
- (uint32)unk_k0;
//- (uint32)unk_v1;
- (uint32)unk_k1;
//- (uint32)unk_v2;
- (uint32)unk_k2;
- (uint32)address;
//- (uint32)unk_v3;
- (uint32)family;
//- (uint32)bcdver;
//- (uint32)rows;
//- (uint32)cols;
//- (uint32)width;
//- (uint32)height;
- (uint32)unk_k3;
- (uint32)unk_k4;
//- (uint32)unk_v4;
- (uint32)unk_k5;

@property (assign) NSUInteger deviceID;
@property (assign,getter=isEnabled) BOOL enabled;
@property (retain) NSMutableArray *fingers;
@property (assign,readonly) int devPtr;

@end
