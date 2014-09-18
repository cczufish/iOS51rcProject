//
//  MyRecruitmentViewController.h
//  iOS51rcProject
//
//  Created by qlrc on 14-8-27.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyRmReceivedInvitationViewController.h"
#import "MyRmSubscribeListViewController.h"
#import "GoToRmViewDetailDelegate.h"
#import "Delegate/GoToMyInvitedCpViewDelegate.h"

@interface MyRecruitmentViewController : UIViewController<GoToRmViewDetailDelegate, GoToMyInvitedCpViewDelegate>
{
    
}
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
@property (retain,nonatomic) MyRmSubscribeListViewController *myRmSubscribeListView;
@property (retain,nonatomic) MyRmReceivedInvitationViewController *myRmInvitationViewCtrl;
@end
