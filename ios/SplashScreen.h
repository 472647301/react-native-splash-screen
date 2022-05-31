// SplashScreen.h

#import <React/RCTRootView.h>
#import <React/RCTBridgeModule.h>

@interface SplashScreen : NSObject <RCTBridgeModule>

+ (void)initWithStoryboard:(NSString * _Nonnull)storyboardName
                  rootView:(UIView * _Nullable)rootView;

@end
