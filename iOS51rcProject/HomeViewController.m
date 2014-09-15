#import "HomeViewController.h"
#import "LoginViewController.h"
#import "SlideNavigationController.h"
#import "GRListViewController.h"
#import "EIListViewController.h"
#import "EmploymentInformation/EIMainViewController.h"
#import "MoreViewController.h"
#import "RecruitmentListViewController.h"
#import "CampusViewController.h"
#import "Toast+UIView.h"
#import "CpInviteViewController.h"
#import "JmMainViewController.h"
#import "CommonController.h"

@interface HomeViewController() <SlideNavigationControllerDelegate>

@end

@implementation HomeViewController

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
    //接收其他页面的消息（返回时）
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popBackCompletion:)
                                                 name:@"Home"
                                               object:nil];
}

//处理其他页面返回的事件
-(void)popBackCompletion:(NSNotification*)notification {
    NSDictionary *theData = [notification userInfo];
    NSString *value = [theData objectForKey:@"operation"];    
    
    if([value isEqualToString:@"logout"]){
        //从“更多”页面退出后返回
        [self.view makeToast:@"退出成功"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//点击职位申请
- (IBAction)btnJobApplication:(id)sender {
    if ([CommonController isLogin]) {
        UIStoryboard *jm = [UIStoryboard storyboardWithName:@"JobApplication" bundle:nil];
        JmMainViewController *jmMainCtrl = [jm instantiateViewControllerWithIdentifier:@"JmMainView"];
        jmMainCtrl.navigationItem.title = @"职位申请";
        self.navigationItem.title = @" ";
        [self.navigationController pushViewController:jmMainCtrl animated:true];
    }else{
        UIStoryboard *login = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        LoginViewController *loginCtrl = [login instantiateViewControllerWithIdentifier:@"LoginView"];
        [self.navigationController pushViewController:loginCtrl animated:YES];
        self.navigationItem.title = @" ";
    }
}

//点击企业邀约
- (IBAction)btnCpInvitationClick:(id)sender {
    if ([CommonController isLogin]) {
        UIStoryboard *userCenter = [UIStoryboard storyboardWithName:@"UserCenter" bundle:nil];
        CpInviteViewController *CpInviteViewCtrl = [userCenter instantiateViewControllerWithIdentifier:@"CpInviteView"];
        CpInviteViewCtrl.navigationItem.title = @"企业邀约";
        self.navigationItem.title = @" ";
        [self.navigationController pushViewController:CpInviteViewCtrl animated:true];
    }else{
        UIStoryboard *login = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        LoginViewController *loginCtrl = [login instantiateViewControllerWithIdentifier:@"LoginView"];
        [self.navigationController pushViewController:loginCtrl animated:YES];
        self.navigationItem.title = @" ";
    }
}

//点击招聘会
- (IBAction)btnRMClick:(id)sender {
    UIStoryboard *storyMore = [UIStoryboard storyboardWithName:@"Recruitment" bundle:nil];
    RecruitmentListViewController *rmList = [storyMore instantiateViewControllerWithIdentifier:@"RecruitmentListView"];
    rmList.navigationItem.title = @"招聘会";
    [self.navigationController pushViewController:rmList animated:true];
}

//点击我的简历按钮
- (IBAction)btnMyResultClick:(id)sender {
    if([CommonController isLogin]) {
        UIViewController *viewC = [[UIStoryboard storyboardWithName:@"UserCenter" bundle:nil] instantiateViewControllerWithIdentifier:@"MyCvView"];
        [self.navigationController pushViewController:viewC animated:YES];
    }
    else {
        UIStoryboard *login = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        LoginViewController *loginCtrl = [login instantiateViewControllerWithIdentifier:@"LoginView"];
        [self.navigationController pushViewController:loginCtrl animated:YES];
    }
}

- (IBAction)btnMoreClick:(id)sender {
    UIStoryboard *storyMore = [UIStoryboard storyboardWithName:@"More" bundle:nil];
    MoreViewController *moreC = [storyMore instantiateViewControllerWithIdentifier:@"MoreView"];
    moreC.navigationItem.title = @"更多";
    [self.navigationController pushViewController:moreC animated:true];
}

- (IBAction)btnCampusClick:(id)sender {
    UIStoryboard *storyMore = [UIStoryboard storyboardWithName:@"Campus" bundle:nil];
    CampusViewController *campusC = [storyMore instantiateViewControllerWithIdentifier:@"CampusView"];
    campusC.navigationItem.title = @"校园招聘";
    [self.navigationController pushViewController:campusC animated:true];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (int)slideMenuItem
{
    return 1;
}

//点击政府招考
- (IBAction)btnGRClick:(id)sender {
    UIStoryboard *search = [UIStoryboard storyboardWithName:@"GovernmentRecruitmentStoryboard" bundle:nil];
     GRListViewController *eiCtrl = [search instantiateViewControllerWithIdentifier:@"GRListView"];
    [self.navigationController pushViewController:eiCtrl animated:YES];
}

//点击就业资讯
- (IBAction)btnEIClick:(id)sender {
    UIStoryboard *eiStoryBoard = [UIStoryboard storyboardWithName:@"EmploymentInformation" bundle:nil];
    EIMainViewController *eiMainCtrl = [eiStoryBoard instantiateViewControllerWithIdentifier:@"EIMainView"];
    [self.navigationController pushViewController:eiMainCtrl animated:YES];
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

@end
