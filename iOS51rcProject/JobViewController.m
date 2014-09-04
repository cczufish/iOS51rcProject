//
//  JobViewController.m
//  iOS51rcProject
//
//  Created by qlrc on 14-8-25.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import "JobViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "MJRefresh.h"

@interface JobViewController ()<NetWebServiceRequestDelegate,UIScrollViewDelegate>
@property (retain, nonatomic) IBOutlet UIScrollView *jobMainScroll;
@property (retain, nonatomic) IBOutlet UILabel *lbJobName;
@property (retain, nonatomic) IBOutlet UILabel *lbFereashTime;
@property (retain, nonatomic) IBOutlet UILabel *lbCpName;
@property (retain, nonatomic) IBOutlet UILabel *lbCpNameValue;
@property (retain, nonatomic) IBOutlet UILabel *lbWorkPlace;
@property (retain, nonatomic) IBOutlet UILabel *lbWorkPlaceValue;
@property (retain, nonatomic) IBOutlet UILabel *lbJobRequest;
@property (retain, nonatomic) IBOutlet UILabel *lbJobRequestValue;
@property (retain, nonatomic) IBOutlet UILabel *lbSalary;
@property (retain, nonatomic) IBOutlet UILabel *lbSpitLine2;
@property (retain, nonatomic) IBOutlet UILabel *lbSpitLine3;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) LoadingAnimationView *loading;
@property (retain, nonatomic) NSString *wsName;//当前调用的webservice名称
@property (retain, nonatomic) IBOutlet UITableView *tvRecommentJobList;
@property (retain, nonatomic) IBOutlet UIView *subView;

@end

@implementation JobViewController

@synthesize runningRequest = _runningRequest;
@synthesize loading = _loading;
@synthesize JobID;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"scrollViewDidScroll......");
}

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
    self.jobMainScroll.delegate = self;
    self.JobID = @"4509150";
    //NSLog(@"%@",self.recruitmentID);
//    self.btnRmCp.layer.masksToBounds = YES;
//    self.btnRmCp.layer.borderWidth = 1.0;
//    self.btnRmCp.layer.borderColor = [[UIColor grayColor] CGColor];
//    
//    self.btnRmPa.layer.masksToBounds = YES;
//    self.btnRmPa.layer.borderWidth = 1.0;
//    self.btnRmPa.layer.borderColor = [[UIColor grayColor] CGColor];
    
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.JobID forKey:@"JobID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetJobInfo" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
    self.wsName = @"GetJobInfo";//当前调用的函数名称
    self.loading = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
   
    [self.loading startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    if ([self.wsName isEqualToString:@"GetJobInfo"]) {
        [self didReceiveJobMain:requestData];
    }
    else if ([self.wsName isEqualToString:@"GetRecommendJobByJobID"]){
        [self didReceiveRecommendJob:(NSMutableArray *)requestData];
    }
}

//第一个消息完成了以后再调用第二个消息(其他职位)
-(void) didReceiveRecommendJob:(NSMutableArray *) requestData{
    [recommentJobsData removeAllObjects];
    recommentJobsData = requestData;
    [recommentJobsData retain];
    
    [self.tvRecommentJobList reloadData];
    [self.tvRecommentJobList footerEndRefreshing];
    
    //结束等待动画
    [self.loading stopAnimating];
}

//绑定浏览的其他职位
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =
    [[[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"JobList"] autorelease];
    
    NSDictionary *rowData = recommentJobsData[indexPath.row];
    //职位名称
    NSString *strRecruitmentName = rowData[@"JobName"];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, 60, 15)];
    lbTitle.text = strRecruitmentName;
    lbTitle.font = [UIFont systemFontOfSize:12];
    lbTitle.textColor = [UIColor blackColor];
    [cell.contentView addSubview:(lbTitle)];
    [lbTitle release];
    //待遇
    UILabel *lbSalaryID = [[UILabel alloc] initWithFrame:CGRectMake(20, self.tvRecommentJobList.frame.origin.x + self.tvRecommentJobList.frame.size.width - 200, 180, 15)];
    NSString *strSalaryID = rowData[@"dcSalaryID"];
    lbSalaryID.font = [UIFont systemFontOfSize:12];
    lbSalaryID.textColor = [UIColor redColor];
    lbSalaryID.text = strSalaryID;
    lbSalaryID.textAlignment = NSTextAlignmentRight;
    [cell.contentView addSubview:(lbSalaryID)];
    [lbSalaryID release];
    return cell;
}

