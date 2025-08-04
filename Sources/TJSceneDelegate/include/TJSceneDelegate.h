//
//  TJSceneDelegate.h
//
//  Created by Tim Johnsen on 5/7/25.
//  Copyright © 2025 Tim Johnsen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TJAppDelegate <UIApplicationDelegate>

- (UIViewController *)appWindowRootViewController;
- (UIWindow *)window;

@end

@interface TJSceneDelegate : NSObject <UIWindowSceneDelegate>

@end

NS_ASSUME_NONNULL_END