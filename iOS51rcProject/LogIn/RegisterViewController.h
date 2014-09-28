//
//  RegisterViewController.h
//  iOS51rcProject
//
//  Created by qlrc on 14-8-15.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateResumeAlertViewController.h"
#import "GoToHomeDelegate.h"

@interface RegisterViewController : UIViewController
{
    id<GoToHomeDelegate> gotoHomeDelegate;
    NSString *userName;
    NSString *userID;
    NSString *password;
    NSString *rePassword;
    NSString *ip;
    NSString *provinceID;
    NSString *browser;
    NSString *isAutoLogin;
    CreateResumeAlertViewController *createResumeCtrl;
    UIView *backGroundView;
}

@property(nonatomic, retain) id<GoToHomeDelegate> gotoHomeDelegate;
@end
