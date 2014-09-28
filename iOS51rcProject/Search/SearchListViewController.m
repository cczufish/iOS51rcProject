#import "SearchListViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "MJRefresh.h"
#import "SearchPickerView.h"
#import "Toast+UIView.h"
#import "DictionaryPickerView.h"
#import "LoginViewController.h"
#import "CustomPopup.h"
#import "JobViewController.h"
#import "SuperJobMainViewController.h"

@interface SearchListViewController () <NetWebServiceRequestDelegate,UITableViewDataSource,UITableViewDelegate,SearchPickerDelegate,DictionaryPickerDelegate,CustomPopupDelegate>
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
@property (nonatomic, retain) SearchPickerView *searchPicker;
@property (nonatomic, retain) DictionaryPickerView *dictionaryPicker;
@property (nonatomic, retain) CustomPopup *cPopup;
@end

@implementation SearchListViewController

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
    self.arrCheckJobID = [[[NSMutableArray alloc] init] autorelease];
    //设置导航标题(搜索条件)
    UIView *viewTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 180, 45)];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, viewTitle.frame.size.width, 20)];
    [lbTitle setFont:[UIFont systemFontOfSize:12]];
    [lbTitle setText:self.searchCondition];
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
    [self.btnFavorite addTarget:self action:@selector(jobFavorite) forControlEvents:UIControlEventTouchUpInside];
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //添加上拉加载更多
    [self.tvJobList addFooterWithTarget:self action:@selector(footerRereshing)];
    //不显示列表分隔线
    self.tvJobList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //添加检索功能
    [self.btnRegionFilter addTarget:self action:@selector(regionFilter) forControlEvents:UIControlEventTouchUpInside];
    [self.btnJobTypeFilter addTarget:self action:@selector(jobtypeFilter) forControlEvents:UIControlEventTouchUpInside];
    [self.btnSalaryFilter addTarget:self action:@selector(salaryFilter) forControlEvents:UIControlEventTouchUpInside];
    [self.btnOtherFilter addTarget:self action:@selector(otherFilter) forControlEvents:UIControlEventTouchUpInside];
    //添加检索边框
    self.btnRegionFilter.layer.masksToBounds = YES;
    self.btnRegionFilter.layer.borderWidth = 1.0;
    self.btnRegionFilter.layer.borderColor = [[UIColor grayColor] CGColor];
    self.btnJobTypeFilter.layer.masksToBounds = YES;
    self.btnJobTypeFilter.layer.borderWidth = 1.0;
    self.btnJobTypeFilter.layer.borderColor = [[UIColor grayColor] CGColor];
    self.btnSalaryFilter.layer.masksToBounds = YES;
    self.btnSalaryFilter.layer.borderWidth = 1.0;
    self.btnSalaryFilter.layer.borderColor = [[UIColor grayColor] CGColor];
    self.btnOtherFilter.layer.masksToBounds = YES;
    self.btnOtherFilter.layer.borderWidth = 1.0;
    self.btnOtherFilter.layer.borderColor = [[UIColor grayColor] CGColor];
    
    //搜索条件赋值
    self.jobType = @"";
    self.workPlace = @"";
    self.industry = @"";
    self.salary = @"";
    self.experience = @"";
    self.education = @"";
    self.employType = @"";
    self.keyWord = @"";
    self.rsType = @"";
    self.companySize = @"";
    self.welfare = @"";
    self.isOnline = @"";
    
    if (self.searchJobType.length > 0) {
        self.jobType = self.searchJobType;
    }
    else {
        self.searchJobType = @"";
    }
    if (self.searchIndustry.length > 0) {
        self.industry = self.searchIndustry;
    }
    else {
        self.searchIndustry = @"";
    }
    self.workPlace = self.searchRegion;
    self.keyWord = self.searchKeyword;
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
    [dicParam setObject:self.jobType forKey:@"jobType"];
    [dicParam setObject:self.workPlace forKey:@"workPlace"];
    [dicParam setObject:self.industry forKey:@"industry"];
    [dicParam setObject:self.salary forKey:@"salary"];
    [dicParam setObject:self.experience forKey:@"experience"];
    [dicParam setObject:self.education forKey:@"education"];
    [dicParam setObject:self.employType forKey:@"employType"];
    [dicParam setObject:self.keyWord forKey:@"keyWord"];
    [dicParam setObject:self.rsType forKey:@"rsType"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.pageNumber] forKey:@"pageNumber"];
    [dicParam setObject:self.companySize forKey:@"companySize"];
    [dicParam setObject:@"" forKey:@"searchFromID"];
    [dicParam setObject:self.welfare forKey:@"welfare"];
    [dicParam setObject:self.isOnline forKey:@"isOnline"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetJobListBySearch" Params:dicParam];
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
            [self.view makeToast:@"没有符合条件的职位"];
        }
    }
    else if (request.tag == 2) { //获取可投递的简历，默认投递第一份简历
        if (requestData.count == 0) {
            [self.view makeToast:@"您没有有效职位，请先完善您的简历"];
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
        [self.view makeToast:@"重新申请简历成功"];
    }
    else if (request.tag == 5) {
        [self.view makeToast:@"收藏职位成功"];
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
    UIFont *fontCell = [UIFont systemFontOfSize:12];
    UIColor *colorText = [UIColor colorWithRed:120.f/255.f green:120.f/255.f blue:120.f/255.f alpha:1];
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"jobList"] autorelease];
    NSDictionary *rowData = self.jobListData[indexPath.row];
    if (indexPath.row == 1) {
        [self.lbSearchResult setText:[NSString stringWithFormat:@"[找到%@个职位]",rowData[@"JobNumber"]]];
        if (self.pageNumber == 1) {
            //删除重复的搜索记录
            NSString *strSql = [NSString stringWithFormat:@"DELETE FROM PaSearchHistory WHERE Name='%@'",self.searchCondition];
            [CommonController execSql:strSql];
            //添加搜索记录
            strSql = [NSString stringWithFormat:@"INSERT INTO PaSearchHistory(Name,dcRegionID,dcIndustryID,dcJobTypeID,keyWords,reSearchDate,addDate,JobNum) VALUES('%@','%@','%@','%@','%@',datetime(CURRENT_TIMESTAMP,'localtime'),datetime(CURRENT_TIMESTAMP,'localtime'),%@)",self.searchCondition,self.searchRegion,self.searchIndustry,self.searchJobType,self.keyWord,rowData[@"JobNumber"]];
            [CommonController execSql:strSql];
        }
    }
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
    if ([rowData[@"dcEducationID"] isEqualToString:@"100"]) {
        strRegionAndEducation = [NSString stringWithFormat:@"%@%@",strRegionAndEducation,@"学历不限"];
    }
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
    [imgCheck release];
    [cell.contentView addSubview:btnCheck];
    [btnCheck release];
    
    //分割线
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, 76, 320, 1)];
    [viewSeparate setBackgroundColor:[UIColor lightGrayColor]];
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
    self.navigationItem.title = @" ";
    jobC.navigationItem.title = rowData[@"cpName"];
    [self.navigationController pushViewController:jobC animated:YES];
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

