#import "JobInviteListViewController.h"
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
#import <objc/runtime.h>

@interface JobInviteListViewController ()<NetWebServiceRequestDelegate,UITableViewDataSource,UITableViewDelegate,SearchPickerDelegate,DictionaryPickerDelegate,CustomPopupDelegate>
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

@implementation JobInviteListViewController
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
    self.arrWillBeDeletedID = [[NSMutableArray alloc] init];
    //设置底部功能栏
    self.tvJobList.frame = CGRectMake(0, self.tvJobList.frame.origin.y, 320, HEIGHT-self.viewBottom.frame.size.height-155);
    self.viewBottom.frame = CGRectMake(self.view.frame.origin.x, self.tvJobList.frame.origin.y+self.tvJobList.frame.size.height-1, 320, self.viewBottom.frame.size.height+1);
    self.btnApply.layer.cornerRadius = 5;
    self.viewBottom.layer.borderWidth = 1.0;
    self.viewBottom.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    [self.btnApply addTarget:self action:@selector(jobApply) forControlEvents:UIControlEventTouchUpInside];
    [self.btnFavorite addTarget:self action:@selector(jobFavorite) forControlEvents:UIControlEventTouchUpInside];
    [self.btnDelete addTarget:self action:@selector(jobDelete) forControlEvents:UIControlEventTouchUpInside];
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    
    //不显示列表分隔线
    self.tvJobList.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    [dicParam setObject:userID forKey:@"paMainID"];//21142013
    [dicParam setObject:code forKey:@"code"];//152014391908
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetJobInvitationList" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 1;
    self.runningRequest = request;
    [dicParam release];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSMutableArray *)requestData
{
     UIViewController *pCtrl = [self getFatherController];
    if (request.tag == 1) { //职位搜索
        if (requestData.count>0) {
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
            //没有应聘邀请记录
            self.lbTop.text = @" ";
            self.lbTop.layer.borderColor = [UIColor whiteColor].CGColor;
            UIView *viewHsaNoCv = [[[UIView alloc] initWithFrame:CGRectMake(30, 100, 240, 80)]autorelease];
            UIImageView *img = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 60)] autorelease];
            img.image = [UIImage imageNamed:@"pic_noinfo.png"];
            [viewHsaNoCv addSubview:img];
            
            UILabel *lb1 = [[[UILabel alloc]initWithFrame:CGRectMake(50, 10, 220, 20)] autorelease];
            lb1.text = @"亲，您没有应聘邀请记录,";
            lb1.font = [UIFont systemFontOfSize:14];
            lb1.textAlignment = NSTextAlignmentCenter;
            [viewHsaNoCv addSubview:lb1];
            
            UILabel *lb2 = [[[UILabel alloc] initWithFrame:CGRectMake(35, 30, 45, 20)] autorelease];
            lb2.text = @"建议您";
            lb2.font = [UIFont systemFontOfSize:14];
            lb2.textAlignment = NSTextAlignmentLeft;
            [viewHsaNoCv addSubview:lb2];
            
            UILabel *lb3 = [[[UILabel alloc] initWithFrame:CGRectMake(lb2.frame.origin.x + lb2.frame.size.width, 30, 85, 20)] autorelease];
            lb3.text = @"主动申请职位";
            lb3.font = [UIFont systemFontOfSize:14];
            lb3.textColor =  [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
            lb3.textAlignment = NSTextAlignmentLeft;
            [viewHsaNoCv addSubview:lb3];
            
            UILabel *lb4 = [[[UILabel alloc] initWithFrame:CGRectMake(lb3.frame.origin.x + lb3.frame.size.width, 30, 160, 20)] autorelease];
            lb4.text = @"，把握更多的机会。";
            lb4.font = [UIFont systemFontOfSize:14];
            lb4.textAlignment = NSTextAlignmentLeft;
            [viewHsaNoCv addSubview:lb4];
            
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
        [pCtrl.view makeToast:@"简历更换成功"];
         [self onSearch];
    }
    else if (request.tag == 5) {
        [pCtrl.view makeToast:@"收藏成功"];
    }
    else if (request.tag == 6) {
        //if (requestData.count > 0) {
            [pCtrl.view makeToast:@"删除成功"];
            [self.arrWillBeDeletedID removeAllObjects];//清空数据
            [self.arrCheckJobID removeAllObjects];
            [self onSearch];
        //}else{
        //    [pCtrl.view makeToast:@"删除失败"];
        //}
    }
    //结束等待动画
    [loadView stopAnimating];
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
  
    //职位名称
    UILabel *lbJobName = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, 200, 20)];
    [lbJobName setText:rowData[@"JobName"]];
    [lbJobName setFont:[UIFont systemFontOfSize:14]];
    [cell.contentView addSubview:lbJobName];
    [lbJobName release];
    
    //公司名称
    UILabel *lbCompanyName = [[UILabel alloc] initWithFrame:CGRectMake(40, 28, 200, 20)];
    [lbCompanyName setText:rowData[@"cpName"]];
    [lbCompanyName setFont:fontCell];
    [lbCompanyName setTextColor:colorText];
    [cell.contentView addSubview:lbCompanyName];
    [lbCompanyName release];
    
    //已经过期
    NSString *issueEnd = rowData[@"IssueEnd"];
    NSDate *dtIssueEnd = [CommonController dateFromString:issueEnd];
    NSDate * now = [NSDate date];
    if ([now laterDate:dtIssueEnd] == now ) {
        UIImageView *imgEnd = [[[UIImageView alloc] initWithFrame:CGRectMake(290, 0, 30, 30)]autorelease];
        imgEnd.image = [UIImage imageNamed:@"ico_expire.png"];
        [cell.contentView addSubview:imgEnd];
    }
    
    //邀请时间
    UILabel *lbRefreshDate = [[UILabel alloc] initWithFrame:CGRectMake(40, 51, 200, 20)];
    NSString *strDate = [NSString stringWithFormat:@"邀请时间：%@", [CommonController stringFromDate:[CommonController dateFromString:rowData[@"AddDate"]] formatType:@"MM-dd HH:mm"]];
    [lbRefreshDate setText:strDate];
    [lbRefreshDate setFont:fontCell];
    [lbRefreshDate setTextColor:colorText];
    //[lbRefreshDate setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbRefreshDate];
    [lbRefreshDate release];

    //在线按钮
    BOOL isOnline = [rowData[@"IsOnline"] boolValue];
    if (isOnline) {
        UIButton *btnChat = [[[UIButton alloc] initWithFrame:CGRectMake(250, 5, 40, 20)] autorelease];
        [btnChat setImage:[UIImage imageNamed:@"ico_joblist_online.png"] forState:UIControlStateNormal];
        [cell.contentView addSubview:btnChat];
    }
    
    //已申请按钮
    NSString *isApply = rowData[@"isApply"];
    if ([isApply isEqualToString:@"1"]) {
        UILabel *lbFavourite = [[[UILabel alloc] initWithFrame:CGRectMake(250, 33, 50, 15)] autorelease];
        [lbFavourite setText:@"已申请"];
        [lbFavourite setFont:fontCell];
        lbFavourite.textAlignment = NSTextAlignmentCenter;
        [lbFavourite setTextColor:[UIColor whiteColor]];
        lbFavourite.layer.cornerRadius = 5;
        lbFavourite.layer.backgroundColor = [UIColor colorWithRed:0.f/255.f green:161.f/255.f blue:233.f/255.f alpha:1].CGColor;
        [cell.contentView addSubview:lbFavourite];
    }
    
    //月薪
    NSString *strdcSalaryId = rowData[@"dcSalaryId"] ;
    NSString *strSalary = [CommonController getDictionaryDesc:strdcSalaryId tableName:@"dcSalary"];
    if (strSalary.length == 0) {
        strSalary = @"面议";
    }
    UILabel *lbSalary = [[UILabel alloc] initWithFrame:CGRectMake(230, 51, 75, 20)];
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
     objc_setAssociatedObject(btnCheck, "favID", rowData[@"ID"], OBJC_ASSOCIATION_RETAIN_NONATOMIC);//传递对象,删除用
    [btnCheck addTarget:self action:@selector(rowChecked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imgCheck = [[UIImageView alloc] initWithFrame:CGRectMake(10, 30, 20, 20)];
    [imgCheck setImage:[UIImage imageNamed:@"chk_default.png"]];
    [btnCheck addSubview:imgCheck];
    [imgCheck release];
    [cell.contentView addSubview:btnCheck];
    [btnCheck release];
    
    //分割线
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, 76, 320, 1)];
    [viewSeparate setBackgroundColor:[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1]];
    [cell.contentView addSubview:viewSeparate];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 77;
}

