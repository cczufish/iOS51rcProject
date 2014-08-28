//
//  MyRmCpListViewController.h
//  iOS51rcProject
//
//  Created by qlrc on 14-8-27.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"
#import "GoToRmViewDetailDelegate.h"
#import "GoToMyInvitedCpViewDelegate.h"

@interface MyRmCpListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger page;
    NSInteger pageSize;
    NSMutableArray *recruitmentCpData;
    //NSString *rmID;
    LoadingAnimationView *loadView;
    NSMutableArray *checkedCpArray;
    id<GoToRmViewDetailDelegate> gotoRmViewDelegate;
    id<GoToMyInvitedCpViewDelegate> gotoMyInvitedCpViewDelegate;
}
@property (retain, nonatomic) id<GoToRmViewDetailDelegate> gotoRmViewDelegate;
@property (retain, nonatomic) id<GoToMyInvitedCpViewDelegate> gotoMyInvitedCpViewDelegate;
@end

