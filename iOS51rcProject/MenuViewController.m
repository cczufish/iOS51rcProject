#import "MenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"

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
    self.tvMenu = [[[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, 600)] autorelease];
    self.tvMenu.delegate = self;
    self.tvMenu.dataSource = self;
    [self.tvMenu setBackgroundColor:[UIColor clearColor]];
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
            lbTitle.text = @"点击登陆";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_head.png"]];
            ivTitle.frame = CGRectMake(35, 3, 40, 40);
            break;
        case 1:
            lbTitle.text = @"首页";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_index.png"]];
            ivTitle.frame = CGRectMake(45, 10, 25, 25);
            break;
        case 2:
            lbTitle.text = @"职位搜索";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_search.png"]];
            ivTitle.frame = CGRectMake(45, 10, 25, 25);
            break;
        case 3:
            lbTitle.text = @"会员中心";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_mebercenter.png"]];
            ivTitle.frame = CGRectMake(45, 10, 25, 25);
            break;
        case 4:
            lbTitle.text = @"查工资";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_salary.png"]];
            ivTitle.frame = CGRectMake(45, 10, 25, 25);
            break;
        case 5:
            lbTitle.text = @"招聘会";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_rm.png"]];
            ivTitle.frame = CGRectMake(45, 10, 25, 25);
            break;
        case 6:
            lbTitle.text = @"政府招考";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_govnews.png"]];
            ivTitle.frame = CGRectMake(45, 10, 25, 25);
            break;
        case 7:
            lbTitle.text = @"校园招聘";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_campus.png"]];
            ivTitle.frame = CGRectMake(45, 14, 25, 21);
            break;
        case 8:
            lbTitle.text = @"就业资讯";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_jobnews.png"]];
            ivTitle.frame = CGRectMake(45, 12, 25, 23);
            break;
        case 9:
            lbTitle.text = @"更多";
            [ivTitle setImage:[UIImage imageNamed:@"ico_leftmenu_more.png"]];
            ivTitle.frame = CGRectMake(45, 14, 25, 18);
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
        UIView *viewSelect = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 7, 48)] autorelease];
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
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Home" bundle: nil];
	UIViewController *vc;
	
	switch (indexPath.row)
	{
		case 1:
			[[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
			return;
			break;
        case 2:
			vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"SearchView"];
			break;
		case 5:
			vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"RecruitmentListView"];
			break;
        default:
            [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
			return;
			break;
	}
	
	[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
															 withSlideOutAnimation:YES
																	 andCompletion:nil];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47;
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
    [super dealloc];
}

@end
