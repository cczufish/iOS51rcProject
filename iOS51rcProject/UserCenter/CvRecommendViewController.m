//
//  CvRecommendViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-22.
//

#import "CvRecommendViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "Toast+UIView.h"
#import "CommonController.h"
#import "LoginViewController.h"
#import "CustomPopup.h"
#import "SuperJobMainViewController.h"
#import "CvModifyViewController.h"

@interface CvRecommendViewController ()<NetWebServiceRequestDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,CustomPopupDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, retain) NSArray *cvListData;
@property (nonatomic, retain) NSArray *jobListData1;
@property (nonatomic, retain) NSArray *jobListData2;
@property (nonatomic, retain) NSArray *jobListData3;
@property (retain,nonatomic) NSMutableArray* arrCheckJobID;
@property (nonatomic, retain) CustomPopup *cPopup;
@property int tableNumber;
@end

@implementation CvRecommendViewController

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
    [self.navigationItem setTitle:@"推荐职位"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.arrCheckJobID = [[[NSMutableArray alloc] init] autorelease];
    self.tvList1.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tvList2.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tvList3.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.btnApply1.layer.cornerRadius = 5;
    self.btnApply2.layer.cornerRadius = 5;
    self.btnApply3.layer.cornerRadius = 5;
    self.btnCreate.layer.cornerRadius = 5;
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    [loadView startAnimating];
    [self getCvList];
}

- (void)getCvList
{
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetBasicCvListByPaMainID" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 1;
    self.runningRequest = request;
    [dicParam release];
}

