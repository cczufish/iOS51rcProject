#import "MapSearchListViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "MJRefresh.h"
#import "SearchPickerView.h"
#import "Toast+UIView.h"
#import "DictionaryPickerView.h"
#import "LoginViewController.h"
#import "CustomPopup.h"
#import "SuperJobMainViewController.h"

@interface MapSearchListViewController () <NetWebServiceRequestDelegate,UITableViewDataSource,UITableViewDelegate,SearchPickerDelegate,DictionaryPickerDelegate,CustomPopupDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NSMutableArray *jobListData;
@property int pageNumber;
@property (nonatomic, retain) NSString *jobType;
@property (nonatomic, retain) NSString *salary;
@property (nonatomic, retain) NSString *experience;
@property (nonatomic, retain) NSString *education;
@property (nonatomic, retain) NSString *employType;
@property (nonatomic, retain) NSString *rsType;
@property (nonatomic, retain) NSString *companySize;
@property (nonatomic, retain) NSString *welfare;
@property (nonatomic, retain) NSString *welfareName;
@property (nonatomic, retain) NSString *isOnline;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) UILabel *lbSearchResult;
@property (nonatomic, retain) SearchPickerView *searchPicker;
@property (nonatomic, retain) DictionaryPickerView *dictionaryPicker;
@property (nonatomic, retain) CustomPopup *cPopup;
@end

@implementation MapSearchListViewController

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
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.arrCheckJobID = [[[NSMutableArray alloc] init] autorelease];
    //设置导航标题(搜索条件)
    UIView *viewTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 45)];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, viewTitle.frame.size.width, 20)];
    [lbTitle setFont:[UIFont systemFontOfSize:14]];
    [lbTitle setText:self.searchCondition];
    [lbTitle setTextAlignment:NSTextAlignmentCenter];
    [lbTitle setTextColor:[UIColor whiteColor]];
    //    [viewTitle setBackgroundColor:[UIColor blueColor]];
    [viewTitle addSubview:lbTitle];
    //设置导航标题(搜索结果)
    self.lbSearchResult = [[[UILabel alloc] initWithFrame:CGRectMake(0, 22, viewTitle.frame.size.width, 20)] autorelease];
    [self.lbSearchResult setText:@"正在获取职位列表"];
    [self.lbSearchResult setFont:[UIFont systemFontOfSize:10]];
    [self.lbSearchResult setTextAlignment:NSTextAlignmentCenter];
    [self.lbSearchResult setTextColor:[UIColor whiteColor]];
    [viewTitle addSubview:self.lbSearchResult];
    [self.navigationItem setTitleView:viewTitle];
    [viewTitle release];
    [lbTitle release];
    //设置底部功能栏
    self.btnApply.layer.cornerRadius = 5;
    self.viewBottom.layer.borderWidth = 1.0;
    self.viewBottom.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    [self.btnApply addTarget:self action:@selector(jobApply) forControlEvents:UIControlEventTouchUpInside];
    [self.btnFavorite addTarget:self action:@selector(jobFavorite) forControlEvents:UIControlEventTouchUpInside];
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //添加上拉加载更多
    [self.tvJobList addFooterWithTarget:self action:@selector(footerRereshing)];
    //不显示列表分隔线
    self.tvJobList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //添加检索功能
    [self.btnWelfareFilter addTarget:self action:@selector(welfareFilter) forControlEvents:UIControlEventTouchUpInside];
    [self.btnJobTypeFilter addTarget:self action:@selector(jobtypeFilter) forControlEvents:UIControlEventTouchUpInside];
    [self.btnSalaryFilter addTarget:self action:@selector(salaryFilter) forControlEvents:UIControlEventTouchUpInside];
    [self.btnOtherFilter addTarget:self action:@selector(otherFilter) forControlEvents:UIControlEventTouchUpInside];
    //添加检索边框
    self.btnWelfareFilter.layer.masksToBounds = YES;
    self.btnWelfareFilter.layer.borderWidth = 1.0;
    self.btnWelfareFilter.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    self.btnJobTypeFilter.layer.masksToBounds = YES;
    self.btnJobTypeFilter.layer.borderWidth = 1.0;
    self.btnJobTypeFilter.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    self.btnSalaryFilter.layer.masksToBounds = YES;
    self.btnSalaryFilter.layer.borderWidth = 1.0;
    self.btnSalaryFilter.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    self.btnOtherFilter.layer.masksToBounds = YES;
    self.btnOtherFilter.layer.borderWidth = 1.0;
    self.btnOtherFilter.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    
    //搜索条件赋值
    self.jobType = @"";
    self.salary = @"";
    self.experience = @"";
    self.education = @"";
    self.employType = @"";
    self.rsType = @"";
    self.companySize = @"";
    self.welfare = @"";
    self.isOnline = @"";
    self.pageNumber = 1;
    self.rsType = @"0";
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
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[NSString stringWithFormat:@"%d",(int)self.searchDistance] forKey:@"distance"];
    [dicParam setObject:[NSString stringWithFormat:@"%f",self.searchLat] forKey:@"lat"];
    [dicParam setObject:[NSString stringWithFormat:@"%f",self.searchLng] forKey:@"lng"];
    [dicParam setObject:self.jobType forKey:@"jobType"];
    [dicParam setObject:@"" forKey:@"industry"];
    [dicParam setObject:self.salary forKey:@"salary"];
    [dicParam setObject:self.experience forKey:@"experience"];
    [dicParam setObject:self.education forKey:@"education"];
    [dicParam setObject:self.employType forKey:@"employType"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.pageNumber] forKey:@"pageNumber"];
    [dicParam setObject:self.companySize forKey:@"companySize"];
    [dicParam setObject:self.rsType forKey:@"rsType"];
    [dicParam setObject:self.welfare forKey:@"welfare"];
    [dicParam setObject:self.isOnline forKey:@"status"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetJobListByMapSearch" Params:dicParam];
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
        if (requestData.count == 0) {
            [loadView showNoListTips];
        }
        else {
            [loadView hideNoListTips];
        }
    }
    else if (request.tag == 2) { //获取可投递的简历，默认投递第一份简历
        if (requestData.count == 0) {
            [self.view makeToast:@"您没有有效简历，请先完善您的简历"];
        }
        else {
            self.cPopup = [[[CustomPopup alloc] popupCvSelect:requestData] autorelease];
            [self.cPopup setDelegate:self];
            [self insertJobApply:requestData[0][@"ID"] isFirst:YES];
        }
    }
    else if (request.tag == 3) { //默认投递完之后，显示弹层
        [self.cPopup showJobApplyCvSelect:result view:self.view];
    }
    else if (request.tag == 4) { //重新申请职位成功
        [self.view makeToast:@"简历更换成功"];
    }
    else if (request.tag == 5) {
        [self.view makeToast:@"收藏成功"];
    }
    //结束等待动画
    [loadView stopAnimating];
}