//点击某一行,到达企业页面--调用代理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[gotoRmViewDelegate gotoRmView:recruitmentCpData[indexPath.row][@"id"]];
}

//每一行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 20;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [recommentJobsData count];
}

//绑定职位信息
-(void) didReceiveJobMain:(NSArray *) requestData
{
    NSDictionary *dicJob = requestData[0];
    //职位名称
    NSString *jobName = dicJob[@"Name"];
    CGSize labelSize = [CommonController CalculateFrame:jobName fontDemond:[UIFont systemFontOfSize:16] sizeDemand:CGSizeMake(self.lbJobName.frame.size.width, 500)];
    self.lbJobName.frame = CGRectMake(20, 15, labelSize.width, labelSize.height);
    self.lbJobName.lineBreakMode = NSLineBreakByCharWrapping;
    self.lbJobName.numberOfLines = 0;
    [self.lbJobName setText:jobName];
    //刷新时间
    self.lbFereashTime.textColor = [UIColor grayColor];
    NSDate *refreshDate = [CommonController dateFromString:dicJob[@"RefreshDate"]];
    NSString *strRefreshDate = [CommonController stringFromDate:refreshDate formatType:@"MM-dd HH:mm"];
    [self.lbFereashTime setText:[NSString stringWithFormat:@"刷新时间：%@", strRefreshDate]];
    //待遇
    NSString *strSalary = dicJob[@"Salary"];
    self.lbSalary.text = strSalary;
    //公司名称
    self.lbCpName.textColor = [UIColor grayColor];
    [self.lbCpNameValue setText:dicJob[@"cpName"]];
    //工作地点
    NSString *strJobRegion = dicJob[@"JobRegion"];
    labelSize = [CommonController CalculateFrame:strJobRegion fontDemond:[UIFont systemFontOfSize:16] sizeDemand:CGSizeMake(self.lbJobName.frame.size.width, 500)];
    self.lbWorkPlace.textColor = [UIColor grayColor];
    self.lbWorkPlaceValue.frame = CGRectMake(76, 122, labelSize.width, 15);
    [self.lbWorkPlaceValue setText:strJobRegion];
    //坐标
    UIButton *btnLngLat = [[UIButton alloc] initWithFrame:CGRectMake(self.lbWorkPlaceValue.frame.size.width + self.lbWorkPlaceValue.frame.origin.x, self.lbWorkPlaceValue.frame.origin.y + self.lbWorkPlaceValue.frame.size.height - 15, 15, 15)];
    //NSString *lng = rowData[@"lng"];
    //NSString *lat = rowData[@"lat"];
    UIImageView *imgLngLat = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    imgLngLat.image = [UIImage imageNamed:@"ico_coordinate_red.png"];
    [btnLngLat addSubview:imgLngLat];
    btnLngLat.tag = (NSInteger)dicJob[@"ID"];
    //[btnLngLat addTarget:self action:@selector(btnLngLatClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.subView addSubview:btnLngLat];
    [btnLngLat release];
    [imgLngLat release];

    //招聘人数
    NSString *num = dicJob[@"NeedNumber"];
    //学历
    NSString *education = dicJob[@"Education"];
    //年龄
    NSString *minAge = dicJob[@"MinAge"];
    NSString *maxAge = dicJob[@"MaxAge"];
    //经验
    NSString *experience = dicJob[@"Experience"];
    //全职与否
    NSString *employType = dicJob[@"EmployType"];
    //招聘条件
    self.lbJobRequest.textColor = [UIColor grayColor];
    self.lbJobRequestValue.text = [NSString stringWithFormat:@"%@|%@|%@-%@|%@|%@", num, education, minAge, maxAge, experience, employType];
    //岗位职责------hight = 166
    UILabel *lbResponsibility = [[UILabel alloc] initWithFrame:CGRectMake(20, self.lbJobRequest.frame.origin.y + self.lbJobRequest.frame.size.height + 5, 200, 15)];
    lbResponsibility.textColor = [UIColor grayColor];
    lbResponsibility.text = @"岗位职责";
    lbResponsibility.font = [UIFont systemFontOfSize:12];
    
    NSString *strResponsibility = dicJob[@"Responsibility"];
    labelSize = [CommonController CalculateFrame:strResponsibility fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(280, 500)];
     UILabel *lbResponsibilityInput = [[UILabel alloc] initWithFrame:CGRectMake(20, lbResponsibility.frame.origin.y + lbResponsibility.frame.size.height + 5, labelSize.width, labelSize.height)];
    lbResponsibilityInput.lineBreakMode = NSLineBreakByCharWrapping;
    lbResponsibilityInput.numberOfLines = 0;
    lbResponsibilityInput.font = [UIFont systemFontOfSize:12];
    lbResponsibilityInput.text = strResponsibility;
    [self.subView addSubview:lbResponsibilityInput];
    [self.subView addSubview:lbResponsibility];
    [lbResponsibility release];
    [lbResponsibilityInput release];
    //岗位要求
    UILabel *lbDemand = [[UILabel alloc] initWithFrame:CGRectMake(20, lbResponsibilityInput.frame.origin.y+lbResponsibilityInput.frame.size.height + 5, 200, 15)];
    lbDemand.textColor = [UIColor grayColor];
    lbDemand.text = @"岗位要求";
    lbDemand.font = [UIFont systemFontOfSize:12];
    NSString *strDemand = dicJob[@"Demand"];
    labelSize = [CommonController CalculateFrame:strDemand fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(280, 500)];
    UILabel *lbDemandInput = [[UILabel alloc] initWithFrame:CGRectMake(20, lbDemand.frame.origin.y+lbDemand.frame.size.height + 5, labelSize.width, labelSize.height)];
    lbDemandInput.lineBreakMode = NSLineBreakByCharWrapping;
    lbDemandInput.numberOfLines = 0;
    lbDemandInput.text = strDemand;
    lbDemandInput.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbDemand];
    [self.subView addSubview:lbDemandInput];
    [lbDemand release];
    [lbDemandInput release];
    
    //第二个分割线
    CGFloat y = lbDemand.frame.origin.y + lbDemand.frame.size.height + 70;
    self.lbSpitLine2.frame = CGRectMake(8, y, 304, 22);
    //联系人
    NSString *strCaName = dicJob[@"caName"];
    UILabel *lbCaName = [[UILabel alloc] initWithFrame:CGRectMake(20, lbDemandInput.frame.origin.y + lbDemandInput.frame.size.height + 35, 64, 15)];
    lbCaName.textColor = [UIColor grayColor];
    lbCaName.text = @"联 系人：";
    lbCaName.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:lbCaName];
    [lbCaName release];
    
    UILabel *lbCaNameValue = [[UILabel alloc]initWithFrame:CGRectMake(76, lbDemandInput.frame.origin.y + lbDemandInput.frame.size.height + 35, 200, 15)];
    lbCaNameValue.text = strCaName;
    lbCaNameValue.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:lbCaNameValue];
    [lbCaNameValue release];
    
    //职务
    NSString *strCaTitle = dicJob[@"caTitle"];
    UILabel *lbCaTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, lbCaNameValue.frame.origin.y+lbCaNameValue.frame.size.height + 5, 64, 15)];
    lbCaTitle.textColor = [UIColor grayColor];
    lbCaTitle.text = @"职  务：";
    lbCaTitle.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:lbCaTitle];
    [lbCaTitle release];
    
    UILabel *lbCaTitleValue = [[UILabel alloc] initWithFrame:CGRectMake(76, lbCaNameValue.frame.origin.y+lbCaNameValue.frame.size.height + 5, 200, 15)];
    lbCaTitleValue.text = strCaTitle;
    lbCaTitleValue.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:lbCaTitleValue];
    [lbCaTitleValue release];
    
    //所在部门
    NSString *strCaDept = dicJob[@"caDept"];
    UILabel *lbDept = [[UILabel alloc]initWithFrame:CGRectMake(20, lbCaTitle.frame.origin.y+lbCaTitle.frame.size.height + 5, 64, 15)];
    lbDept.textColor = [UIColor grayColor];
    lbDept.text = @"所在部门：";
    lbDept.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:lbDept];
    [lbDept release];
    
    UILabel *lbDeptValue = [[UILabel alloc] initWithFrame:CGRectMake(76, lbCaTitleValue.frame.origin.y+lbCaTitleValue.frame.size.height + 5 , 200, 15)];
    lbDeptValue.text = strCaDept;
    lbDeptValue.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:lbDeptValue];
    [lbDeptValue release];
    
    //联系电话
    NSString *strCaTel = dicJob[@"caTel"];
    UILabel *lbCaTel = [[UILabel alloc] initWithFrame:CGRectMake(20, lbDept.frame.origin.y+lbDept.frame.size.height  + 5, 64, 15)];
    lbCaTel.textColor = [UIColor grayColor];
    lbCaTel.text = @"联系电话：";
    lbCaTel.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:lbCaTel];
    [lbCaTel release];
    
    labelSize = [CommonController CalculateFrame:strCaTel fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(280, 500)];
    UILabel *lbCaTelValue = [[UILabel alloc]initWithFrame: CGRectMake(76, lbDept.frame.origin.y+lbDept.frame.size.height + 5, labelSize.width, 15)];
    lbCaTelValue.text = strCaTel;
    lbCaTelValue.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:lbCaTelValue];
    [lbCaTelValue release];
    
    //联系电话后的图片
    UIImageView *imgMobile = [[UIImageView alloc] initWithFrame:CGRectMake(lbCaTelValue.frame.origin.x + lbCaTelValue.frame.size.width, lbCaTelValue.frame.origin.y, 15, 15)];
    imgMobile.image = [UIImage imageNamed:@"ico_calltelphone.png"];
    //imgMobile.tag = (NSInteger)rowData[@"ID"];
    [self.view addSubview:imgMobile];
    [imgMobile release];
    
    //第三个分割线
    y = lbDept.frame.origin.y + lbDept.frame.size.height + 5;
    self.lbSpitLine3.frame = CGRectMake(8, y, 304, 0.5);

        //浏览了该职位的还查看了
    //NSString *strOther = @"浏览了该职位的还查看了以下职位";
    [self.loading stopAnimating];
