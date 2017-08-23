#import <objc/runtime.h>
#import <notify.h>
#import <substrate.h>

extern const char *__progname;

#define NSLog(...)

@interface SUUtility : NSObject
+ (BOOL)freeCachedSpaceSynchronous:(unsigned long long)arg1 timeout:(double)arg2;
@end

#import <libactivator/libactivator.h>
#import <Flipswitch/Flipswitch.h>

@interface CacheWipeActivatorSwitch : NSObject <FSSwitchDataSource>
+ (id)sharedInstance;
+ (BOOL)sharedInstanceExist;
- (void)RegisterActions;
@end

static BOOL Enabled;

@implementation CacheWipeActivatorSwitch
__strong static id _sharedObject;
+ (id)sharedInstance
{
	if (!_sharedObject) {
		_sharedObject = [[self alloc] init];
	}
	return _sharedObject;
}
+ (BOOL)sharedInstanceExist
{
	if (_sharedObject) {
		return YES;
	}
	return NO;
}
- (void)RegisterActions
{
    if (access("/usr/lib/libactivator.dylib", F_OK) == 0) {
		dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
	    if (Class la = objc_getClass("LAActivator")) {
			[[la sharedInstance] registerListener:(id<LAListener>)self forName:@"com.julioverne.cachewipe"];
		}
	}
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName
{
	return @"CacheWipe";
}
- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName
{
	return @"Action For Wipe Cache Data.";
}
- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale
{
    static __strong UIImage* listenerIcon;
    if (!listenerIcon) {
		listenerIcon = [[UIImage alloc] initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/Switches/CacheWipe.bundle"] pathForResource:scale==2.0f?@"icon@2x":@"icon" ofType:@"png"]];
	}
    return listenerIcon;
}
- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale
{
    static __strong UIImage* listenerIcon;
    if (!listenerIcon) {
		listenerIcon = [[UIImage alloc] initWithContentsOfFile:[[NSBundle bundleWithPath:@"/Library/Switches/CacheWipe.bundle"] pathForResource:scale==2.0f?@"icon@2x":@"icon" ofType:@"png"]];
	}
    return listenerIcon;
}
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	if(Enabled) {
		return;
	}
	Enabled = YES;
	[[%c(FSSwitchPanel) sharedPanel] stateDidChangeForSwitchIdentifier:@"com.julioverne.cachewipe"];
	@autoreleasepool {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[%c(SUUtility) freeCachedSpaceSynchronous:999999999999 timeout:3600];
			Enabled = NO;
			[[%c(FSSwitchPanel) sharedPanel] stateDidChangeForSwitchIdentifier:@"com.julioverne.cachewipe"];
		});
	}
}
- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
	return Enabled?FSSwitchStateOn:FSSwitchStateOff;
}
- (void)applyActionForSwitchIdentifier:(NSString *)switchIdentifier
{
	[self activator:nil receiveEvent:nil];
}
@end



%ctor
{
	@autoreleasepool {
		dlopen("/System/Library/PrivateFrameworks/SoftwareUpdateServices.framework/SoftwareUpdateServices", RTLD_LAZY);
		[[CacheWipeActivatorSwitch sharedInstance] RegisterActions];
	}
}
