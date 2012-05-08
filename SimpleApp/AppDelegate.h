//
//  AppDelegate.h
//  SimpleApp
//
//  Created by Ming Chow on 2/7/12.
//  Copyright (c) 2012 Tufts University. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "crmd.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@property CRMD_HANDLE handle;
@property CRMD_FUNC *api;

@end