//    labelSize = [CommonController CalculateFrame:strOther fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(280, 500)];
//    UILabel *lbOther = [[UILabel alloc] initWithFrame:CGRectMake(20, lbCaTel.frame.origin.y+lbCaTel.frame.size.height  + 5, labelSize.width, 15)];
//    lbOther.textColor = [UIColor grayColor];
//    lbOther.text = strOther;
//    lbOther.font = [UIFont systemFontOfSize:12];
//    [self.view addSubview:lbOther];
//    [lbOther release];
//    //其他职位----调用Webservice
//    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
//    [dicParam setObject:self.JobID forKey:@"JobID"];
//    [dicParam setObject:@"8500" forKey:@"SearchFromID"];
//    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetRecommendJobByJobID" Params:dicParam];
//    [request setDelegate:self];
//    [request startAsynchronous];
//    self.runningRequest = request;
//    self.wsName = @"GetRecommendJobByJobID";//当前调用的函数名称
//    
//    self.tvRecommentJobList.frame = CGRectMake(20, lbOther.frame.origin.y+lbOther.frame.size.height - 100, 280, 160);
    //页面滚动
    self.jobMainScroll.frame = CGRectMake(self.jobMainScroll.frame.origin.x, self.jobMainScroll.frame.origin.y, 320, 400);
    [self.jobMainScroll setContentSize:CGSizeMake(320, 1600)];
}

- (void)call:(UIButton *)sender {
    NSString *strCallNumber;
    if (sender.tag == 1) {
        //strCallNumber = self.recruitmentMobile;
    }
    else {
        //strCallNumber = self.recruitmentTelephone;
    }
    UIWebView*callWebview =[[UIWebView alloc] init];
    NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",strCallNumber]];
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    //记得添加到view上
    [self.view addSubview:callWebview];
}

- (void)dealloc {
    //[_nibName release];
    [_lbFereashTime release];
    [_wsName release];
    [_lbWorkPlaceValue release];
    [_lbJobRequestValue release];
    [_lbSalary release];
    [_lbSpitLine2 release];
    [_lbSpitLine3 release];

    [_jobMainScroll release];
    [_lbCpName release];
    [_lbWorkPlace release];
    [_lbJobRequest release];
    [_contentView release];
    
    [_tvRecommentJobList release];
    [_subView release];
    [super dealloc];
}
@end