- (void)regionFilter
{
    [self cancelPicker];
    if ([self.searchRegion rangeOfString:@","].location == NSNotFound) {
        if (![CommonController hasParentOfRegion:self.searchRegion]) {
            [self.view makeToast:@"您选择的地区已经到最后一级，不能再继续筛选了"];
            return;
        }
    }
    self.searchPicker = [[[SearchPickerView alloc] initWithSearchRegionFilter:self selectValue:self.searchRegion selectName:self.searchRegionName defaultValue:self.workPlace] autorelease];
    self.searchPicker.tag = 1;
    [self.searchPicker showInView:self.view];
}

- (void)jobtypeFilter
{
    [self cancelPicker];
    if ([self.searchRegion rangeOfString:@","].location == NSNotFound) {
        if (self.searchRegion.length == 4) {
            [self.view makeToast:@"您选择的职位类别已经到最后一级，不能再继续筛选了"];
            return;
        }
    }
    self.searchPicker = [[[SearchPickerView alloc] initWithSearchJobTypeFilter:self selectValue:self.searchJobType selectName:self.searchJobTypeName defaultValue:self.jobType] autorelease];
    self.searchPicker.tag = 2;
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
    self.searchPicker = [[[SearchPickerView alloc] initWithSearchOtherFilter:self defaultValue:self.selectOther defaultName:self.selectOtherName otherType:SearchPickerOtherAll] autorelease];
    self.searchPicker.tag = 3;
    [self.searchPicker showInView:self.view];
}

- (void)searchPickerDidChangeStatus:(SearchPickerView *)picker
                selectedValue:(NSString *)selectedValue
                 selectedName:(NSString *)selectedName
{
    [self cancelPicker];
    if (picker.tag == 1) {
        self.workPlace = selectedValue;
        if (selectedValue.length == 0) {
            self.workPlace = self.searchRegion;
        }
        self.lbRegionFilter.text = selectedName;
    }
    else if (picker.tag == 2) {
        self.jobType = selectedValue;
        if (selectedValue.length == 0) {
            self.jobType = self.searchJobType;
        }
        self.lbJobTypeFilter.text = selectedName;
    }
    else if (picker.tag == 3) {
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
    [_btnRegionFilter release];
    [_lbRegionFilter release];
    [_btnJobTypeFilter release];
    [_lbJobTypeFilter release];
    [_btnSalaryFilter release];
    [_lbSalaryFilter release];
    [_btnOtherFilter release];
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
    [_searchKeyword release];
    [_searchRegion release];
    [_searchJobType release];
    [_searchIndustry release];
    [_searchCondition release];
    [_lbSearchResult release];
    [_btnApply release];
    [_btnFavorite release];
    [_viewBottom release];
    [_searchPicker release];
    [_dictionaryPicker release];
    [_arrCheckJobID release];
    [_cPopup release];
    [_btnTop release];
    [super dealloc];
}
@end
