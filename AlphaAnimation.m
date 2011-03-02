#import "AlphaAnimation.h"

NSString * const AAFadeIn = @"AAFadeIn";
NSString * const AAFadeOut = @"AAFadeOut";

@implementation AlphaAnimation
- (id)initWithDuration:(NSTimeInterval)aDuration effect:(NSString *)anEffect object:(NSView *)anObject
{
    self = [super initWithDuration:aDuration animationCurve:0];
    
    if (self) {
        animatedObject = anObject;
        effect = anEffect;
    }
    
    return self;
}

- (void)setCurrentProgress:(NSAnimationProgress)progress
{
    [super setCurrentProgress:progress];

    if ([effect isEqual:AAFadeIn])
        [animatedObject setAlphaValue:progress];
    else
        [animatedObject setAlphaValue:1 - progress];
    
}
@synthesize animatedObject;
@synthesize effect;
@end
