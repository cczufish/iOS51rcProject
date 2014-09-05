#import "HomeViewController.h"
#import "LoginViewController.h"
#import "SlideNavigationController.h"
#import "JobSearch/SearchMainViewController.h"
#import "GRListViewController.h"
#import "EIListViewController.h"
#import "EmploymentInformation/EIMainViewController.h"
#import "MoreViewController.h"

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//点击职位搜索
- (IBAction)btnSearchJob:(id)sender {
    UIStoryboard *search = [UIStoryboard storyboardWithName:@"JobSearch" bundle:nil];
    SearchMainViewController *searchCtrl = [search instantiateViewControllerWithIdentifier:@"SearchMain"];
    [self.navigationController pushViewController:searchCtrl animated:YES];
}

//点击我的简历按钮
- (IBAction)btnMyResultClick:(id)sender {
    UIStoryboard *login = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    LoginViewController *loginCtrl = [login instantiateViewControllerWithIdentifier:@"LoginView"];
    [self.navigationController pushViewController:loginCtrl animated:YES];
    //[loginCtrl release];//加release会报错
}

- (IBAction)btnMoreClick:(id)sender {
    UIStoryboard *storyMore = [UIStoryboard storyboardWithName:@"More" bundle:nil];
    MoreViewController *moreC = [storyMore instantiateViewControllerWithIdentifier:@"MoreView"];
    moreC.navigationItem.title = @"更多";
    [self.navigationController pushViewController:moreC animated:true];
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
    EIListViewController *eiCtrl = [search instantiateViewControllerWithIdentifier:@"GRListView"];
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
