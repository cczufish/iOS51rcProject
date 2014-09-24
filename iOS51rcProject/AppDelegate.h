//
//  AppDelegate.h
//  iOS51rcProject
//
//  Created by Lucifer on 14-8-13.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "MenuViewController.h"
#import "BMapKit.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BMKMapManager* _mapManager;
}
@property (strong, nonatomic) UIWindow *window;
@end