- (void)insertJobApply:(NSString *)cvMainID
               isFirst:(BOOL)isFirst
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[self.arrCheckJobID componentsJoinedByString:@","] forKey:@"JobID"];
    [dicParam setObject:cvMainID forKey:@"cvMainID"];
    [dicParam setObject:[userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"InsertJobApply" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    if (isFirst) {
        request.tag = 3;
    }
    else {
        request.tag = 4;
    }
    self.runningRequest = request;
    [dicParam release];
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
    if (indexPath.row == 1) {
        [self.lbSearchResult setText:[NSString stringWithFormat:@"周边%.1f公里 [找到%@个职位]",self.searchDistance/1000,rowData[@"JobNumber"]]];
    }
    //职位名称
    UILabel *lbJobName = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, 200, 20)];
    [lbJobName setText:rowData[@"JobName"]];
    [lbJobName setFont:[UIFont systemFontOfSize:16]];
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
    [lbRefreshDate setFont:[UIFont systemFontOfSize:12]];
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
    UIButton *btnCheck = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 77)];
    [btnCheck setTitle:rowData[@"ID"] forState:UIControlStateNormal];
    [btnCheck setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [btnCheck setTag:1];
    [btnCheck addTarget:self action:@selector(rowChecked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imgCheck = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 20, 20)];
    [imgCheck setImage:[UIImage imageNamed:@"chk_default.png"]];
    [btnCheck addSubview:imgCheck];
    if ([self.arrCheckJobID containsObject:rowData[@"ID"]]) {
        [imgCheck setImage:[UIImage imageNamed:@"chk_check.png"]];
        [btnCheck setTag:2];
    }
    [imgCheck release];
    
    [cell.contentView addSubview:btnCheck];
    [btnCheck release];
    
    //分割线
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, 76, 320, 1)];
    [viewSeparate setBackgroundColor:[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1]];
    [cell.contentView addSubview:viewSeparate];
    [viewSeparate release];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 77;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rowData = self.jobListData[indexPath.row];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CpAndJob" bundle:nil];
    SuperJobMainViewController *jobC = [storyBoard instantiateViewControllerWithIdentifier:@"SuperJobMainView"];
    jobC.JobID = rowData[@"ID"];
    jobC.cpMainID = rowData[@"cpMainID"];    
    jobC.navigationItem.title = rowData[@"cpName"];
    [self.navigationController pushViewController:jobC animated:YES];
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:false];
}