//选择某一行
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
     NSString *favID = objc_getAssociatedObject(sender, "favID");
    UIImageView *imgCheck = sender.subviews[0];
    if (sender.tag == 1) {
        if (![self.arrCheckJobID containsObject:sender.titleLabel.text]) {
            [self.arrCheckJobID addObject:sender.titleLabel.text];
        }
        if (![self.arrWillBeDeletedID containsObject:favID]) {
            [self.arrWillBeDeletedID addObject:favID];
        }
        [imgCheck setImage:[UIImage imageNamed:@"chk_check.png"]];
        [sender setTag:2];
    }
    else {
        [self.arrCheckJobID removeObject:sender.titleLabel.text];
        if ([self.arrWillBeDeletedID containsObject:favID]) {
            [self.arrWillBeDeletedID removeObject:favID];
        }
        [imgCheck setImage:[UIImage imageNamed:@"chk_default.png"]];
        [sender setTag:1];
    }
    NSLog(@"%@",[self.arrCheckJobID componentsJoinedByString:@","]);
}

- (void)jobApply
{
     UIViewController *pCtrl = [self getFatherController];
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

//收藏职位
- (void)jobFavorite
{
    UIViewController *pCtrl = [self getFatherController];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"UserID"]) {
        //判断是否有选中的职位
        if (self.arrCheckJobID.count == 0) {
            [pCtrl.view makeToast:@"您还没有选择职位"];
            return;
        }
        
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

//删除职位
- (void)jobDelete
{
     UIViewController *pCtrl = [self getFatherController];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"UserID"]) {
        //判断是否有选中的职位
        if (self.arrWillBeDeletedID.count == 0) {
            [pCtrl.view makeToast:@"您还没有选择职位"];
            return;
        }
        //＝＝＝＝＝＝＝＝＝弹出对话框，询问是否退出＝＝＝＝＝＝＝＝＝
        CGSize labelSize = CGSizeMake(240, 30);
        //添加view
        UIView *viewPopup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelSize.width+20, labelSize.height+50)];
        //添加标题“提示”
        UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width+10, 20)];
        [lbTitle setText:@"提示！"];
        [lbTitle setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [lbTitle setTextAlignment:NSTextAlignmentCenter];
        //添加分割线
        UILabel *lbSeperate = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, labelSize.width, 1)];
        [lbSeperate setBackgroundColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        //消息内容
        NSString *strMsg = @"确定要删除选中的职位吗？";
        UILabel *lbMsg = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, labelSize.width, labelSize.height)];
        [lbMsg setText: strMsg];
        [lbMsg setFont:[UIFont systemFontOfSize:14]];
        lbMsg.numberOfLines = 0;
        lbMsg.lineBreakMode = NSLineBreakByCharWrapping;
        [viewPopup addSubview:lbMsg];
        [viewPopup addSubview:lbTitle];
        [viewPopup addSubview:lbSeperate];
        //显示
        self.cPopup = [[[CustomPopup alloc] popupCommon:viewPopup buttonType:PopupButtonTypeConfirmAndCancel] autorelease];
        self.cPopup.delegate = self;
        [self.cPopup showPopup:pCtrl.view];
        [lbMsg release];
        [lbTitle release];
        [lbSeperate release];
        [viewPopup release];
    }
    else {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        LoginViewController *loginC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginView"];
        [self.navigationController pushViewController:loginC animated:true];
    }
}


//点击确定删除
- (void) confirmAndCancelPopupNext
{
    //连接数据库，读取有效简历
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[self.arrWillBeDeletedID componentsJoinedByString:@","] forKey:@"JobId"];
    [dicParam setObject:[userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"DeleteJobInvitation" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 6;
    self.runningRequest = request;
    [dicParam release];
    [loadView startAnimating];

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
    [_btnFavorite release];
    [_viewBottom release];
    [_arrCheckJobID release];
    [_cPopup release];
    [_btnDelete release];
    [_lbTop release];
    [super dealloc];
}
@end
