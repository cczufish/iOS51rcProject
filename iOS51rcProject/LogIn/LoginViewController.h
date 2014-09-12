//
//  LoginViewController.h
//  iOS51rcProject
//
//  Created by qlrc on 14-8-15.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginDetailsViewController.h"
#import "RegisterViewController.h"
#import "LoginDetailsDelegate.h"
#import "GoToHomeDelegate.h"

@interface LoginViewController: UIViewController<LoginDetailsDelegate, GoToHomeDelegate>
    @property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
    @property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
    @property (nonatomic, strong) LoginDetailsViewController *loginDetailsView;
    @property (nonatomic, strong) RegisterViewController *registerView;
@end