- (void)rowChecked:(UIButton *)sender
{
    UIImageView *imgCheck = sender.subviews[0];
    if (sender.tag == 1) {
        if (![self.arrCheckJobID containsObject:sender.titleLabel.text]) {
            [self.arrCheckJobID addObject:sender.titleLabel.text];
        }
        [imgCheck setImage:[UIImage imageNamed:@"chk_check.png"]];
        [sender setTag:2];
    }
    else {
        [self.arrCheckJobID removeObject:sender.titleLabel.text];
        [imgCheck setImage:[UIImage imageNamed:@"chk_default.png"]];
        [sender setTag:1];
    }
    NSLog(@"%@",[self.arrCheckJobID componentsJoinedByString:@","]);
}

- (void)welfareFilter
{
    NSMutableArray *arrWelfare = [NSMutableArray arrayWithCapacity:5];
    [arrWelfare addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"1",@"id",
                                 @"保险",@"value", nil] autorelease]];
    [arrWelfare addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"2",@"id",
                                 @"公积金",@"value", nil] autorelease]];
    [arrWelfare addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"13",@"id",
                                 @"奖金提成",@"value", nil] autorelease]];
    [arrWelfare addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"3",@"id",
                                 @"双休",@"value", nil] autorelease]];
    [arrWelfare addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"9",@"id",
                                 @"8小时工作制",@"value", nil] autorelease]];
    [arrWelfare addObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"10",@"id",
                                 @"提供住宿",@"value", nil] autorelease]];
    [self cancelPicker];
    self.dictionaryPicker = [[[DictionaryPickerView alloc] initWithDictionary:self defaultArray:arrWelfare defaultValue:self.welfare defaultName:self.welfareName pickerMode:DictionaryPickerModeMulti] autorelease];
    self.dictionaryPicker.tag = 2;
    [self.dictionaryPicker showInView:self.view];
}

- (void)jobtypeFilter
{
    [self cancelPicker];
    self.searchPicker = [[[SearchPickerView alloc] initWithSearchJobTypeFilter:self selectValue:@"" selectName:@"" defaultValue:self.jobType] autorelease];
    self.searchPicker.tag = 1;
    [self.searchPicker showInView:self.view];
}

- (void)salaryFilter
{
    [self cancelPicker];
    self.dictionaryPicker = [[[DictionaryPickerView alloc] initWithCommon:self pickerMode:DictionaryPickerModeOne tableName:@"dcSalary" defaultValue:self.salary defaultName:@""] autorelease];
    self.dictionaryPicker.tag = 1;
    [self.dictionaryPicker showInView:self.view];
}

- (void)otherFilter
{
    [self cancelPicker];
    self.searchPicker = [[[SearchPickerView alloc] initWithSearchOtherFilter:self defaultValue:self.selectOther defaultName:self.selectOtherName otherType:SearchPickerOtherNoWelfare] autorelease];
    self.searchPicker.tag = 2;
    [self.searchPicker showInView:self.view];
}

- (void)searchPickerDidChangeStatus:(SearchPickerView *)picker
                      selectedValue:(NSString *)selectedValue
                       selectedName:(NSString *)selectedName
{
    [self cancelPicker];
    if (picker.tag == 1) {
        self.jobType = selectedValue;
        self.lbJobTypeFilter.text = selectedName;
    }
    else if (picker.tag == 2) {
        self.selectOther = selectedValue;
        self.selectOtherName = selectedName;
        self.experience = @"";
        self.education = @"";
        self.employType = @"";
        self.companySize = @"";
        self.welfare = @"";
        self.isOnline = @"";
        if (selectedValue.length > 0) {
            NSArray *arrSelectValue = [selectedValue componentsSeparatedByString:@","];
            for (NSString* value in arrSelectValue) {
                if ([[value substringToIndex:1] isEqualToString:@"a"]) {
                    self.isOnline = @"1";
                }
                if ([[value substringToIndex:1] isEqualToString:@"b"]) {
                    self.education = [value substringFromIndex:1];
                }
                if ([[value substringToIndex:1] isEqualToString:@"c"]) {
                    self.experience = [value substringFromIndex:1];
                }
                if ([[value substringToIndex:1] isEqualToString:@"d"]) {
                    self.employType = [value substringFromIndex:1];
                }
                if ([[value substringToIndex:1] isEqualToString:@"e"]) {
                    self.companySize = [value substringFromIndex:1];
                }
                if ([[value substringToIndex:1] isEqualToString:@"f"]) {
                    self.welfare = [self.welfare stringByAppendingString:[NSString stringWithFormat:@"%@,",[value substringFromIndex:1]]];
                }
            }
            if (self.welfare.length > 0) {
                self.welfare = [self.welfare substringToIndex:self.welfare.length-1];
            }
        }
    }
    self.pageNumber = 1;
    [self onSearch];
}

