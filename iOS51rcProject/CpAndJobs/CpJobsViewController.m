#import "CpJobsViewController.h"
#import "CommonController.h"
#import "Toast+UIView.h"
#import "LoginViewController.h"
#import "Popup+UIView.h"
#import "CustomPopup.h"
#import "SuperJobMainViewController.h"

//公司职位列表页面
@interface CpJobsViewController ()<NetWebServiceRequestDelegate, CustomPopupDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tvCpJobList;
@property (retain, nonatomic) IBOutlet UIButton *btnApply;
@property (retain, nonatomic) IBOutlet UIView *ViewBottom;
@property (retain, nonatomic) IBOutlet UIButton *btnFavourite;
@property (nonatomic, retain) CustomPopup *cPopup;
@end

@implementation CpJobsViewController
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
    self.arrCheckJobID = [[NSMutableArray alloc] init];
    if (self.frameHeight == 0) {
        self.frameHeight = 496;
    }
    self.btnApply.layer.cornerRadius = 5;   
    [self.btnApply addTarget:self action:@selector(jobApply) forControlEvents:UIControlEventTouchUpInside];
    [self.btnFavourite addTarget:self action:@selector(jobFavorite) forControlEvents:UIControlEventTouchUpInside];
    //数据加载等待控件初始化
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //设置高度
    self.ViewBottom.frame = CGRectMake(0, HEIGHT - 170, 320, 55);
    self.tvCpJobList.frame = CGRectMake(0, 0, 320, HEIGHT - 170);
    //设置边框
    self.ViewBottom.layer.borderColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
    self.ViewBottom.layer.borderWidth = 0.5;
    //不显示列表分隔线
    self.tvCpJobList.separatorStyle = UITableViewCellSeparatorStyleNone;
    //[self onSearch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];  
}
- (void)onSearch
{
    [self.jobListData removeAllObjects];
    [self.tvCpJobList reloadData];
    
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.cpMainID forKey:@"cpMainID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetJobList" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 1;
    self.runningRequest = request;
    [dicParam release];
    [loadView startAnimating];
}

