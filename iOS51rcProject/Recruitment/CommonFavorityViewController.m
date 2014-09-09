#import "CommonFavorityViewController.h"
#import "CustomPopup.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import <objc/runtime.h>
#import "RmInviteCpViewController.h"
#import "JobViewController.h"
#import "LoginViewController.h"
@interface CommonFavorityViewController ()<NetWebServiceRequestDelegate,UITableViewDataSource,UITableViewDelegate,CustomPopupDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NSMutableArray *jobListData;
@property int pageNumber;
@property (nonatomic, retain) NSString *jobType;
@property (nonatomic, retain) NSString *workPlace;
@property (nonatomic, retain) NSString *industry;
@property (nonatomic, retain) NSString *salary;
@property (nonatomic, retain) NSString *experience;
@property (nonatomic, retain) NSString *education;
@property (nonatomic, retain) NSString *employType;
@property (nonatomic, retain) NSString *keyWord;
@property (nonatomic, retain) NSString *rsType;
@property (nonatomic, retain) NSString *companySize;
@property (nonatomic, retain) NSString *welfare;
@property (nonatomic, retain) NSString *isOnline;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) UILabel *lbSearchResult;

@property (nonatomic, retain) CustomPopup *cPopup;
@end

@implementation CommonFavorityViewController

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
    checkedCpArray = [[NSMutableArray alloc] init];//选择的企业
    //设置导航标题(搜索条件)
    UIView *viewTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 125, 45)];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, viewTitle.frame.size.width, 20)];
    [lbTitle setFont:[UIFont systemFontOfSize:12]];
    [lbTitle setTextAlignment:NSTextAlignmentCenter];
    //    [viewTitle setBackgroundColor:[UIColor blueColor]];
    [viewTitle addSubview:lbTitle];
    //设置导航标题(搜索结果)
    self.lbSearchResult = [[[UILabel alloc] initWithFrame:CGRectMake(0, 22, viewTitle.frame.size.width, 20)] autorelease];
    [self.lbSearchResult setText:@"正在获取职位列表"];
    [self.lbSearchResult setFont:[UIFont systemFontOfSize:10]];
    [self.lbSearchResult setTextAlignment:NSTextAlignmentCenter];
    [viewTitle addSubview:self.lbSearchResult];
    [self.navigationItem setTitleView:viewTitle];
    [viewTitle release];
    [lbTitle release];
    //设置底部功能栏
    self.btnApply.layer.cornerRadius = 5;
    self.viewBottom.layer.borderWidth = 1.0;
    self.viewBottom.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    [self.btnApply addTarget:self action:@selector(jobApply) forControlEvents:UIControlEventTouchUpInside];
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //添加上拉加载更多
    [self.tvJobList addFooterWithTarget:self action:@selector(footerRereshing)];
    //不显示列表分隔线
    self.tvJobList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self onSearch];
}

- (void)onSearch
{
    if (self.pageNumber == 1) {
        [self.jobListData removeAllObjects];
        [self.tvJobList reloadData];
        //开始等待动画
        [loadView startAnimating];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *code = [userDefaults objectForKey:@"code"];
    NSString *userID = [userDefaults objectForKey:@"UserID"];
    
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:@"20" forKey:@"pageSize"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.pageNumber] forKey:@"pageNum"];
    [dicParam setObject:@"0" forKey:@"cvMainID"];
    [dicParam setObject:userID forKey:@"paMainID"];
    [dicParam setObject:code forKey:@"code"];
    
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetExJobApply" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 1;
    self.runningRequest = request;
    [dicParam release];
}

