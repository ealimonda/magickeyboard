#import <Cocoa/Cocoa.h>

NSString * const AAFadeIn;
NSString * const AAFadeOut;

@interface AlphaAnimation : NSAnimation {
    NSView          *animatedObject;
    NSString        *effect;
}
- (id)initWithDuration:(NSTimeInterval)duration effect:(NSString *)effect object:(NSView *)object;
@property (retain) NSView          *animatedObject;
@property (retain) NSString        *effect;
@end