//成功
- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSMutableArray *)requestData
{
    UIViewController *pCtrl = [CommonController getFatherController:self.view];
    if (request.tag == 1) {
        [self.jobListData removeAllObjects];
        self.jobListData = requestData;
        
        [self.tvCpJobList reloadData];
    }else if (request.tag == 2) { //获取可投递的简历，默认投递第一份简历
        if (requestData.count == 0) {
            [pCtrl.view makeToast:@"您没有有效简历，请先完善您的简历"];
            [self.arrCheckJobID removeAllObjects];
        }else {
            self.cPopup = [[[CustomPopup alloc] popupCvSelect:requestData] autorelease];
            [self.cPopup setDelegate:self];
            [self insertJobApply:requestData[0][@"ID"] isFirst:YES];
        }
    }else if (request.tag == 3) { //默认投递完之后，显示弹层
        [self.cPopup showJobApplyCvSelect:result view:[CommonController getFatherController:self.view].view];
        [self.arrCheckJobID removeAllObjects];
    }else if (request.tag == 4) { //重新申请职位成功
        [pCtrl.view makeToast:@"简历更换成功"];
        [self.arrCheckJobID removeAllObjects];
        [self.tvCpJobList reloadData];
    }else if (request.tag == 5) {
        [pCtrl.view makeToast:@"收藏成功"];
        [self.arrCheckJobID removeAllObjects];
        [self.tvCpJobList reloadData];
    }
    
    //结束等待动画
    [loadView stopAnimating];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat titleWidth = 235;
    CGSize titleSize = CGSizeMake(titleWidth, 5000.0f);
    
    UITableViewCell *cell =
    [[[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"paList"] autorelease];
    NSDictionary *rowData = self.jobListData[indexPath.row];
    //职位名称
    NSString *strJobName = rowData[@"Name"];
    UIFont *titleFont = [UIFont systemFontOfSize:14];
    CGSize labelSize = [CommonController CalculateFrame:strJobName fontDemond:titleFont sizeDemand:titleSize];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 200, labelSize.height)];
    lbTitle.text = strJobName;
    lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
    lbTitle.numberOfLines = 0;
    lbTitle.font = titleFont;
    [cell.contentView addSubview:(lbTitle)];
    [lbTitle release];
    //时间
    NSString *strefreshDate = rowData[@"RefreshDate"];
    NSDate *dtefreshDate = [CommonController dateFromString:strefreshDate];
    strefreshDate = [CommonController stringFromDate:dtefreshDate formatType:@"MM-dd HH:mm"];
    UILabel *lbeRfreshDate = [[UILabel alloc] initWithFrame:CGRectMake(220, lbTitle.frame.origin.y, 80, labelSize.height)];
    lbeRfreshDate.text = strefreshDate;
    lbeRfreshDate.textAlignment = NSTextAlignmentRight;
    lbeRfreshDate.font = [UIFont systemFontOfSize:14];
    lbeRfreshDate.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbeRfreshDate)];
    [lbeRfreshDate release];
    //地区
    NSString *strAge = rowData[@"Region"];
    //学历
    NSString *strDegree = [CommonController getDictionaryDesc:rowData[@"dcEducationID"] tableName:@"dcEducation"];
    //[CommonController getDictionary:rowData[@"dcEducationID"]];
    NSString *strInfo = [NSString stringWithFormat:@"%@|%@", strAge, strDegree];
    UILabel *lbInfo = [[UILabel alloc] initWithFrame:CGRectMake(40, lbTitle.frame.origin.y+lbTitle.frame.size.height + 5, 200, labelSize.height)];
    lbInfo.text = strInfo;
    lbInfo.font = [UIFont systemFontOfSize:14];
    lbInfo.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbInfo)];
    [lbInfo release];
    //工资
    NSString *strdcSalaryID = rowData[@"dcSalaryID"];
    UILabel *lbSalary = [[UILabel alloc] initWithFrame:CGRectMake(220, lbTitle.frame.origin.y+lbTitle.frame.size.height + 5, 80, labelSize.height)];
    lbSalary.text = [CommonController getDictionaryDesc:strdcSalaryID tableName:@"dcSalary"];
    lbSalary.font = [UIFont systemFontOfSize:14];
    lbSalary.textAlignment = NSTextAlignmentRight;
    lbSalary.textColor = [UIColor redColor];
    [cell.contentView addSubview:(lbSalary)];
    [lbSalary release];
    //复选框
    UIButton *btnCheck = [[UIButton alloc] initWithFrame:CGRectMake(10, 15, 100, 50)];
    [btnCheck setTitle:rowData[@"ID"] forState:UIControlStateNormal];
    [btnCheck setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [btnCheck setTag:1];
    [btnCheck addTarget:self action:@selector(rowChecked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnCheck];
    [btnCheck release];
    UIImageView *imgCheck = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)] autorelease];
    imgCheck.image = [UIImage imageNamed: @"chk_default.png"];
    [btnCheck addSubview:imgCheck];
    //分割线
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, lbSalary.frame.origin.y+lbSalary.frame.size.height + 6, 320, 1)];
    [viewSeparate setBackgroundColor:[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1]];
    [cell.contentView addSubview:viewSeparate];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rowData = self.jobListData[indexPath.row];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CpAndJob" bundle:nil];
    SuperJobMainViewController *jobC = [storyBoard instantiateViewControllerWithIdentifier:@"SuperJobMainView"];
    jobC.JobID = rowData[@"ID"];
    jobC.cpMainID = rowData[@"cpMainID"];
    UIViewController *pCtrl = [CommonController getFatherController:self.view];
    jobC.navigationItem.title = pCtrl.navigationItem.title;
    [pCtrl.navigationController pushViewController:jobC animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.jobListData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (void)footerRereshing{
    page++;
    [self onSearch];
}


- (void)rowChecked:(UIButton *)sender
{
    if (sender.tag == 1) {
        if (![self.arrCheckJobID containsObject:sender.titleLabel.text]) {
            [self.arrCheckJobID addObject:sender.titleLabel.text];
        }
        UIImageView *imgCheck = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)] autorelease];
        imgCheck.image = [UIImage imageNamed: @"chk_check.png"];
        [sender addSubview:imgCheck];
        [sender setTag:2];
    }
    else {
        [self.arrCheckJobID removeObject:sender.titleLabel.text];
        UIImageView *imgCheck = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)] autorelease];
        imgCheck.image = [UIImage imageNamed: @"chk_default.png"];
        [sender addSubview:imgCheck];
        [sender setTag:1];
    }
    NSLog(@"%@",[self.arrCheckJobID componentsJoinedByString:@","]);
}

- (void)insertJobApply:(NSString *)cvMainID isFirst:(BOOL)isFirst
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

- (void)jobApply
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"UserID"]) {
        //判断是否有选中的职位
        if (self.arrCheckJobID.count == 0) {
            UIViewController *pCtrl = [CommonController getFatherController:self.view];
            [pCtrl.view makeToast:@"您还没有选择职位"];
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
            UIViewController *pCtrl = [CommonController getFatherController:self.view];
            [pCtrl.view makeToast:@"您还没有选择职位"];
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

- (void)dealloc {
    [loadView release];
    [_cPopup release];
    [_jobListData release];
    [_tvCpJobList release];
    [_ViewBottom release];
    [_btnApply release];
    [_btnFavourite release];
    [_runningRequest release];
    [_arrCheckJobID release];
    
    [super dealloc];
}
@end
