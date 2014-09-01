//
//  MyRecruitmentViewController.m
//  iOS51rcProject
//
//  Created by qlrc on 14-8-27.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import "MyRecruitmentViewController.h"
#import "RecruitmentViewController.h"
#import "MyRmInviteCpListViewController.h"
#import "RmInviteCpViewController.h"

@interface MyRecruitmentViewController ()
@property (retain, nonatomic) IBOutlet UILabel *lbBgLeft;
@property (retain, nonatomic) IBOutlet UILabel *lbBgRight;
@property (retain, nonatomic) IBOutlet UIButton *btnInvitation;//右
@property (retain, nonatomic) IBOutlet UIButton *btnMyRm;//左

@end

@implementation MyRecruitmentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     self.lbBgRight.backgroundColor = [UIColor clearColor];
    //self.btnInvitation.titleLabel.textColor = [UIColor orangeColor];
    self.btnInvitation.titleLabel.textColor = [UIColor blackColor];
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.y = 106;//状态栏和切换栏的高度
    frame.size.height = frame.size.height - 106;
    //获得子View
    self.myRmCpListViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MyRmCpListView"];
    self.myRmInvitationViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MyRmInvitationView"];
    self.myRmCpListViewCtrl.view.frame = frame;
    self.myRmInvitationViewCtrl.view.frame = frame;
    
    //初始化左侧和右侧的登录以及注册子View
    self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    self.leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:self.leftSwipeGestureRecognizer];
    [self.view addGestureRecognizer:self.rightSwipeGestureRecognizer];
    self.myRmCpListViewCtrl.gotoRmViewDelegate = self;
    self.myRmCpListViewCtrl.gotoMyInvitedCpViewDelegate = self;
    //self.myRmInvitationViewCtrl.gotoHomeDelegate = self;
    
    //默认加载我的预约页面
    [self.view addSubview: self.myRmCpListViewCtrl.view];
    
    //添加邀请按钮
    UIButton *btnInviteCp = [[UIButton alloc] initWithFrame:CGRectMake(110,  self.myRmCpListViewCtrl.view.frame.size.height + 60, 110, 35)];
    btnInviteCp.backgroundColor = [UIColor colorWithRed:255/255.0 green:90/255.0 blue:49/255.0 alpha:1];
    btnInviteCp.layer.cornerRadius = 5;
    [btnInviteCp addTarget:self action:@selector(inviteCp) forControlEvents:UIControlEventTouchUpInside];
    UILabel *lbInviteCp = [[UILabel alloc]initWithFrame:CGRectMake(0,0, 110,35)];
    lbInviteCp.text = @"邀请企业参会";
    lbInviteCp.font = [UIFont systemFontOfSize:12];
    lbInviteCp.textColor = [UIColor whiteColor];
    lbInviteCp.textAlignment = NSTextAlignmentCenter;
    [btnInviteCp addSubview:lbInviteCp];
    [self.view addSubview:btnInviteCp];
    [btnInviteCp release];
    [lbInviteCp release];
}

//邀请企业参会
-(void) inviteCp
{
    RmInviteCpViewController *inviteViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"RmInviteCpView"];
    [self.navigationController pushViewController:inviteViewCtrl animated:true];
}

//从我的预约页面到招聘会详情页面
-(void) gotoRmView:(NSString *) rmID
{
    RecruitmentViewController *rmViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"RecruitmentView"];
    rmViewCtrl.recruitmentID = rmID;
    [self.navigationController pushViewController:rmViewCtrl animated:true];
}

//从我的预约页面到我邀请的企业页面
-(void) GoToMyInvitedCpView:(NSString *) paMainID
{
    MyRmInviteCpListViewController *rmViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MyRmInviteCpListView"];
    [self.navigationController pushViewController:rmViewCtrl animated:true];
}

- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        [self.myRmCpListViewCtrl removeFromParentViewController];
        [self.view addSubview:self.myRmInvitationViewCtrl.view];
        //self.navigationItem.title = @"登录";
        self.lbBgRight.backgroundColor = [UIColor clearColor];
        self.lbBgLeft.backgroundColor = [UIColor orangeColor];
        self.btnMyRm.titleLabel.textColor = [UIColor orangeColor];
        self.btnInvitation.titleLabel.textColor = [UIColor blackColor];
    }
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self.myRmInvitationViewCtrl removeFromParentViewController];
        [self.view addSubview:self.myRmCpListViewCtrl.view];
        //self.navigationItem.title = @"注册";
        self.lbBgRight.backgroundColor = [UIColor orangeColor];
        self.lbBgLeft.backgroundColor = [UIColor clearColor];
        self.btnMyRm.titleLabel.textColor = [UIColor blackColor];
        self.btnInvitation.titleLabel.textColor = [UIColor orangeColor];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnLeftClick:(id)sender {
    [self.myRmInvitationViewCtrl removeFromParentViewController];
    [self.view addSubview:self.myRmCpListViewCtrl.view];
    //self.navigationItem.title = @"登录";
    self.lbBgRight.backgroundColor = [UIColor clearColor];
    self.lbBgLeft.backgroundColor = [UIColor orangeColor];
    self.btnMyRm.titleLabel.textColor = [UIColor orangeColor];
    self.btnInvitation.titleLabel.textColor = [UIColor blackColor];
}

- (IBAction)btnRightClick:(id)sender {
    [self.myRmCpListViewCtrl removeFromParentViewController];
    [self.view addSubview:self.myRmInvitationViewCtrl.view];
    //self.navigationItem.title = @"注册";
    self.lbBgRight.backgroundColor = [UIColor orangeColor];
    self.lbBgLeft.backgroundColor = [UIColor clearColor];
    self.btnMyRm.titleLabel.textColor = [UIColor blackColor];
    self.btnInvitation.titleLabel.textColor = [UIColor orangeColor];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_lbBgLeft release];
    [_lbBgRight release];
    [_btnInvitation release];
    [_btnMyRm release];
    [super dealloc];
}
@end
