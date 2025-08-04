//
//  TJSceneDelegate.m
//
//  Created by Tim Johnsen on 5/7/25.
//  Copyright © 2025 Tim Johnsen. All rights reserved.
//

#import "include/TJSceneDelegate.h"
#import <UserNotifications/UserNotifications.h>

@implementation TJSceneDelegate {
    UIWindow *_window;
    UISceneConnectionOptions *_pendingOptions;
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions
{
    NSAssert([[[UIApplication sharedApplication] delegate] conformsToProtocol:@protocol(TJAppDelegate)], @"App delegate must conform to TJAppDelegate");
    _window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    _window.rootViewController = [(NSObject<TJAppDelegate> *)[[UIApplication sharedApplication] delegate] appWindowRootViewController];
    [_window makeKeyAndVisible];
    
    _pendingOptions = connectionOptions;
}

- (void)sceneDidBecomeActive:(UIScene *)scene
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(applicationDidBecomeActive:)]) {
        [[[UIApplication sharedApplication] delegate] applicationDidBecomeActive:[UIApplication sharedApplication]];
    }
    
    if (_pendingOptions) {
        if (_pendingOptions.URLContexts.count) {
            [self scene:scene openURLContexts:_pendingOptions.URLContexts];
        }
        if (_pendingOptions.notificationResponse) {
#if DEBUG
            if ([[UNUserNotificationCenter currentNotificationCenter] delegate] == nil) {
                NSLog(@"[TJSceneDelegate] WARNING - UNUserNotificationCenter.currentNotificationCenter.delegate is unassigned, notification handling may not function on cold start");
            }
#endif
            if ([[[UNUserNotificationCenter currentNotificationCenter] delegate] respondsToSelector:@selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:)]) {
                [[[UNUserNotificationCenter currentNotificationCenter] delegate] userNotificationCenter:[UNUserNotificationCenter currentNotificationCenter]
                                                                         didReceiveNotificationResponse:_pendingOptions.notificationResponse
                                                                                  withCompletionHandler:^{
                    // no-op since UISceneConnectionOptions doesn't provide a completion handler.
                }];
            }
        }
        if (_pendingOptions.shortcutItem) {
            [self windowScene:(UIWindowScene *)scene performActionForShortcutItem:_pendingOptions.shortcutItem completionHandler:^(BOOL succeeded) {
                // no-op since UISceneConnectionOptions doesn't provide a completion handler.
            }];
        }
        // NOTE: Handoff doesn't actually go through this path per the docs.
        for (NSUserActivity *userActivity in _pendingOptions.userActivities) {
            [self scene:scene continueUserActivity:userActivity];
        }
        if (_pendingOptions.cloudKitShareMetadata) {
            [self windowScene:(UIWindowScene *)scene userDidAcceptCloudKitShareWithMetadata:_pendingOptions.cloudKitShareMetadata];
        }
        _pendingOptions = nil;
    }
}

- (void)sceneWillResignActive:(UIScene *)scene
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(applicationWillResignActive:)]) {
        [[[UIApplication sharedApplication] delegate] applicationWillResignActive:[UIApplication sharedApplication]];
    }
}

- (void)sceneWillEnterForeground:(UIScene *)scene
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(applicationWillEnterForeground:)]) {
        [[[UIApplication sharedApplication] delegate] applicationWillEnterForeground:[UIApplication sharedApplication]];
    }
}

- (void)sceneDidEnterBackground:(UIScene *)scene
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(applicationDidEnterBackground:)]) {
        [[[UIApplication sharedApplication] delegate] applicationDidEnterBackground:[UIApplication sharedApplication]];
    }
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)contexts
{
    if (![[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        return;
    }
    for (UIOpenURLContext *context in contexts) {
        NSMutableDictionary<UIApplicationOpenURLOptionsKey, id> *const options = [NSMutableDictionary new];
        options[UIApplicationOpenURLOptionsSourceApplicationKey] = context.options.sourceApplication;
        options[UIApplicationOpenURLOptionsAnnotationKey] = context.options.annotation;
        options[UIApplicationOpenURLOptionsOpenInPlaceKey] = @(context.options.openInPlace);
        if (@available(iOS 14.5, *)) {
            options[UIApplicationOpenURLOptionsEventAttributionKey] = context.options.eventAttribution;
        }
        [[[UIApplication sharedApplication] delegate] application:[UIApplication sharedApplication]
                                                          openURL:context.URL
                                                          options:options];
    }
}

- (void)scene:(UIScene *)scene willContinueUserActivityWithType:(NSString *)userActivityType
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(application:willContinueUserActivityWithType:)]) {
        [[[UIApplication sharedApplication] delegate] application:[UIApplication sharedApplication]
                                 willContinueUserActivityWithType:userActivityType];
    }
}

- (void)scene:(UIScene *)scene continueUserActivity:(NSUserActivity *)userActivity
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(application:continueUserActivity:restorationHandler:)]) {
        [[[UIApplication sharedApplication] delegate] application:[UIApplication sharedApplication]
                                             continueUserActivity:userActivity
                                               restorationHandler:^(NSArray<id<UIUserActivityRestoring>> * _Nullable restorableObjects) {}];
    }
}

- (void)scene:(UIScene *)scene didFailToContinueUserActivityWithType:(NSString *)userActivityType error:(NSError *)error
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(application:didFailToContinueUserActivityWithType:error:)]) {
        [[[UIApplication sharedApplication] delegate] application:[UIApplication sharedApplication]
                            didFailToContinueUserActivityWithType:userActivityType
                                                            error:error];
    }
}

- (void)scene:(UIScene *)scene didUpdateUserActivity:(NSUserActivity *)userActivity
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(application:didUpdateUserActivity:)]) {
        [[[UIApplication sharedApplication] delegate] application:[UIApplication sharedApplication]
                                            didUpdateUserActivity:userActivity];
    }
}

- (void)windowScene:(UIWindowScene *)windowScene performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(application:performActionForShortcutItem:completionHandler:)]) {
        [[[UIApplication sharedApplication] delegate] application:[UIApplication sharedApplication]
                                     performActionForShortcutItem:shortcutItem
                                                completionHandler:completionHandler];
    }
}

- (void)windowScene:(UIWindowScene *)windowScene userDidAcceptCloudKitShareWithMetadata:(CKShareMetadata *)cloudKitShareMetadata
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(application:userDidAcceptCloudKitShareWithMetadata:)]) {
        [[[UIApplication sharedApplication] delegate] application:[UIApplication sharedApplication]
                           userDidAcceptCloudKitShareWithMetadata:cloudKitShareMetadata];
    }
}

@end