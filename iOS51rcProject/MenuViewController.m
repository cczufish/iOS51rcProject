#import "MenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "CommonController.h"

@interface MenuViewController () <UITableViewDataSource,UITableViewDelegate>

@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tvMenu setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tvMenu];
    [self changeMenuItem:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(80, 8, 200, 30)];
    UIImageView *ivTitle = [[UIImageView alloc] init];
    switch (indexPath.row)
    {
        case 0:
            if ([CommonController isLogin]) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                UILabel *lbPaName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
                lbPaName.text = [userDefaults objectForKey:@"paName"];
                lbPaName.font = [UIFont systemFontOfSize:14];
                lbPaName.textColor = [UIColor whiteColor];
                [lbTitle addSubview:lbPaName];
                [lbPaName release];
                
                UILabel *lbUserName = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 200, 10)];
                lbUserName.text = [userDefaults objectForKey:@"UserName"];
                lbUserName.font = [UIFont systemFontOfSize:10];
                lbUserName.textColor = [UIColor whiteColor];
                [lbTitle addSubview:lbUserName];
                [lbUserName release];
                
                [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_head.png"]];
                ivTitle.frame = CGRectMake(35, 7, 35, 35);
            }
            else {
                lbTitle.text = @"点击登录";
                [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_head.png"]];
                ivTitle.frame = CGRectMake(35, 7, 35, 35);
            }
            break;
        case 1:
            lbTitle.text = @"首页";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_index.png"]];
            ivTitle.frame = CGRectMake(45, 12, 21, 21);
            break;
        case 2:
            lbTitle.text = @"职位搜索";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_search.png"]];
            ivTitle.frame = CGRectMake(45, 12, 21, 21);
            break;
        case 3:
            lbTitle.text = @"会员中心";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_mebercenter.png"]];
            ivTitle.frame = CGRectMake(45, 12, 21, 21);
            break;
        case 4:
            lbTitle.text = @"查工资";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_salary.png"]];
            ivTitle.frame = CGRectMake(45, 12, 21, 21);
            break;
        case 5:
            lbTitle.text = @"招聘会";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_rm.png"]];
            ivTitle.frame = CGRectMake(45, 12, 21, 21);
            break;
        case 6:
            lbTitle.text = @"政府招考";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_govnews.png"]];
            ivTitle.frame = CGRectMake(45, 12, 21, 21);
            break;
        case 7:
            lbTitle.text = @"校园招聘";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_campus.png"]];
            ivTitle.frame = CGRectMake(43, 14, 25, 21);
            break;
        case 8:
            lbTitle.text = @"就业资讯";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_jobnews.png"]];
            ivTitle.frame = CGRectMake(45, 14, 20, 18);
            break;
        case 9:
            lbTitle.text = @"更多";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_more.png"]];
            ivTitle.frame = CGRectMake(45, 15, 20, 15);
            break;
        default:
            break;
    }
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"menu"] autorelease];
    [cell.contentView addSubview:ivTitle];
    [cell.contentView addSubview:lbTitle];
    [lbTitle setTextColor:[UIColor whiteColor]];
    [cell setBackgroundColor:[UIColor clearColor]];
    if (indexPath.row == 0) {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    else {
        UIView *viewBackground = [[[UIView alloc] init] autorelease];
        [viewBackground setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.3]];
        UIView *viewSelect;
        if ([[UIScreen mainScreen] bounds].size.height == 480) {
            viewSelect = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 7, 43)] autorelease];
        }
        else {
            viewSelect = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 7, 48)] autorelease];
        }
        [viewSelect setBackgroundColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [viewBackground addSubview:viewSelect];
        [cell setSelectedBackgroundView:viewBackground];
    }
    [ivTitle release];
    [lbTitle release];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIViewController *vc;
	switch (indexPath.row)
	{
        case 0:
        {
            if ([CommonController isLogin]) {
                vc = [[UIStoryboard storyboardWithName:@"UserCenter" bundle: nil] instantiateViewControllerWithIdentifier: @"IndexView"];
            }
            else {
                vc = [[UIStoryboard storyboardWithName:@"Login" bundle: nil] instantiateViewControllerWithIdentifier: @"LoginView"];
            }
            break;
        }
		case 1:
            vc = [[UIStoryboard storyboardWithName:@"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"HomeView"];
			break;
        case 2:
            vc = [[UIStoryboard storyboardWithName:@"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"SearchView"];
			break;
        case 3:
        {
            if ([CommonController isLogin]) {
                vc = [[UIStoryboard storyboardWithName:@"UserCenter" bundle: nil] instantiateViewControllerWithIdentifier: @"IndexView"];
            }
            else {
                vc = [[UIStoryboard storyboardWithName:@"Login" bundle: nil] instantiateViewControllerWithIdentifier: @"LoginView"];
            }
			break;
        }
        case 4:
            vc = [[UIStoryboard storyboardWithName:@"SalaryAnalysis" bundle:nil] instantiateViewControllerWithIdentifier:@"SalaryAnalysisView"];
            vc.navigationItem.title = @"查工资";
            break;
		case 5:
			vc = [[UIStoryboard storyboardWithName:@"Recruitment" bundle: nil] instantiateViewControllerWithIdentifier: @"RecruitmentListView"];
			break;
        case 6:
            vc = [[UIStoryboard storyboardWithName:@"GovernmentRecruitmentStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"GRListView"];
            break;
        case 7:
			vc = [[UIStoryboard storyboardWithName:@"Campus" bundle: nil] instantiateViewControllerWithIdentifier: @"CampusView"];
			break;
        case 8:
			vc = [[UIStoryboard storyboardWithName:@"EmploymentInformation" bundle: nil] instantiateViewControllerWithIdentifier: @"EIMainView"];
			break;
        case 9:
			vc = [[UIStoryboard storyboardWithName:@"More" bundle: nil] instantiateViewControllerWithIdentifier: @"MoreView"];
			break;
        default:
            return;
			break;
	}
	
	[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
															 withSlideOutAnimation:YES
																	 andCompletion:nil];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        return 43;
    }
    else {
        return 47;
    }
}

-(void)changeMenuItem:(int)item
{
    [self.tvMenu selectRowAtIndexPath:[NSIndexPath indexPathForRow:item inSection:0] animated:false scrollPosition:UITableViewScrollPositionNone];
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
    [_tvMenu release];
    [_tvMenu release];
    [super dealloc];
}

@end
