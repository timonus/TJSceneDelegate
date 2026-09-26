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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[[UIApplication sharedApplication] delegate] applicationDidBecomeActive:[UIApplication sharedApplication]];
#pragma clang diagnostic pop
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[[UIApplication sharedApplication] delegate] applicationWillResignActive:[UIApplication sharedApplication]];
#pragma clang diagnostic pop
    }
}

- (void)sceneWillEnterForeground:(UIScene *)scene
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(applicationWillEnterForeground:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[[UIApplication sharedApplication] delegate] applicationWillEnterForeground:[UIApplication sharedApplication]];
#pragma clang diagnostic pop
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        options[UIApplicationOpenURLOptionsSourceApplicationKey] = context.options.sourceApplication;
        options[UIApplicationOpenURLOptionsAnnotationKey] = context.options.annotation;
        options[UIApplicationOpenURLOptionsOpenInPlaceKey] = @(context.options.openInPlace);
        if (@available(iOS 14.5, *)) {
            options[UIApplicationOpenURLOptionsEventAttributionKey] = context.options.eventAttribution;
        }
        [[[UIApplication sharedApplication] delegate] application:[UIApplication sharedApplication]
                                                          openURL:context.URL
                                                          options:options];
#pragma clang diagnostic pop
    }
}

- (void)scene:(UIScene *)scene willContinueUserActivityWithType:(NSString *)userActivityType
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(application:willContinueUserActivityWithType:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[[UIApplication sharedApplication] delegate] application:[UIApplication sharedApplication]
                                 willContinueUserActivityWithType:userActivityType];
#pragma clang diagnostic pop
    }
}

- (void)scene:(UIScene *)scene continueUserActivity:(NSUserActivity *)userActivity
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(application:continueUserActivity:restorationHandler:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[[UIApplication sharedApplication] delegate] application:[UIApplication sharedApplication]
                                             continueUserActivity:userActivity
                                               restorationHandler:^(NSArray<id<UIUserActivityRestoring>> * _Nullable restorableObjects) {}];
#pragma clang diagnostic pop
    }
}

- (void)scene:(UIScene *)scene didFailToContinueUserActivityWithType:(NSString *)userActivityType error:(NSError *)error
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(application:didFailToContinueUserActivityWithType:error:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[[UIApplication sharedApplication] delegate] application:[UIApplication sharedApplication]
                            didFailToContinueUserActivityWithType:userActivityType
                                                            error:error];
#pragma clang diagnostic pop
    }
}

- (void)scene:(UIScene *)scene didUpdateUserActivity:(NSUserActivity *)userActivity
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(application:didUpdateUserActivity:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[[UIApplication sharedApplication] delegate] application:[UIApplication sharedApplication]
                                            didUpdateUserActivity:userActivity];
#pragma clang diagnostic pop
    }
}

- (void)windowScene:(UIWindowScene *)windowScene performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(application:performActionForShortcutItem:completionHandler:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[[UIApplication sharedApplication] delegate] application:[UIApplication sharedApplication]
                                     performActionForShortcutItem:shortcutItem
                                                completionHandler:completionHandler];
#pragma clang diagnostic pop
    }
}

- (void)windowScene:(UIWindowScene *)windowScene userDidAcceptCloudKitShareWithMetadata:(CKShareMetadata *)cloudKitShareMetadata
{
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(application:userDidAcceptCloudKitShareWithMetadata:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[[UIApplication sharedApplication] delegate] application:[UIApplication sharedApplication]
                           userDidAcceptCloudKitShareWithMetadata:cloudKitShareMetadata];
#pragma clang diagnostic pop
    }
}

@end