#import "CommonApplyJobViewController.h"
#import "CustomPopup.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import <objc/runtime.h> 
#import "RmInviteCpViewController.h"
#import "JobViewController.h"
#import "LoginViewController.h"
#import "RmSearchJobForInviteViewController.h"
#import "DictionaryPickerView.h"

@interface CommonApplyJobViewController ()<NetWebServiceRequestDelegate,UITableViewDataSource,UITableViewDelegate,CustomPopupDelegate, DictionaryPickerDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NSMutableArray *jobListData;
@property (nonatomic, retain) NSMutableArray *cvList;
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
@property (nonatomic, retain) NetWebServiceRequest *runningRequestGetCvList;
@property (nonatomic, retain) UILabel *lbSearchResult;
@property (retain, nonatomic) IBOutlet UILabel *lbApplyInfo;
@property (retain, nonatomic) IBOutlet UIButton *btnTop;//选择简历按钮

@property (retain, nonatomic) IBOutlet UIView *viewTop;
@property (nonatomic, retain) CustomPopup *cPopup;
@property (strong, nonatomic) DictionaryPickerView *DictionaryPicker;
@end

@implementation CommonApplyJobViewController
@synthesize inviteFromApplyViewDelegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}
-(void)cancelDicPicker
{
    [self.DictionaryPicker cancelPicker];
    self.DictionaryPicker.delegate = nil;
    self.DictionaryPicker = nil;
    
    //切换背景图片
    UIImageView *imgCornor = self.btnTop.subviews[1];
    imgCornor.image = [UIImage imageNamed:@"ico_triangle.png"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.automaticallyAdjustsScrollViewInsets = NO;
    self.pageNumber = 1;
    //最上面提示信息的边框
    self.viewTop.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.viewTop.layer.borderWidth = 1;
    self.btnTop.titleLabel.text = @"相关简历";
    self.btnTop.titleLabel.font = [UIFont systemFontOfSize:12];
    self.btnTop.layer.borderWidth = 0.5;
    self.btnTop.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self.btnTop addTarget:self action:@selector(selectCV:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imgCornor = [[[UIImageView alloc] initWithFrame:CGRectMake(65, 20, 10, 10)] autorelease];
    imgCornor.image = [UIImage imageNamed:@"ico_triangle.png"];
    [self.btnTop addSubview:imgCornor];
    
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
    //获取简历列表
    [self GetBasicCvList];
    selectCV = @"";
    //[self onSearch:selectCV];//默认选择全部
}

//获得简历列表
-(void) GetBasicCvList{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *code = [userDefaults objectForKey:@"code"];
    NSString *userID = [userDefaults objectForKey:@"UserID"];
   
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:userID forKey:@"paMainID"];
    [dicParam setObject:code forKey:@"code"];
    
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetBasicCvListByPaMainID" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 2;
    self.runningRequestGetCvList = request;
    [dicParam release];

}

//选择简历
-(void) selectCV:(UIButton*) sender{
    UIImageView *imgCornor = sender.subviews[1];
    imgCornor.image = [UIImage imageNamed:@"ico_triangle_orange.png"];
    [self cancelDicPicker];
    
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithDictionary:self defaultArray:self.cvList defalutValue:@"0" defalutName:@"相关简历" pickerMode:DictionaryPickerModeOne] autorelease];
    self.DictionaryPicker.frame = CGRectMake(self.DictionaryPicker.frame.origin.x, self.DictionaryPicker.frame.origin.y-50, self.DictionaryPicker.frame.size.width, self.DictionaryPicker.frame.size.height);
    [self.DictionaryPicker setTag:1];
    [self.DictionaryPicker showInView:self.view];
}

- (void)pickerDidChangeStatus:(DictionaryPickerView *)picker
                selectedValue:(NSString *)selectedValue
                 selectedName:(NSString *)selectedName
{
    switch (picker.tag) {
        case 1:
            if (selectedValue.length == 0) {
                [self.btnTop setTitle:@"相关简历" forState:UIControlStateNormal];
                selectCV = @"";
                //[self.view makeToast:@"工作地点不能为空"];
                return;
            }else{
                [self.btnTop setTitle:selectedName forState:UIControlStateNormal];
                selectCV = selectedValue;
            }
            
            [self onSearch:selectCV];
            break;
        default:
            break;
    }
    [self cancelDicPicker];
}

