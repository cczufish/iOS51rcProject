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
#import "SalaryAnalysisViewController.h"
#import "BMapKit.h"
#import "NetWebServiceRequest.h"

@interface HomeViewController() <SlideNavigationControllerDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,NetWebServiceRequestDelegate>
@property (retain, nonatomic) BMKLocationService *locService;
@property (retain, nonatomic) BMKGeoCodeSearch *geocodesearch;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NetWebServiceRequest *runningRequestPic;
@property (nonatomic, retain) NetWebServiceRequest *runningRequestSql;
@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, retain) NSString *titleUrl;
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.toastType == 1) {
        [self.view makeToast:@"账号已退出"];
    }
    else if (self.toastType == 2) {
        [self.view makeToast:@"登录成功"];
    }
    self.toastType = 0;
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *titleViews = self.viewTitle.subviews;
    UIButton *btnSubSite = titleViews[0];
    [btnSubSite setTitle:[self.userDefaults objectForKey:@"subSiteName"] forState:UIControlStateNormal];
    UIView *btnSearch = titleViews[1];
    btnSearch.layer.cornerRadius = 5;
    [self getSQL];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //第一次进入home获取地理位置，和主页头部图片
    if ([[self.userDefaults objectForKey:@"firstToHome"] boolValue] == YES) {
        [self getLauncherPic];
        self.locService = [[BMKLocationService alloc] init];
        self.locService.delegate = self;
        //开始定位
        [self.locService startUserLocationService];
        [self.view makeToast:@"正在定位..."];
        [self.userDefaults setBool:NO forKey:@"firstToHome"];
        [self.userDefaults synchronize];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.locService.delegate = nil;
    self.geocodesearch.delegate = nil;
}

- (void)getLauncherPic
{
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[self.userDefaults objectForKey:@"subSiteId"] forKey:@"regionID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetLauncherPic" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 2;
    self.runningRequestPic = request;
    [dicParam release];
}

- (void)getSQL
{
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[self.userDefaults objectForKey:@"sqlVersion"] forKey:@"version"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetSQLByVersion" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 3;
    self.runningRequestSql = request;
    [dicParam release];
}

//定位完成后执行此方法，将定位的位置添加到地图上
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    [self.locService stopUserLocationService];
    [self getAddress:userLocation.location.coordinate];
}

//根据坐标获取地理位置
- (void)getAddress:(CLLocationCoordinate2D) pt
{
    self.geocodesearch = [[[BMKGeoCodeSearch alloc] init] autorelease];
    self.geocodesearch.delegate = self;
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [self.geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    [reverseGeocodeSearchOption release];
    if(!flag)
    {
        [self.view makeToast:@"获取地理位置失败"];
    }
}

//根据坐标获取地理位置成功执行此方法
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        NSLog(@"%@",result.address);
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setObject:result.address forKey:@"address"];
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetSubSiteByAddress" Params:dicParam];
        [request setDelegate:self];
        [request startAsynchronous];
        request.tag = 1;
        self.runningRequest = request;
        [dicParam release];
    }
    else {
        [self.view makeToast:@"获取地理位置失败"];
    }
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    if (request.tag == 1) {
        if (requestData.count > 0) {
            NSArray *titleViews = self.viewTitle.subviews;
            UIButton *btnSubSite = titleViews[0];
            [btnSubSite setTitle:requestData[0][@"SubSiteName"] forState:UIControlStateNormal];
            [self.view makeToast:[NSString stringWithFormat:@"已切换到%@",requestData[0][@"SubSiteName"]]];
            [self.userDefaults setValue:requestData[0][@"ID"] forKey:@"subSiteId"];
            [self.userDefaults setValue:requestData[0][@"SubSiteName"] forKey:@"subSiteName"];
            [self.userDefaults setValue:requestData[0][@"SubSIteCity"] forKey:@"subSiteCity"];
            [self.userDefaults setValue:[NSString stringWithFormat:@"http://%@",requestData[0][@"SubSiteUrl"]] forKey:@"subSiteUrl"];
            [self.userDefaults synchronize];
        }
    }
    else if (request.tag == 2) {
        if (requestData.count > 0) {
            //首页的头部图片更改
            if ([requestData[0][@"Type"] isEqualToString:@"24"]) {
                NSString *strUrl = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/operational/hpimage/%@",requestData[0][@"ImageFile"]];
                [self.imgHomeTitle setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:strUrl]]]];
                
                //如果有url，添加点击事件
                if (requestData[0][@"Url"]) {
                    self.imgHomeTitle.userInteractionEnabled = YES;
                    self.titleUrl = requestData[0][@"Url"];
                    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToUrl)];
                    [self.imgHomeTitle addGestureRecognizer:singleTap];
                    [singleTap release];
                }
            }
        }
    }
    else {
        if (result.length > 0) {
            NSArray *arrResult = [result componentsSeparatedByString:@"##$$"];
            NSString *strVersion = arrResult[0];
            NSString *strSql = arrResult[1];
            NSArray *arrSql = [strSql componentsSeparatedByString:@"@@!!"];
            for (NSString *sql in arrSql) {
                [CommonController execSql:sql];
            }
            [self.userDefaults setValue:strVersion forKey:@"sqlVersion"];
            NSLog(@"%@",result);
        }
    }
}

-(void)goToUrl
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.titleUrl]];
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

//点击查工资
- (IBAction)btnSalaryAnalysisClick:(id)sender {
    UIStoryboard *storyMore = [UIStoryboard storyboardWithName:@"SalaryAnalysis" bundle:nil];
    SalaryAnalysisViewController *saCtrl = [storyMore instantiateViewControllerWithIdentifier:@"SalaryAnalysisView"];
    saCtrl.navigationItem.title = @"查工资";
    [self.navigationController pushViewController:saCtrl animated:true];
}

//点击更多
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

- (void)dealloc {
    [_runningRequestPic release];
    [_runningRequestSql release];
    [_runningRequest release];
    [_viewTitle release];
    [_locService release];
    [_geocodesearch release];
    [_userDefaults release];
    [_imgHomeTitle release];
    [_titleUrl release];
    [super dealloc];
}
@end