- (void)pickerDidChangeStatus:(DictionaryPickerView *)picker
                selectedValue:(NSString *)selectedValue
                 selectedName:(NSString *)selectedName
{
    [self cancelPicker];
    if (picker.tag == 1) {
        self.salary = selectedValue;
        self.lbSalaryFilter.text = selectedName;
    }
    else if (picker.tag == 2)
    {
        self.welfare = selectedValue;
        self.welfareName = selectedName;
    }
    self.pageNumber = 1;
    [self onSearch];
}

-(void)cancelPicker
{
    [self.dictionaryPicker cancelPicker];
    self.dictionaryPicker.delegate = nil;
    self.dictionaryPicker = nil;
    
    [self.searchPicker cancelPicker];
    self.searchPicker.delegate = nil;
    self.searchPicker = nil;
}

- (void)jobApply
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"UserID"]) {
        //判断是否有选中的职位
        if (self.arrCheckJobID.count == 0) {
            [self.view makeToast:@"您还没有选择职位"];
            return;
        }
        //连接数据库，读取有效简历
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setObject:[userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
        [dicParam setObject:[userDefaults objectForKey:@"code"] forKey:@"code"];
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCvListByApply" Params:dicParam];
        [request setDelegate:self];
        [request startAsynchronous];
        request.tag = 2;
        self.runningRequest = request;
        [dicParam release];
        [loadView startAnimating];
    }
    else {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        LoginViewController *loginC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginView"];
        [self.navigationController pushViewController:loginC animated:true];
    }
}

- (void)jobFavorite
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"UserID"]) {
        //判断是否有选中的职位
        if (self.arrCheckJobID.count == 0) {
            [self.view makeToast:@"您还没有选择职位"];
            return;
        }
        //连接数据库，读取有效简历
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setObject:[userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
        [dicParam setObject:[self.arrCheckJobID componentsJoinedByString:@","] forKey:@"jobID"];
        [dicParam setObject:[userDefaults objectForKey:@"code"] forKey:@"code"];
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"InsertPaFavorate" Params:dicParam];
        [request setDelegate:self];
        [request startAsynchronous];
        request.tag = 5;
        self.runningRequest = request;
        [dicParam release];
        [loadView startAnimating];
    }
    else {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        LoginViewController *loginC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginView"];
        [self.navigationController pushViewController:loginC animated:true];
    }
}

- (void) getPopupValue:(NSString *)value
{
    [self insertJobApply:value isFirst:NO];
}

- (IBAction)scrollToTop:(id)sender {
    [self.tvJobList setContentOffset:CGPointMake(0, 0) animated:true];
    [self.btnTop setHidden:true];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.tvJobList.contentOffset.y > 300) {
        [self.btnTop setHidden:false];
    }
    else {
        [self.btnTop setHidden:true];
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
    [_btnWelfareFilter release];
    [_btnJobTypeFilter release];
    [_lbJobTypeFilter release];
    [_btnSalaryFilter release];
    [_lbSalaryFilter release];
    [_btnOtherFilter release];
    [_runningRequest release];
    [_jobType release];
    [_salary release];
    [_experience release];
    [_education release];
    [_employType release];
    [_rsType release];
    [_companySize release];
    [_welfare release];
    [_isOnline release];
    [_tvJobList release];
    [_searchCondition release];
    [_lbSearchResult release];
    [_btnApply release];
    [_btnFavorite release];
    [_viewBottom release];
    [_searchPicker release];
    [_dictionaryPicker release];
    [_arrCheckJobID release];
    [_cPopup release];
    [_jobListData release];
    [_btnTop release];
    [super dealloc];
}
@end