- (void)onSearch:(NSString *)cvMainID
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
    [dicParam setObject:cvMainID forKey:@"cvMainID"];
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
    [self onSearch:selectCV];
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
    }else if(request.tag == 2){
        NSMutableArray *arrCv = [[NSMutableArray alloc] init];
        NSDictionary *defalult = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                   @"0",@"id",
                                   @"相关简历",@"value"
                                   ,nil] autorelease];
        [arrCv addObject:defalult];
        for (int i = 0; i < requestData.count; i++) {
            NSDictionary *dicCv = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                       requestData[i][@"ID"],@"id",
                                       requestData[i][@"Name"],@"value"
                                       ,nil] autorelease];
            [arrCv addObject:dicCv];
        }
        
        self.cvList = arrCv;
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
    cpMain.ID = rowData[@"EnCpMainID"];
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
        UIImageView *imgOnline = [[UIImageView alloc] initWithFrame:CGRectMake(260, 5, 40, 20)];
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
    UILabel *lbRefreshDate = [[UILabel alloc] initWithFrame:CGRectMake(40, 48, 160, 20)];
    NSString *addDate = [CommonController stringFromDate:[CommonController dateFromString:rowData[@"AddDate"]] formatType:@"MM-dd HH:mm"];
    addDate = [NSString stringWithFormat:@"申请时间：%@", addDate];
    [lbRefreshDate setText:addDate];
    [lbRefreshDate setTextColor:colorText];
    lbRefreshDate.font = [UIFont systemFontOfSize:12];
    [lbRefreshDate setTextAlignment:NSTextAlignmentLeft];
    [cell.contentView addSubview:lbRefreshDate];
    [lbRefreshDate release];
    
    //右侧的邀请按钮和图片
    UIButton *btnInvite = [[[UIButton alloc] initWithFrame:CGRectMake(255, 30, 40, 60)] autorelease];
    objc_setAssociatedObject(btnInvite, "rmCpMain", cpMain, OBJC_ASSOCIATION_RETAIN_NONATOMIC);//传递对象
    [btnInvite addTarget:self action:@selector(inviteOneCp:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imgInvite = [[[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 20, 20)] autorelease];
    imgInvite.image = [UIImage imageNamed:@"ico_rm_head.png"];
    [btnInvite addSubview:imgInvite];
    
    UILabel *lbInvite = [[[UILabel alloc] initWithFrame:CGRectMake(10, 22, 40, 20)] autorelease];
    lbInvite.font = [UIFont systemFontOfSize:12];
    lbInvite.text = @"邀请";
    lbInvite.textColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
    [btnInvite addSubview:lbInvite];
    [cell.contentView addSubview:btnInvite];
    
    //复选框
    UIButton *btnCheck = [[UIButton alloc] initWithFrame:CGRectMake(10, 30, 20, 20)];
    [btnCheck setImage:[UIImage imageNamed:@"chk_default.png"] forState:UIControlStateNormal];
    [btnCheck setTitle:rowData[@"JobID"] forState:UIControlStateNormal];
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
    jobC.JobID = rowData[@"JobID"];
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
}

//邀请一个企业
-(void) inviteOneCp:(UIButton*)sender{
    RmCpMain *selectCp = (RmCpMain*)objc_getAssociatedObject(sender, "rmCpMain");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"UserID"]) {
        [checkedCpArray removeAllObjects];
        [checkedCpArray addObject:selectCp];
        [inviteFromApplyViewDelegate InviteJobsFromApplyView:checkedCpArray];
    }
    else {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        LoginViewController *loginC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginView"];
        [self.navigationController pushViewController:loginC animated:true];
    }
}

//批量邀请
- (void)jobApply
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"UserID"]) {          
        [inviteFromApplyViewDelegate InviteJobsFromApplyView:checkedCpArray];        
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
}


//得到父View
- (UIViewController *)getFatherController
{
    for (UIView* next = [self.view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    
    return nil;
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
    [_lbApplyInfo release];
    [_viewTop release];
    [_btnTop release];
    [super dealloc];
}
@end
