#import "JmJobScanViewController.h"
#import "CommonController.h"
#import "NetWebServiceRequest.h"
#import "DictionaryPickerView.h"
#import "CustomPopup.h"
#import "Toast+UIView.h"
#import "LoadingAnimationView.h"
#import "SuperJobMainViewController.h"
#import "MJRefresh.h"
#import "LoginViewController.h"

@interface JmJobScanViewController ()<NetWebServiceRequestDelegate,UITableViewDataSource,UITableViewDelegate,DictionaryPickerDelegate,CustomPopupDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NSMutableArray *jobListData;
@property int pageNumber;
@property (nonatomic, retain) NSString *isOnline;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) CustomPopup *cPopup;
@property (retain, nonatomic) IBOutlet UILabel *lbTop;
@end

@implementation JmJobScanViewController
#define HEIGHT [[UIScreen mainScreen] bounds].size.height
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
    
    self.lbTop.layer.borderWidth = 0.5;
    self.lbTop.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.pageNumber = 1;
    self.arrCheckJobID = [[NSMutableArray alloc] init];
    //设置底部功能栏
    self.tvJobList.frame = CGRectMake(0, self.tvJobList.frame.origin.y, 320, HEIGHT-self.viewBottom.frame.size.height-154);
    self.viewBottom.frame = CGRectMake(0, self.tvJobList.frame.origin.y+self.tvJobList.frame.size.height, 320, self.viewBottom.frame.size.height);
    self.btnApply.layer.cornerRadius = 5;
    [self.btnApply addTarget:self action:@selector(jobApply) forControlEvents:UIControlEventTouchUpInside];
    self.viewBottom.layer.borderWidth = 1.0;
    self.viewBottom.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    [self.btnFavourity addTarget:self action:@selector(jobFavorite) forControlEvents:UIControlEventTouchUpInside];
    
    //不显示列表分隔线
    self.tvJobList.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    [dicParam setObject:userID forKey:@"paMainID"];//21142013
    [dicParam setObject:code forKey:@"code"];//152014391908
    [dicParam setObject:@"20" forKey:@"pageSize"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.pageNumber] forKey:@"pageNum"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetPaJobViewList" Params:dicParam];
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
    UIViewController *pCtrl = [CommonController getFatherController:self.view];
    if (request.tag == 1) { //职位搜索
         if (requestData.count>0 || (requestData.count == 0 && self.pageNumber > 1)) {
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
        else{
            //没有面试通知记录
            self.lbTop.text = @" ";
            self.lbTop.layer.borderColor = [UIColor whiteColor].CGColor;
            
            UIView *viewHsaNoCv = [[[UIView alloc] initWithFrame:CGRectMake(20, 100, 240, 80)]autorelease];
            UIImageView *img = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 60)] autorelease];
            img.image = [UIImage imageNamed:@"pic_noinfo.png"];
            [viewHsaNoCv addSubview:img];
            
            UILabel *lb1 = [[[UILabel alloc]initWithFrame:CGRectMake(50, 10, 220, 20)] autorelease];
            lb1.text = @"亲，没有浏览职位记录";
            lb1.font = [UIFont systemFontOfSize:14];
            lb1.textAlignment = NSTextAlignmentCenter;
            [viewHsaNoCv addSubview:lb1];
            
            UILabel *lb2 = [[[UILabel alloc] initWithFrame:CGRectMake(50, 30, 235, 20)] autorelease];
            lb2.text = @"现在就去我们的职位库中看看吧！";
            lb2.font = [UIFont systemFontOfSize:14];
            lb2.textColor =  [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
            lb2.textAlignment = NSTextAlignmentCenter;
            [viewHsaNoCv addSubview:lb2];
            
            [self.view addSubview:viewHsaNoCv];
        }
    }
    else if (request.tag == 2) { //获取可投递的简历，默认投递第一份简历
        if (requestData.count == 0) {
            [pCtrl.view makeToast:@"您没有有效简历，请先完善您的简历"];
        }
        else {
            self.cPopup = [[[CustomPopup alloc] popupCvSelect:requestData] autorelease];
            [self.cPopup setDelegate:self];
            [self insertJobApply:requestData[0][@"ID"] isFirst:YES];
        }
    }
    else if (request.tag == 3) { //默认投递完之后，显示弹层
        [self.cPopup showJobApplyCvSelect:result view:pCtrl.view];
    }
    else if (request.tag == 4) { //重新申请职位成功
        [pCtrl.view makeToast:@"申请成功"];
        //更新视图，删除全局对象内改数据，并重新绑定
        for (int i = 0; i<self.jobListData.count; i++) {
            NSDictionary *rowData = self.jobListData[i];
            NSString *jobID = rowData[@"JobID"];
            //如果包含在被申请的列表内，则更新数据源
            for (int j=0; j<self.arrCheckJobID.count; j++) {
                if ([self.arrCheckJobID[j] isEqualToString:jobID]) {
                    [rowData setValue:@"1" forKey:@"isApply"];//设置为已申请
                    break;
                }
            }
        }
        [self.tvJobList reloadData];
        self.arrCheckJobID = [[NSMutableArray alloc] init];
    }
    else if (request.tag == 5) {
        [pCtrl.view makeToast:@"收藏职位成功"];
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


- (void)jobFavorite
{
    UIViewController *pCtrl = [CommonController getFatherController:self.view];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"UserID"]) {
        //判断是否有选中的职位
        if (self.arrCheckJobID.count == 0) {
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
    
    //职位名称
    UILabel *lbJobName = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, 200, 20)];
    [lbJobName setText:rowData[@"JobName"]];
    [lbJobName setFont:[UIFont systemFontOfSize:14]];
    [cell.contentView addSubview:lbJobName];
    [lbJobName release];
    
    //在线按钮
    BOOL isOnline = [rowData[@"IsOnline"] boolValue];
    if (isOnline) {
        UIButton *btnChat = [[[UIButton alloc] initWithFrame:CGRectMake(265, 5, 40, 20)] autorelease];
        [btnChat setImage:[UIImage imageNamed:@"ico_joblist_online.png"] forState:UIControlStateNormal];
        [cell.contentView addSubview:btnChat];
    }

    //公司名称
    UILabel *lbCompanyName = [[UILabel alloc] initWithFrame:CGRectMake(40, 28, 200, 20)];
    [lbCompanyName setText:rowData[@"cpName"]];
    [lbCompanyName setFont:fontCell];
    [lbCompanyName setTextColor:colorText];
    [cell.contentView addSubview:lbCompanyName];
    [lbCompanyName release];
    
    //已申请按钮
    NSString *isApply = rowData[@"isApply"];
    if ([isApply isEqualToString:@"1"]) {
        UILabel *lbFavourite = [[[UILabel alloc] initWithFrame:CGRectMake(255, 32, 50, 15)] autorelease];
        [lbFavourite setText:@"已申请"];
        [lbFavourite setFont:[UIFont systemFontOfSize:10]];
        lbFavourite.textAlignment = NSTextAlignmentCenter;
        [lbFavourite setTextColor:[UIColor whiteColor]];
        lbFavourite.layer.cornerRadius = 5;
        lbFavourite.layer.backgroundColor = [UIColor colorWithRed:0.f/255.f green:161.f/255.f blue:233.f/255.f alpha:1].CGColor;
        [cell.contentView addSubview:lbFavourite];
    }
    
    //已经过期
    NSString *issueEnd = rowData[@"IssueEND"];
    NSDate *dtIssueEnd = [CommonController dateFromString:issueEnd];
    NSDate * now = [NSDate date];
    if ([now laterDate:dtIssueEnd] == now ) {
        UIImageView *imgEnd = [[[UIImageView alloc] initWithFrame:CGRectMake(290, 0, 30, 30)]autorelease];
        imgEnd.image = [UIImage imageNamed:@"ico_expire.png"];
        [cell.contentView addSubview:imgEnd];
    }
    
    //收藏时间
    UILabel *lbRefreshDate = [[UILabel alloc] initWithFrame:CGRectMake(40, 51, 200, 20)];
    NSString *strDate = [NSString stringWithFormat:@"收藏时间：%@", [CommonController stringFromDate:[CommonController dateFromString:rowData[@"AddDate"]] formatType:@"MM-dd HH:mm"]];
    [lbRefreshDate setText:strDate];
    [lbRefreshDate setFont:fontCell];
    [lbRefreshDate setTextColor:colorText];
    //[lbRefreshDate setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbRefreshDate];
    [lbRefreshDate release];
    
    //月薪
    NSString *strdcSalaryId = rowData[@"dcSalaryId"] ;
    NSString *strSalary = [CommonController getDictionaryDesc:strdcSalaryId tableName:@"dcSalary"];
    if (strSalary.length == 0) {
        strSalary = @"面议";
    }
    UILabel *lbSalary = [[UILabel alloc] initWithFrame:CGRectMake(200, 51, 100, 20)];
    [lbSalary setText:strSalary];
    [lbSalary setFont:fontCell];
    [lbSalary setTextColor:[UIColor redColor]];
    [lbSalary setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbSalary];
    [lbSalary release];
    
    //复选框
    UIButton *btnCheck = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 77)];
    [btnCheck setTitle:rowData[@"JobID"] forState:UIControlStateNormal];
    [btnCheck setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [btnCheck setTag:1];
    [btnCheck addTarget:self action:@selector(rowChecked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imgCheck = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 20, 20)];
    [imgCheck setImage:[UIImage imageNamed:@"chk_default.png"]];
    [btnCheck addSubview:imgCheck];
    if ([self.arrCheckJobID containsObject:rowData[@"JobID"]]) {
        [imgCheck setImage:[UIImage imageNamed:@"chk_check.png"]];
        [btnCheck setTag:2];
    }
    [imgCheck release];
    [cell.contentView addSubview:btnCheck];
    [btnCheck release];
    
    //添加上拉加载更多
    [self.tvJobList addFooterWithTarget:self action:@selector(footerRereshing)];
    //分割线
    if (indexPath.row != self.jobListData.count - 1) {
        UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, 76, 320, 1)];
        [viewSeparate setBackgroundColor:[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1]];
        [cell.contentView addSubview:viewSeparate];
    }
   
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
    jobC.JobID = rowData[@"JobID"];
    jobC.cpMainID = rowData[@"cpID"];
    jobC.navigationItem.title = rowData[@"cpName"];
    UIViewController *pCtrl = [CommonController getFatherController:self.view];
    [pCtrl.navigationController pushViewController:jobC animated:YES];
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

- (void)jobApply
{
    UIViewController *pCtrl = [CommonController getFatherController:self.view];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"UserID"]) {
        //判断是否有选中的职位
        if (self.arrCheckJobID.count == 0) {
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

- (void) getPopupValue:(NSString *)value
{
    [self insertJobApply:value isFirst:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
    [_runningRequest release];
    [_isOnline release];
    [_tvJobList release];
    [_btnApply release];
    [_viewBottom release];
    [_arrCheckJobID release];
    [_cPopup release];
    [_btnFavourity release];
    [_lbTop release];
    [super dealloc];
}
@end
