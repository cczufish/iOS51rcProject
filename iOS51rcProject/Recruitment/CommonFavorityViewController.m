#import "CommonFavorityViewController.h"
#import "CustomPopup.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import <objc/runtime.h>
#import "RmInviteCpViewController.h"
#import "SuperJobMainViewController.h"
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
@synthesize InviteJobsFromFavorityViewDelegate;
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
    self.pageNumber = 1;
    checkedCpArray = [[NSMutableArray alloc] init];//选择的企业
    //设置导航标题(搜索条件)
    UIView *viewTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 125, 45)];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, viewTitle.frame.size.width, 20)];
    [lbTitle setFont:[UIFont systemFontOfSize:14]];
    [lbTitle setTextAlignment:NSTextAlignmentCenter];
   
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
    self.viewBottom.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    [self.btnApply addTarget:self action:@selector(jobInviteAll) forControlEvents:UIControlEventTouchUpInside];
   
    //添加上拉加载更多
    [self.tvJobList addFooterWithTarget:self action:@selector(footerRereshing)];
    //不显示列表分隔线
    self.tvJobList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //[self onSearch];
}

- (void)onSearch
{
    if (self.pageNumber == 1) {
        [self.jobListData removeAllObjects];
        [self.tvJobList reloadData];
    }
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    [loadView startAnimating];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *code = [userDefaults objectForKey:@"code"];
    NSString *userID = [userDefaults objectForKey:@"UserID"];
    
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:@"20" forKey:@"pageSize"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.pageNumber] forKey:@"pageNum"];
    [dicParam setObject:userID forKey:@"paMainID"];
    [dicParam setObject:code forKey:@"code"];
    
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetPaFavorateListByPaMainID" Params:dicParam];
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
    UIFont *fontCell = [UIFont systemFontOfSize:14];
    UIColor *colorText = [UIColor colorWithRed:120.f/255.f green:120.f/255.f blue:120.f/255.f alpha:1];
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"jobList"] autorelease];
    NSDictionary *rowData = self.jobListData[indexPath.row];
    
    RmCpMain *cpMain = [[[RmCpMain alloc] init] autorelease];
    [cpMain retain];
    
    int isBooked = 0;
    //用于选择时，传入邀请企业参会页面
    cpMain.IsBooked = isBooked;
    cpMain.ID = rowData[@"cpID"];
    cpMain.Name = rowData[@"cpName"];
    cpMain.jobID = rowData[@"JobID"];
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
    
    //月薪
    NSString *strSalary = [CommonController getDictionaryDesc:rowData[@"dcSalaryID"] tableName:@"dcSalary"];
    if (strSalary.length == 0) {
        strSalary = @"面议";
    }
   
    UILabel *lbPreSalary = [[[UILabel alloc] initWithFrame:CGRectMake(40, 48, 50, 20)] autorelease];
    lbPreSalary.text = @"薪水：";
    lbPreSalary.textAlignment = NSTextAlignmentLeft;
    lbPreSalary.textColor = [UIColor grayColor];
    lbPreSalary.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:lbPreSalary];
    
    UILabel *lbSalary = [[UILabel alloc] initWithFrame:CGRectMake(90, 48, 160, 20)];
    [lbSalary setText:strSalary];
    [lbSalary setFont:fontCell];
    lbSalary.textColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
    [lbSalary setTextAlignment:NSTextAlignmentLeft];
    [cell.contentView addSubview:lbSalary];
    [lbSalary release];
    
    //刷新时间
    UILabel *lbRefreshDate = [[UILabel alloc] initWithFrame:CGRectMake(40, 68, 160, 20)];
    NSString *strTime = [CommonController stringFromDate:[CommonController dateFromString:rowData[@"AddDate"]] formatType:@"MM-dd HH:mm"];
    strTime = [NSString stringWithFormat:@"收藏时间：%@", strTime];
    [lbRefreshDate setText:strTime];
    [lbRefreshDate setFont:[UIFont systemFontOfSize:14]];
    [lbRefreshDate setTextColor:colorText];
    [lbRefreshDate setTextAlignment:NSTextAlignmentLeft];
    [cell.contentView addSubview:lbRefreshDate];
    [lbRefreshDate release];
    //复选框
    UIButton *btnCheck = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 77)];
    [btnCheck setTitle:rowData[@"ID"] forState:UIControlStateNormal];
    [btnCheck setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [btnCheck setTag:1];
    objc_setAssociatedObject(btnCheck, "rmCpMain", cpMain, OBJC_ASSOCIATION_RETAIN_NONATOMIC);//传递对象
    [btnCheck addTarget:self action:@selector(rowChecked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imgCheck = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 20, 20)];
    [imgCheck setImage:[UIImage imageNamed:@"chk_default.png"]];
    [btnCheck addSubview:imgCheck];
    for (RmCpMain *cpMain in checkedCpArray) {
        if ([cpMain.ID isEqualToString:rowData[@"cpMainID"]]) {
            [imgCheck setImage:[UIImage imageNamed:@"chk_check.png"]];
            [btnCheck setTag:2];
        }
    }
    //    if ([checkedCpArray containsObject:rowData[@"ID"]]) {
    //        [imgCheck setImage:[UIImage imageNamed:@"chk_check.png"]];
    //        [btnCheck setTag:2];
    //    }
    
    [imgCheck release];
    [cell.contentView addSubview:btnCheck];
    [btnCheck release];
    
    //右侧的邀请按钮和图片
    UIButton *btnInvite = [[[UIButton alloc] initWithFrame:CGRectMake(260, 10, 50, 80)] autorelease];
    objc_setAssociatedObject(btnInvite, "rmCpMain", cpMain, OBJC_ASSOCIATION_RETAIN_NONATOMIC);//传递对象
    [btnInvite addTarget:self action:@selector(inviteOneCp:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imgInvite = [[[UIImageView alloc] initWithFrame:CGRectMake(25, 30, 25, 25)] autorelease];
    imgInvite.image = [UIImage imageNamed:@"ico_rm_head.png"];
    [btnInvite addSubview:imgInvite];
    
    UILabel *lbInvite = [[[UILabel alloc] initWithFrame:CGRectMake(26, 57, 30, 12)] autorelease];
    lbInvite.font = [UIFont systemFontOfSize:12];
    lbInvite.text = @"邀请";
    lbInvite.textColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
    [btnInvite addSubview:lbInvite];
    [cell.contentView addSubview:btnInvite];
    
    //分割线
    UIView *viewSeparate = [[[UIView alloc] initWithFrame:CGRectMake(0, 89, 320, 1)] autorelease];
    [viewSeparate setBackgroundColor:[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1]];
    [cell.contentView addSubview:viewSeparate];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rowData = self.jobListData[indexPath.row];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CpAndJob" bundle:nil];
    SuperJobMainViewController *jobC = [storyBoard instantiateViewControllerWithIdentifier:@"SuperJobMainView"];
    jobC.JobID = rowData[@"JobID"];
    jobC.cpMainID = rowData[@"cpID"];   
    jobC.navigationItem.title = rowData[@"cpName"];
    [[CommonController getFatherController:self.view].navigationController pushViewController:jobC animated:YES];
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:false];
}

- (void)rowChecked:(UIButton *)sender
{
    UIImageView *imgCheck = sender.subviews[0];
    RmCpMain *selectCp = (RmCpMain*)objc_getAssociatedObject(sender, "rmCpMain");
    if (sender.tag == 1) {
        [checkedCpArray addObject:(selectCp)];
        [imgCheck setImage:[UIImage imageNamed:@"chk_check.png"]];
        [sender setTag:2];
    }
    else {
        [checkedCpArray removeObject:(selectCp)];
        [imgCheck setImage:[UIImage imageNamed:@"chk_default.png"]];
        [sender setTag:1];
    }
}


//邀请一个企业
-(void) inviteOneCp:(UIButton*)sender{
    RmCpMain *selectCp = (RmCpMain*)objc_getAssociatedObject(sender, "rmCpMain");
    NSMutableArray *tmpCheckArray = [[[NSMutableArray alloc] init] autorelease];
    [tmpCheckArray addObject:selectCp];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"UserID"]) {
        [InviteJobsFromFavorityViewDelegate InviteJobsFromFavorityView:tmpCheckArray];
    }
    else {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        LoginViewController *loginC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginView"];
        [self.navigationController pushViewController:loginC animated:true];
    }
}

- (void)jobInviteAll
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"UserID"]) {
        if (checkedCpArray.count>0) {
            [InviteJobsFromFavorityViewDelegate InviteJobsFromFavorityView:checkedCpArray];
        }else{
             UIViewController *pCtrl = [CommonController getFatherController:self.view];
            [pCtrl.view makeToast:@"至少选择一个职位申请"];
        }
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
