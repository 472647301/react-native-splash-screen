// SplashScreen.m

#import "SplashScreen.h"
#import <React/RCTBridge.h>
#import <React/RCTUtils.h>

static NSMutableArray<RCTPromiseResolveBlock> *_resolverQueue = nil;
static RCTRootView *_rootView = nil;

@implementation SplashScreen

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup {
  return NO;
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

+ (void)initWithStoryboard:(NSString * _Nonnull)storyboardName
                  rootView:(UIView * _Nullable)rootView {
  if (rootView == nil ||
      ![rootView isKindOfClass:[RCTRootView class]] ||
      _rootView != nil ||
      RCTRunningInAppExtension())
    return;

  _rootView = (RCTRootView *)rootView;

  [[NSNotificationCenter defaultCenter] removeObserver:rootView
                                                  name:RCTContentDidAppearNotification
                                                object:rootView];

  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
  UIView *loadingView = [[storyboard instantiateInitialViewController] view];

  if (_resolverQueue != nil)
    return; // hide has already been called, abort init

  [_rootView setLoadingView:loadingView];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(onJavaScriptDidLoad)
                                               name:RCTJavaScriptDidLoadNotification
                                             object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(onJavaScriptDidFailToLoad)
                                               name:RCTJavaScriptDidFailToLoadNotification
                                             object:nil];
}

+ (void)onJavaScriptDidLoad {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)onJavaScriptDidFailToLoad {
  [self removeLoadingView];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (bool)isHidden {
  return _rootView == nil || _rootView.loadingView == nil || [_rootView.loadingView isHidden];
}

+ (void)removeLoadingView {
  if (![self isHidden]) {
    _rootView.loadingView.hidden = YES;

    [_rootView.loadingView removeFromSuperview];
    _rootView.loadingView = nil;
  }
}

- (void)clearResolverQueue {
  while ([_resolverQueue count] > 0) {
    RCTPromiseResolveBlock resolve = [_resolverQueue objectAtIndex:0];
    [_resolverQueue removeObjectAtIndex:0];

    resolve(@(true));
  }
}

RCT_REMAP_METHOD(hide,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  if (_resolverQueue == nil)
    _resolverQueue = [[NSMutableArray alloc] init];

  [_resolverQueue addObject:resolve];

  if ([SplashScreen isHidden] || RCTRunningInAppExtension())
    return [self clearResolverQueue];

  [SplashScreen removeLoadingView];
  return [self clearResolverQueue];
}

@end
