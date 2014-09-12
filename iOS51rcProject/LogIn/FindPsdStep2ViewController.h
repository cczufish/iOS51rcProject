//
//  FindPsdStep2ViewController.h
//  iOS51rcProject
//
//  Created by qlrc on 14-8-15.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindPsdStep2ViewController : UIViewController
{
    NSString *verifyCode;
}

@property (retain,nonatomic) NSString *type;  //本次找回的类型：用户名，邮箱 1  手机号
@property (retain,nonatomic) NSString *code;
@property (retain,nonatomic) NSString *name; //上一步找回时输入的邮箱名或者手机号
@end
