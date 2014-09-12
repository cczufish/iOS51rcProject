//
//  CreateResumeAlertViewController.h
//  iOS51rcProject
//
//  Created by qlrc on 14-8-21.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//
#import <UIKit/UIKit.h>

//协议
@protocol CreateResumeDelegate <NSObject>
-(void) CreateResume:(BOOL) hasExp;
@end


@interface CreateResumeAlertViewController : UIViewController
{
    BOOL hasExp;
    id<CreateResumeDelegate> delegate;
}
@property (nonatomic, assign) id<CreateResumeDelegate> delegate;
@end
