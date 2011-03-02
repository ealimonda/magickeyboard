//
//  msView.m
//  MagicKeyboard
//
//  Created by Michael Nemat on 10-08-14.
//  Copyright 2010 Carleton University. All rights reserved.
//

#import "msView.h"
#import "AlphaAnimation.h"
id refToSelf;
dispatch_queue_t myQueue;


@implementation msView

typedef struct { float x,y; } mtPoint;
typedef struct { mtPoint pos,vel; } mtReadout;

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
} Finger;

typedef void *MTDeviceRef;
typedef int (*MTContactCallbackFunction)(int,Finger*,int,double,int);

MTDeviceRef MTDeviceCreateDefault();
void MTRegisterContactFrameCallback(MTDeviceRef, MTContactCallbackFunction);
void MTDeviceStart(MTDeviceRef, int); // thanks comex
CFMutableArrayRef MTDeviceCreateList(void); //returns a CFMutableArrayRef array of all multitouch devices


int callback(int device, Finger *data, int nFingers, double timestamp, int frame) {
   /* 
	for (int i=0; i<nFingers; i++) {
        Finger *f = &data[i];
        
    }*/
    
    if (nFingers == 1){
        Finger *f = &data[0];
        [refToSelf processTouch:f];
        
    }
    return 0;
}
- (void)resizeWindowOnSpotWithRect:(NSRect)aRect
{
    NSRect r = NSMakeRect([self frame].origin.x - 
						  (aRect.size.width - [self frame].size.width), [self frame].origin.y - 
						  (aRect.size.height - [self frame].size.height), aRect.size.width, aRect.size.height);
    [window setFrame:r display:YES animate:YES];
}
-(IBAction)fullNumSelector:(id)sender{
	if (![sender state]){
		[selQwerty setState:0];
		[selFullNum setState:1];
		[self writePrefs:@"layout" :@"fullnum"];
		[self resizeWindowOnSpotWithRect:NSMakeRect(0,0,480,360)];
		[keyboardImage setImage:fullNumLayout];
		currentLayout = fullNumLayout;
		[currentButtons removeAllObjects];
		[self getButtonsForXMLFile:@"ifullnum"];
	}
}
-(IBAction)halfQwertySelector:(id)sender{
	if (![sender state]){
		[selQwerty setState:1];
		[selFullNum setState:0];
		[self writePrefs:@"layout" :@"qwerty"];
		[keyboardImage setImage:qwertyLayout];
		currentLayout = qwertyLayout;
		[currentButtons removeAllObjects];
		[self getButtonsForXMLFile:@"iqwerty"];
	}
}