- (void)getRecommendList:(NSDictionary *)cvData
{
    NSString *cvId = cvData[@"ID"];
    if ([cvData[@"Valid"] isEqualToString:@"0"]) {
        CGRect frameModifyCv = self.btnModifyCv.frame;
        frameModifyCv.origin.x = self.scrollContent.contentOffset.x;
        [self.btnModifyCv setTag:[cvId intValue]];
        [self.btnModifyCv setFrame:frameModifyCv];
        [self.btnModifyCv setHidden:false];
        return;
    }
    [self.btnModifyCv setHidden:true];
    [loadView startAnimating];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    [dicParam setObject:cvId forKey:@"cvMainID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetRecommendJobListByCvID" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 2;
    self.runningRequest = request;
    [dicParam release];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSMutableArray *)requestData
{
    [loadView stopAnimating];
    if (request.tag == 1) {
        self.cvListData = requestData;
        if (requestData.count == 0) { //没有简历
            [self.viewCvList setHidden:true];
            [self.viewOperate setHidden:true];
            [self.btnCreate setHidden:false];
        }
        else { //有简历
            for (int i=0; i<requestData.count; i++) {
                switch (i) {
                    case 0:
                    {
                        if (requestData.count == 1) {
                            //移除
                            [self.lbCv2 removeFromSuperview];
                            [self.btnCv2 removeFromSuperview];
                            [self.viewJobList2 removeFromSuperview];
                            [self.lbCv3 removeFromSuperview];
                            [self.btnCv3 removeFromSuperview];
                            [self.viewJobList3 removeFromSuperview];
                            
                            //更改按钮宽度
                            CGRect frameLabelCv1 = self.lbCv1.frame;
                            frameLabelCv1.size.width = 320;
                            [self.lbCv1 setFrame:frameLabelCv1];
                            
                            CGRect frameButtonCv1 = self.btnCv1.frame;
                            frameButtonCv1.size.width = 320;
                            [self.btnCv1 setFrame:frameButtonCv1];
                            
                            CGRect frameLabelSwitch = self.lbSwitch.frame;
                            frameLabelSwitch.size.width = 320;
                            [self.lbSwitch setFrame:frameLabelSwitch];
                            
                            //更改scroll宽度
                            CGSize sizeScroll = self.scrollContent.contentSize;
                            sizeScroll.width = 320;
                            [self.scrollContent setContentSize:sizeScroll];
                        }
                        else if (requestData.count == 2) {
                            //移除
                            [self.lbCv3 removeFromSuperview];
                            [self.btnCv3 removeFromSuperview];
                            [self.viewJobList3 removeFromSuperview];
                            //更改按钮宽度
                            CGRect frameLabelCv1 = self.lbCv1.frame;
                            frameLabelCv1.size.width = 160;
                            [self.lbCv1 setFrame:frameLabelCv1];
                            
                            CGRect frameButtonCv1 = self.btnCv1.frame;
                            frameButtonCv1.size.width = 160;
                            [self.btnCv1 setFrame:frameButtonCv1];
                            
                            CGRect frameLabelCv2 = self.lbCv2.frame;
                            frameLabelCv2.size.width = 160;
                            frameLabelCv2.origin.x = 160;
                            [self.lbCv2 setFrame:frameLabelCv2];
                            
                            CGRect frameButtonCv2 = self.btnCv2.frame;
                            frameButtonCv2.size.width = 160;
                            frameButtonCv2.origin.x = 160;
                            [self.btnCv2 setFrame:frameButtonCv2];
                            
                            CGRect frameLabelSwitch = self.lbSwitch.frame;
                            frameLabelSwitch.size.width = 160;
                            [self.lbSwitch setFrame:frameLabelSwitch];
                            //更改scroll宽度
                            CGSize sizeScroll = self.scrollContent.contentSize;
                            sizeScroll.width = 640;
                            [self.scrollContent setContentSize:sizeScroll];
                        }
                        else {
                            //更改scroll宽度
                            CGSize sizeScroll = self.scrollContent.contentSize;
                            sizeScroll.width = 960;
                            [self.scrollContent setContentSize:sizeScroll];
                        }
                        [self.lbCv1 setText:requestData[i][@"Name"]];
                        [self.btnCv1 setTag:[requestData[i][@"ID"] intValue]];
                        break;
                    }
                    case 1:
                        [self.lbCv2 setText:requestData[i][@"Name"]];
                        [self.btnCv2 setTag:[requestData[i][@"ID"] intValue]];
                        break;
                    case 2:
                        [self.lbCv3 setText:requestData[i][@"Name"]];
                        [self.btnCv3 setTag:[requestData[i][@"ID"] intValue]];
                        break;
                    default:
                        break;
                }
            }
            self.tableNumber = 1;
            [self getRecommendList:requestData[0]];
        }
    }
    else if (request.tag == 2) {
        switch (self.tableNumber) {
            case 1:
                self.jobListData1 = requestData;
                [self.tvList1 reloadData];
                break;
            case 2:
                self.jobListData2 = requestData;
                [self.tvList2 reloadData];
                break;
            case 3:
                self.jobListData3 = requestData;
                [self.tvList3 reloadData];
                break;
            default:
                break;
        }
    }
    else if (request.tag == 3) { //获取可投递的简历，默认投递第一份简历
        if (requestData.count == 0) {
            [self.view makeToast:@"您没有有效简历，请先完善您的简历"];
        }
        else {
            self.cPopup = [[[CustomPopup alloc] popupCvSelect:requestData] autorelease];
            [self.cPopup setDelegate:self];
            [self insertJobApply:requestData[0][@"ID"] isFirst:YES];
        }
    }
    else if (request.tag == 4) { //默认投递完之后，显示弹层
        [self.cPopup showJobApplyCvSelect:result view:self.view];
    }
    else if (request.tag == 5) { //重新申请职位成功
        [self.view makeToast:@"简历更换成功"];
    }
    else if (request.tag == 6) {
        [self.view makeToast:@"收藏成功"];
    }
}

- (IBAction)switchToCv1:(UIButton *)sender {
    [self.scrollContent setContentOffset:CGPointMake(0, 0) animated:true];
    [UIView animateWithDuration:0.4 animations:^{
        [self.lbCv2 setTextColor:[UIColor blackColor]];
        [self.lbCv3 setTextColor:[UIColor blackColor]];
        [self.lbCv1 setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbSwitch setFrame:CGRectMake((320/self.cvListData.count)*0, self.lbSwitch.frame.origin.y, self.lbSwitch.frame.size.width, self.lbSwitch.frame.size.height)];
    } completion:^(BOOL finished) {
        if (!self.jobListData1) {
            self.tableNumber = 1;
            [self getRecommendList:self.cvListData[0]];
        }
    }];
}

- (IBAction)switchToCv2:(UIButton *)sender {
    [self.scrollContent setContentOffset:CGPointMake(320, 0) animated:true];
    [UIView animateWithDuration:0.4 animations:^{
        [self.lbCv1 setTextColor:[UIColor blackColor]];
        [self.lbCv3 setTextColor:[UIColor blackColor]];
        [self.lbCv2 setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbSwitch setFrame:CGRectMake((320/self.cvListData.count)*1, self.lbSwitch.frame.origin.y, self.lbSwitch.frame.size.width, self.lbSwitch.frame.size.height)];
    } completion:^(BOOL finished) {
        if (!self.jobListData2) {
            self.tableNumber = 2;
            [self getRecommendList:self.cvListData[1]];
        }
    }];
}
- (IBAction)switchToCv3:(UIButton *)sender {
    [self.scrollContent setContentOffset:CGPointMake(640, 0) animated:true];
    [UIView animateWithDuration:0.4 animations:^{
        [self.lbCv1 setTextColor:[UIColor blackColor]];
        [self.lbCv2 setTextColor:[UIColor blackColor]];
        [self.lbCv3 setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbSwitch setFrame:CGRectMake((320/self.cvListData.count)*2, self.lbSwitch.frame.origin.y, self.lbSwitch.frame.size.width, self.lbSwitch.frame.size.height)];
    } completion:^(BOOL finished) {
        if (!self.jobListData3) {
            self.tableNumber = 3;
            [self getRecommendList:self.cvListData[2]];
        }
    }];
}

- (IBAction)jobApply:(UIButton *)sender
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
        request.tag = 3;
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

- (IBAction)jobFavorite:(UIButton *)sender
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
        request.tag = 6;
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

- (IBAction)switchToMyCv:(id)sender {
    UIViewController *viewC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyCvView"];
    [self.navigationController pushViewController:viewC animated:true];
}

- (IBAction)switchToModifyCv:(UIButton *)sender {
    CvModifyViewController *cvModifyC = [self.storyboard instantiateViewControllerWithIdentifier:@"CvModifyView"];
    cvModifyC.cvId = [NSString stringWithFormat:@"%d",sender.tag];
    [self.navigationController pushViewController:cvModifyC animated:true];
}

- (void) getPopupValue:(NSString *)value
{
    [self insertJobApply:value isFirst:NO];
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
        request.tag = 4;
    }
    else {
        request.tag = 5;
    }
    self.runningRequest = request;
    [dicParam release];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollContent.contentOffset.x > 480) {
        [self switchToCv3:nil];
    }
    else if (self.scrollContent.contentOffset.x > 160) {
        [self switchToCv2:nil];
    }
    else {
        [self switchToCv1:nil];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (tableView.tag) {
        case 1:
            return self.jobListData1.count;
            break;
        case 2:
            return self.jobListData2.count;
            break;
        case 3:
            return self.jobListData3.count;
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 77;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rowData = nil;
    switch (tableView.tag) {
        case 1:
            rowData = self.jobListData1[indexPath.row];
            break;
        case 2:
            rowData = self.jobListData2[indexPath.row];
            break;
        case 3:
            rowData = self.jobListData3[indexPath.row];
            break;
        default:
            return 0;
            break;
    }
    UIFont *fontCell = [UIFont systemFontOfSize:14];
    UIColor *colorText = [UIColor colorWithRed:120.f/255.f green:120.f/255.f blue:120.f/255.f alpha:1];
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"jobList"] autorelease];
    //职位名称
    UILabel *lbJobName = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, 200, 20)];
    [lbJobName setText:rowData[@"JobName"]];
    [lbJobName setFont:[UIFont systemFontOfSize:14]];
    [cell.contentView addSubview:lbJobName];
    [lbJobName release];
    
    //匹配度
    UILabel *lbMatch = [[UILabel alloc] initWithFrame:CGRectMake(270, 5, 45, 20)];
    [lbMatch setText:[NSString stringWithFormat:@"匹配度%@%%",rowData[@"matchPercent"]]];
    lbMatch.layer.cornerRadius = 5;
    lbMatch.layer.masksToBounds = YES;
    [lbMatch setTextAlignment:NSTextAlignmentCenter];
    [lbMatch setTextColor:[UIColor whiteColor]];
    [lbMatch setFont:[UIFont systemFontOfSize:8]];
    [lbMatch setBackgroundColor:[UIColor colorWithRed:14.f/255.f green:170.f/255.f blue:32.f/255.f alpha:1]];
    [cell.contentView addSubview:lbMatch];
    [lbMatch release];
    
    //是否在线
    if ([rowData[@"IsOnline"] isEqualToString:@"true"]) {
        UIImageView *imgOnline = [[UIImageView alloc] initWithFrame:CGRectMake(225, 5, 40, 20)];
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
    [viewSeparate setBackgroundColor:[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1]];
    [cell.contentView addSubview:viewSeparate];
    [viewSeparate release];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rowData = nil;
    switch (tableView.tag) {
        case 1:
            rowData = self.jobListData1[indexPath.row];
            break;
        case 2:
            rowData = self.jobListData2[indexPath.row];
            break;
        case 3:
            rowData = self.jobListData3[indexPath.row];
            break;
        default:
            break;
    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CpAndJob" bundle:nil];
    SuperJobMainViewController *jobC = [storyBoard instantiateViewControllerWithIdentifier:@"SuperJobMainView"];
    jobC.JobID = rowData[@"ID"];
    jobC.cpMainID = rowData[@"cpMainID"];
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
    [loadView release];
    [_runningRequest release];
    [_userDefaults release];
    [_cvListData release];
    [_jobListData1 release];
    [_jobListData2 release];
    [_jobListData3 release];
    [_arrCheckJobID release];
    [_cPopup release];
    [_lbCv1 release];
    [_lbCv2 release];
    [_lbCv3 release];
    [_btnCv1 release];
    [_btnCv2 release];
    [_btnCv3 release];
    [_lbSwitch release];
    [_viewCvList release];
    [_btnApply1 release];
    [_btnApply2 release];
    [_btnApply3 release];
    [_btnFavorite release];
    [_viewOperate release];
    [_btnCreate release];
    [_viewJobList1 release];
    [_viewJobList2 release];
    [_viewJobList3 release];
    [_scrollContent release];
    [_tvList1 release];
    [_tvList2 release];
    [_tvList3 release];
    [_btnModifyCv release];
    [super dealloc];
}
@end
