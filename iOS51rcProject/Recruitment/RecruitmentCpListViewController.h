//
//  RecruitmentCpListViewController.h
//  iOS51rcProject
//
//  Created by qlrc on 14-8-26.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"

@interface RecruitmentCpListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger page;
    NSInteger pageSize;
    NSMutableArray *recruitmentCpData;
    //NSString *rmID;
    LoadingAnimationView *loadView;
    NSMutableArray *checkedCpArray;
}
@property (retain, nonatomic) NSString *rmID;
@property (retain, nonatomic) NSString *strBeginTime;
@property (retain, nonatomic) NSString *strAddress;
@property (retain, nonatomic) NSString *strPlace;
@end