-(void)processTouch:(Finger*)f{
    if (f->state == 7 && doTracking){
        /*NSLog([NSString stringWithFormat:@"Frame %7d: Angle %6.2f, ellipse %6.3f x%6.3f; "
         "position (%6.3f,%6.3f) vel (%6.3f,%6.3f) "
         "ID %d, state %d [%d %d?] size %6.3f, %6.3f?\n",
         f->frame,
         f->angle * 90 / atan2(1,0),
         f->majorAxis,
         f->minorAxis,
         f->normalized.pos.x,
         f->normalized.pos.y,
         f->normalized.vel.x,
         f->normalized.vel.y,
         f->identifier, f->state, f->foo3, f->foo4,
         f->size, f->unk2]);*/
        NSRect imgBox;
        NSPoint aPoint = NSMakePoint(((mtW*(f->normalized.pos.x))*1.25),(mtH*( f->normalized.pos.y))*1.10);
        imgBox.origin.x = aPoint.x;
        imgBox.origin.y = aPoint.y;
        //NSLog([NSString stringWithFormat:@"%f",aPoint.x]);
        //NSLog([NSString stringWithFormat:@"%f",aPoint.y]);
        imgBox.size.width=33;
        imgBox.size.height=34;
        for (int i = 0; i < [currentButtons count] ; i++){
			MKButton* button = [currentButtons objectAtIndex:i];
			if ([button containsPoint:aPoint :33 :34]){
				//NSLog([button getLetter]);
				bool noSend = false;
				int keycode = 0;
				if ([[button getLetter]isEqualToString:@"NUMS"]){
					[keyboardImage setImage:numbersLayout];
					currentLayout = numbersLayout;
					[currentButtons removeAllObjects];
					[self getButtonsForXMLFile:@"inums"];
					noSend = true;
				} else if ([[button getLetter]isEqualToString:@"QWERTY"]){
					[keyboardImage setImage:qwertyLayout];
					currentLayout = qwertyLayout;
					[currentButtons removeAllObjects];
					[self getButtonsForXMLFile:@"iqwerty"];
					noSend = true;
				} else if ([[button getLetter] isEqualToString:@"SYMS"]){
					[keyboardImage setImage:symsLayout];
					currentLayout = symsLayout;
					[currentButtons removeAllObjects];
					[self getButtonsForXMLFile:@"isyms"];
					noSend=true;
				} else if ([[button getLetter] isEqualToString:@"MODIFIERS"]){
					[keyboardImage setImage:modsLayout];
					currentLayout = modsLayout;
					[currentButtons removeAllObjects];
					[self getButtonsForXMLFile:@"imods"];
					noSend=true;
				}else {
					if (currentLayout == qwertyLayout) {
						if ([[button getLetter] isEqualToString:@"SHIFT"]){
							shift = !shift;
							[shiftChk setState:shift];
							noSend = true;
							lastKeyWasNotModifier = false;
						} else {
							keycode = (CGKeyCode)[[button getKeycode] integerValue];
							lastKeyWasNotModifier = true;
						}
					} else if (currentLayout == numbersLayout || currentLayout == symsLayout || currentLayout == modsLayout){
						if ([[button getLetter] isEqualToString:@"CTL"]){
							ctl = !ctl;
							[ctlChk setState:ctl];
							noSend = true;
							lastKeyWasNotModifier = false;
						} else if ([[button getLetter] isEqualToString:@"ALT"]){
							alt = !alt;
							noSend = true;
							[altChk setState:alt];
							lastKeyWasNotModifier = false;
						} else if ([[button getLetter] isEqualToString:@"CMD"]){
							cmd = !cmd;
							[cmdChk setState:cmd];
							noSend=true;
							lastKeyWasNotModifier = false;
						} else {
							lastKeyWasNotModifier=true;
						}
						if (!ctl && !cmd && !alt){
							lastKeyWasNotModifier = true;
						}
						if ([[button getKeycode] characterAtIndex:0] == 'S'){ 
							keycode = (CGKeyCode)[[[button getKeycode] stringByReplacingOccurrencesOfString:@"S" withString:@""] integerValue];
							keycode = keycode + 300;
					   } else {
							keycode = (CGKeyCode)[[button getKeycode] integerValue];
						}
					}
				}
				if (!noSend){
					[self sendKeycode:keycode];
				}
				NSImageView* imageView = [[NSImageView alloc] initWithFrame:imgBox];
				[self addSubview:imageView];
				[imageView setImage:tap];
				[imageView retain];
				NSSound* sound = [NSSound soundNamed:@"Tock"];
				[sound play];
				dispatch_async(myQueue, ^{
					[self animateImage:imageView];
				});
				if (lastKeyWasNotModifier == true){
					cmd = false;
					[cmdChk setState:0];
					alt = false;
					[altChk setState:0];
					ctl = false;
					[ctlChk setState:0];
				}
				break;
			}
		}
	}
}
-(void)sendKeycode:(CGKeyCode)keycode{
	bool needsShift = keycode >= 300;
	long flags = 0;
	if (needsShift){
		keycode = keycode - 300;
	}
	if (shift || needsShift){
		flags |= kCGEventFlagMaskShift;
	}	
	if (cmd){
		flags |= kCGEventFlagMaskCommand;
	}
	if (alt){
		flags |= kCGEventFlagMaskAlternate;
	}
	if (ctl){
		flags |= kCGEventFlagMaskControl;
	}
	//NSLog([NSString stringWithFormat:@"%d",keycode]);
	CGEventRef event1, event2;
	event1 = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)keycode, true);//'z' keydown event
	event2 = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)keycode, false);
	if (flags > 0){
		CGEventSetFlags(event1, flags);//set shift key down for above event
		CGEventSetFlags(event2, flags);//set shift key down for above event
	} else {
		CGEventSetFlags(event1, 0);//set shift key down for above event
		CGEventSetFlags(event2, 0);//set shift key down for above event
	}
	CGEventPost(kCGHIDEventTap, event1);//post event
	CFRelease(event1);
	usleep(50);
	CGEventPost(kCGHIDEventTap, event2);//post event
	CFRelease(event2);
	usleep(50);
	if (shift || needsShift){
		CGEventRef shiftUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)56, false);//'z' keydown event
		CGEventPost(kCGHIDEventTap, shiftUp);//post event
		CFRelease(shiftUp);
		usleep(50);
	}
	if (cmd){
		CGEventRef cmdUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)55, false);//'z' keydown event
		CGEventPost(kCGHIDEventTap, cmdUp);//post event
		CFRelease(cmdUp);
		usleep(50);
	}
	if (alt){
		CGEventRef altUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)58, false);//'z' keydown event
		CGEventPost(kCGHIDEventTap, altUp);//post event
		CFRelease(altUp);
		usleep(50);
	}
	if (ctl){
		CGEventRef ctlUp = CGEventCreateKeyboardEvent(NULL, (CGKeyCode)59, false);//'z' keydown event
		CGEventPost(kCGHIDEventTap, ctlUp);//post event
		CFRelease(ctlUp);
		usleep(50);
	}
}
-(void)animateImage:(NSImageView*)image{
	AlphaAnimation* animation = [[AlphaAnimation alloc] initWithDuration:0.3 effect:AAFadeOut object:image];
	[animation setAnimationBlockingMode:NSAnimationBlocking];
	[animation startAnimation];
	[image release];
	[animation release];
}
- (id)initWithFrame:(NSRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		NSMutableArray* deviceList = (NSMutableArray*)MTDeviceCreateList(); //grab our device list
		
		for(int i = 0; i<[deviceList count]; i++) //iterate available devices
		{
			MTRegisterContactFrameCallback([deviceList objectAtIndex:i], callback); //assign callback for device
			MTDeviceStart([deviceList objectAtIndex:i], 0); //start sending events
		}
		
		[self setAcceptsTouchEvents:NO];
		NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self frame]
																	options:NSTrackingMouseMoved+NSTrackingActiveInKeyWindow
																	  owner:self
																   userInfo:nil];
		[self addTrackingArea:trackingArea];
		[self becomeFirstResponder];
		tap = [NSImage imageNamed:@"s.png"];
		qwertyLayout = [NSImage imageNamed:@"12.png"];
		numbersLayout = [NSImage imageNamed:@"13.png"];
		symsLayout = [NSImage imageNamed:@"14.png"];
		modsLayout = [NSImage imageNamed:@"15.png"];
		fullNumLayout = [NSImage imageNamed:@"16.png"];
		mtH=311;
		doTracking = true;
		cmd = false;
		alt = false;
		ctl = false;
		lastKeyWasNotModifier = true;
		mtW=368;
		currentButtons = [[NSMutableArray alloc]init];
		[self getButtonsForXMLFile:@"iqwerty"];
		currentLayout = qwertyLayout;
		refToSelf = self;
		NSLog(@"INIT");
		shift = NO;
		myQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
		//MTDeviceRef dev = MTDeviceCreateDefault(1);
		//MTRegisterContactFrameCallback(dev, callback);
		//MTDeviceStart(dev, 0);

		// if the file was there, we got all the informati
		if (prefs == nil){
			prefs = [NSDictionary dictionaryWithContentsOfFile: 
					 [@"~/Library/Preferences/com.magickeyboard.plist" 
					  stringByExpandingTildeInPath]];
			if (prefs){
				NSString* layout = [prefs objectForKey:@"layout"];
				[selQwerty setState:0];
				[selFullNum setState:0];
				if ([layout isEqualToString:@"qwerty"]){
					[self halfQwertySelector:selQwerty];
				} else if ([layout isEqualToString:@"fullnum"]){
					[self fullNumSelector:selFullNum];
				}
			} else {
				prefs = [[NSMutableDictionary alloc] init];
				[self writePrefs:@"layout":@"qwerty"];
			}
			[prefs retain];
		}
	}
	return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict{
	if ([elementName isEqualToString:@"button"]){
		NSString* letter = [attributeDict valueForKey:@"letter"];
		NSString* keycode = [attributeDict valueForKey:@"keycode"];
		int xStart = [[attributeDict valueForKey:@"xStart"] intValue];
		int yStart = [[attributeDict valueForKey:@"yStart"] intValue];
		int xEnd = [[attributeDict valueForKey:@"xEnd"] intValue];
		int yEnd = [[attributeDict valueForKey:@"yEnd"] intValue];
		MKButton* newButton = [[MKButton alloc] initWithXMLData:letter:keycode:xStart:xEnd:yStart:yEnd];
		[currentButtons addObject:newButton];
		[newButton retain];
		[letter retain];
	}
}
-(void)getButtonsForXMLFile:(NSString*)xmlFileName{
	// Create a parser
	NSData* d = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:xmlFileName ofType:@"xml"]];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:d];
	[parser setDelegate:self];
	// Do the parse
	[parser parse];
	[parser release];
}
- (void) writePrefs : (NSString*) key : (NSString*) value {
	// our preference data is our client name, hostname, and buddy list
    [prefs setObject:value forKey:key];
    [prefs writeToFile:[@"~/Library/Preferences/com.magickeyboard.plist"
						stringByExpandingTildeInPath] atomically: TRUE];
}

-(void)setTracking:(bool)trackingEnabled{
	doTracking = trackingEnabled; 
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
}


-(BOOL) acceptsFirstResponder {
	return NO;
}
@synthesize symsLayout;
@synthesize keyboardImage;
@synthesize numbersLayout;
@synthesize qwertyLayout;
@synthesize tap;
@synthesize mtW;
@synthesize currentButtons;
@synthesize mySelf;
@synthesize mtH;
@synthesize shift;
@end