- (void)footerRereshing{
    self.pageNumber++;
    [self onSearch];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSMutableArray *)requestData
{
    if (request.tag == 1) { //职位搜索
        if(self.pageNumber == 1){
            [self.jobListData removeAllObjects];
            self.jobListData = requestData;
        }
        else{
            [self.jobListData addObjectsFromArray:requestData];
        }
        [self.tvJobList footerEndRefreshing];
        //重新加载列表
        [self.tvJobList reloadData];
    }
    //结束等待动画
    [loadView stopAnimating];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.jobListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont *fontCell = [UIFont systemFontOfSize:12];
    UIColor *colorText = [UIColor colorWithRed:120.f/255.f green:120.f/255.f blue:120.f/255.f alpha:1];
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"jobList"] autorelease];
    NSDictionary *rowData = self.jobListData[indexPath.row];
    
    RmCpMain *cpMain = [[RmCpMain alloc] init];
    [cpMain retain];
    
    int isBooked = 0;
    //用于选择时，传入邀请企业参会页面
    cpMain.IsBooked = isBooked;
    cpMain.ID = rowData[@"cpMainID"];
    cpMain.Name = rowData[@"cpName"];
    //cpMain.Address = rowData[@"Address"];
    //cpMain.OrderDate = rowData[@"AddDate"];
    //cpMain.Lat = rowData[@"Lat"];
    //cpMain.Lng = rowData[@"Lng"];
    cpMain.jobID = rowData[@"EnJobID"];
    cpMain.caMainID = rowData[@"caMainID"];
    cpMain.JobName = rowData[@"JobName"];
    
    //职位名称
    UILabel *lbJobName = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, 200, 20)];
    [lbJobName setText:rowData[@"JobName"]];
    [lbJobName setFont:[UIFont systemFontOfSize:14]];
    [cell.contentView addSubview:lbJobName];
    [lbJobName release];
    
    //是否在线
    if ([rowData[@"IsOnline"] isEqualToString:@"true"]) {
        
        UIImageView *imgOnline = [[UIImageView alloc] initWithFrame:CGRectMake(275, 5, 40, 20)];
        [imgOnline setImage:[UIImage imageNamed:@"ico_joblist_online.png"]];
        [cell.contentView addSubview:imgOnline];
        [imgOnline release];
    }
    
    //公司名称
    UILabel *lbCompanyName = [[UILabel alloc] initWithFrame:CGRectMake(40, 28, 200, 20)];
    [lbCompanyName setText:rowData[@"cpName"]];
    [lbCompanyName setFont:fontCell];
    [lbCompanyName setTextColor:colorText];
    [cell.contentView addSubview:lbCompanyName];
    [lbCompanyName release];
    
    //刷新时间
    UILabel *lbRefreshDate = [[UILabel alloc] initWithFrame:CGRectMake(240, 28, 75, 20)];
    [lbRefreshDate setText:[CommonController stringFromDate:[CommonController dateFromString:rowData[@"RefreshDate"]] formatType:@"MM-dd HH:mm"]];
    [lbRefreshDate setFont:fontCell];
    [lbRefreshDate setTextColor:colorText];
    [lbRefreshDate setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbRefreshDate];
    [lbRefreshDate release];
    
    //地区|学历
    NSString *strRegionAndEducation = [NSString stringWithFormat:@"%@|%@",[CommonController getDictionaryDesc:rowData[@"dcRegionID"] tableName:@"dcRegion"],[CommonController getDictionaryDesc:rowData[@"dcEducationID"] tableName:@"dcEducation"]];
    UILabel *lbRegionAndEducation = [[UILabel alloc] initWithFrame:CGRectMake(40, 51, 200, 20)];
    [lbRegionAndEducation setText:strRegionAndEducation];
    [lbRegionAndEducation setFont:fontCell];
    [lbRegionAndEducation setTextColor:colorText];
    [cell.contentView addSubview:lbRegionAndEducation];
    [lbRegionAndEducation release];
    
    //月薪
    NSString *strSalary = [CommonController getDictionaryDesc:rowData[@"dcSalaryID"] tableName:@"dcSalary"];
    if (strSalary.length == 0) {
        strSalary = @"面议";
    }
    UILabel *lbSalary = [[UILabel alloc] initWithFrame:CGRectMake(240, 51, 75, 20)];
    [lbSalary setText:strSalary];
    [lbSalary setFont:fontCell];
    [lbSalary setTextColor:[UIColor redColor]];
    [lbSalary setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbSalary];
    [lbSalary release];
    
    //复选框
    UIButton *btnCheck = [[UIButton alloc] initWithFrame:CGRectMake(10, 30, 20, 20)];
    [btnCheck setImage:[UIImage imageNamed:@"chk_default.png"] forState:UIControlStateNormal];
    [btnCheck setTitle:rowData[@"ID"] forState:UIControlStateNormal];
    [btnCheck setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [btnCheck setTag:1];
    objc_setAssociatedObject(btnCheck, "rmCpMain", cpMain, OBJC_ASSOCIATION_RETAIN_NONATOMIC);//传递对象
    [btnCheck addTarget:self action:@selector(rowChecked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnCheck];
    [btnCheck release];
    
    //分割线
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, 76, 320, 1)];
    [viewSeparate setBackgroundColor:[UIColor lightGrayColor]];
    [cell.contentView addSubview:viewSeparate];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 77;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rowData = self.jobListData[indexPath.row];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"JobSearch" bundle:nil];
    JobViewController *jobC = [storyBoard instantiateViewControllerWithIdentifier:@"JobView"];
    jobC.JobID = rowData[@"ID"];
    [self.navigationController pushViewController:jobC animated:YES];
}

- (void)rowChecked:(UIButton *)sender
{
    RmCpMain *selectCp = (RmCpMain*)objc_getAssociatedObject(sender, "rmCpMain");
    if (sender.tag == 1) {
        [checkedCpArray addObject:(selectCp)];
        [sender setImage:[UIImage imageNamed:@"chk_check.png"] forState:UIControlStateNormal];
        [sender setTag:2];
    }
    else {
        [checkedCpArray removeObject:(selectCp)];
        [sender setImage:[UIImage imageNamed:@"chk_default.png"] forState:UIControlStateNormal];
        [sender setTag:1];
    }
    //NSLog(@"%@",[self.arrCheckJobID componentsJoinedByString:@","]);
}

- (void)jobApply
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"UserID"]) {
        RmInviteCpViewController *rmInviteCpViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"RmInviteCpView"];
        rmInviteCpViewCtrl.strBeginTime = self.strBeginTime;
        rmInviteCpViewCtrl.strAddress = self.strAddress;
        rmInviteCpViewCtrl.strPlace = self.strPlace;
        rmInviteCpViewCtrl.strRmID = self.rmID;
        rmInviteCpViewCtrl.selectRmCps = checkedCpArray;
        [checkedCpArray retain];
        [self.navigationController pushViewController:rmInviteCpViewCtrl animated:YES];
    }
    else {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        LoginViewController *loginC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginView"];
        [self.navigationController pushViewController:loginC animated:true];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [_runningRequest release];
    [_jobType release];
    [_workPlace release];
    [_industry release];
    [_salary release];
    [_experience release];
    [_education release];
    [_employType release];
    [_keyWord release];
    [_rsType release];
    [_companySize release];
    [_welfare release];
    [_isOnline release];
    [_tvJobList release];
    [_lbSearchResult release];
    [_btnApply release];
    [_viewBottom release];
    [_cPopup release];
    [super dealloc];
}
@end
