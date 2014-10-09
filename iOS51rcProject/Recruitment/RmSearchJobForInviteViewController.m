#import "RmSearchJobForInviteViewController.h"
#import "CommonSearchJobViewController.h"
#import "CommonApplyJobViewController.h"
#import "CommonFavorityViewController.h"
#import "RMSearchJobListViewController.h"
#import "RmInviteCpViewController.h"
#define MENUHEIHT 40
@interface RmSearchJobForInviteViewController ()<UIScrollViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *lbUnderline;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UILabel *lbFirst;
@property (retain, nonatomic) IBOutlet UILabel *lbSecond;
@property (retain, nonatomic) IBOutlet UILabel *lbThird;


//三个子页面
@property (retain, nonatomic) CommonSearchJobViewController *firstCtrl;
@property (retain, nonatomic) CommonApplyJobViewController *sccondCtrl;
@property (retain, nonatomic) CommonFavorityViewController *thirdCtrl;

@property (retain, nonatomic) NSString *employId;
@property (retain, nonatomic) NSString *companyId;

@end

@implementation RmSearchJobForInviteViewController
#define HEIGHT [[UIScreen mainScreen] bounds].size.height
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
    firstPageLoad = false;
    secondPageLoad = false;
    thriePageLoad = false;
    
    self.navigationItem.title = @"邀请企业参会";
    //初始化三个子View
    self.firstCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"CommonSearchJobView"];
    self.firstCtrl.view.frame = CGRectMake(0, 0, 320, HEIGHT);
    self.sccondCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"CommonApplyJobView"];
    self.sccondCtrl.view.frame = CGRectMake(320, 0, 320, HEIGHT);
    self.thirdCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"CommonFavorityView"];
    self.thirdCtrl.view.frame = CGRectMake(640, 0, 320, HEIGHT);
    //把三个子View加到Scrollview中
    [self.scrollView addSubview:self.firstCtrl.view];
    [self.scrollView addSubview:self.sccondCtrl.view];
    [self.scrollView addSubview:self.thirdCtrl.view];
    
    //代理
    self.scrollView.delegate = self;
    self.firstCtrl.searchDelegate = self;
    self.sccondCtrl.inviteFromApplyViewDelegate = self;
    self.thirdCtrl.InviteJobsFromFavorityViewDelegate = self;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    //self.scrollView.frame =  CGRectMake(0, 0, 320, HEIGHT);
    [self.scrollView setContentSize:CGSizeMake(960, self.scrollView.frame.size.height)];
   }

- (IBAction)switchToFirstView:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:true];
    
    if (!firstPageLoad) {
        //[self.firstCtrl onSearch];
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbThird setTextColor:[UIColor blackColor]];
        [self.lbSecond setTextColor:[UIColor blackColor]];
        [self.lbFirst setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbUnderline setFrame:CGRectMake(0, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
    } completion:^(BOOL finished) {
        firstPageLoad = true;
    }];
}

- (IBAction)switchToSecondView:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(320, 0) animated:true];
    if (!secondPageLoad) {
        [self.sccondCtrl onSearch];
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbThird setTextColor:[UIColor blackColor]];
        [self.lbFirst setTextColor:[UIColor blackColor]];
        [self.lbSecond setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbUnderline setFrame:CGRectMake(106, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
    } completion:^(BOOL finished) {
        secondPageLoad = true;
    }];
}

- (IBAction)switchToThirdView:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(640, 0) animated:true];
    if (!thriePageLoad) {
        [self.thirdCtrl onSearch];
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbFirst setTextColor:[UIColor blackColor]];
        [self.lbSecond setTextColor:[UIColor blackColor]];
        [self.lbThird setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbUnderline setFrame:CGRectMake(214, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
    } completion:^(BOOL finished) {
        thriePageLoad = true;
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.toastType == 1) {
        [self.view makeToast:@"邀请成功！"];
    }
    
    self.toastType = 0;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollView.contentOffset.x > 480) {
        [self switchToThirdView:nil];
    }
    else if (self.scrollView.contentOffset.x > 160) {
        [self switchToSecondView:nil];
    }
    else {
        [self switchToFirstView:nil];
    }
}

//搜索职位的代理
-(void) gotoJobSearchResultListView:(NSString *)strSearchRegion SearchJobType:(NSString *)strSearchJobType SearchIndustry:(NSString *)strSearchIndustry SearchKeyword:(NSString *)strSearchKeyword SearchRegionName:(NSString *)strSearchRegionName SearchJobTypeName:(NSString *)strSearchJobTypeName SearchCondition:(NSString *)strSearchCondition{
    RMSearchJobListViewController *jobList = [self.storyboard instantiateViewControllerWithIdentifier: @"RMSearchJobListView"];
    jobList.searchRegion = strSearchRegion;
    jobList.searchJobType = strSearchJobType;
    jobList.searchIndustry = strSearchIndustry;
    jobList.searchKeyword = strSearchKeyword;
    jobList.searchRegionName = strSearchRegionName;
    jobList.searchJobTypeName = strSearchJobTypeName;
    jobList.searchCondition = strSearchCondition;
    //招聘会的基本信息
    jobList.strPlace = self.strPlace;
    jobList.strAddress = self.strAddress;
    jobList.strBeginTime = self.strBeginTime;
    jobList.rmID = self.rmID;
    [self.navigationController pushViewController:jobList animated:true];
    jobList.navigationItem.title = @"邀请企业参会";
}

//收藏职位页面的代理
-(void) InviteJobsFromFavorityView:(NSMutableArray *)checkedCps{
    UIStoryboard *rmStoryboard = [UIStoryboard storyboardWithName:@"Recruitment" bundle:nil];
    RmInviteCpViewController *rmInviteCpViewCtrl = [rmStoryboard instantiateViewControllerWithIdentifier:@"RmInviteCpView"];
    rmInviteCpViewCtrl.strBeginTime = self.strBeginTime;
    rmInviteCpViewCtrl.strAddress = self.strAddress;
    rmInviteCpViewCtrl.strPlace = self.strPlace;
    rmInviteCpViewCtrl.strRmID = self.rmID;
    rmInviteCpViewCtrl.selectRmCps = checkedCps;
    [self.navigationController pushViewController:rmInviteCpViewCtrl animated:YES];
}

//申请职位页面的代理代理
-(void) InviteJobsFromApplyView:(NSMutableArray *)checkedCps{
    //得到父View
    UIStoryboard *rmStoryboard = [UIStoryboard storyboardWithName:@"Recruitment" bundle:nil];
    RmInviteCpViewController *rmInviteCpViewCtrl = [rmStoryboard instantiateViewControllerWithIdentifier:@"RmInviteCpView"];
    rmInviteCpViewCtrl.strBeginTime = self.strBeginTime;
    rmInviteCpViewCtrl.strAddress = self.strAddress;
    rmInviteCpViewCtrl.strPlace = self.strPlace;
    rmInviteCpViewCtrl.strRmID = self.rmID;
    rmInviteCpViewCtrl.selectRmCps = checkedCps;    
    [self.navigationController pushViewController:rmInviteCpViewCtrl animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_firstCtrl release];
    [_sccondCtrl release];
    [_thirdCtrl release];
    [_lbUnderline release];
    [_scrollView release];
    [_employId release];
    [_companyId release];
    [_lbFirst release];
    [_lbSecond release];
    [_lbThird release];
    [super dealloc];
}
@end
