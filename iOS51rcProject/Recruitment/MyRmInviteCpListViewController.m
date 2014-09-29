#import "MyRmInviteCpListViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "MJRefresh.h"
#import "CpMainViewController.h"
#import "SuperCpViewController.h"
#import "SuperJobMainViewController.h"

//＝＝＝＝＝＝＝＝我邀请的企业＝＝＝＝＝＝
@interface MyRmInviteCpListViewController ()<NetWebServiceRequestDelegate>
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) IBOutlet UITableView *tvRecruitmentCpList;
@end

@implementation MyRmInviteCpListViewController

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
    UIButton *button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [button setTitle: @"我的招聘会" forState: UIControlStateNormal];
    [button sizeToFit];
    self.navigationItem.titleView = button;
       
    [super viewDidLoad];
    //self.rmID = @"95935";
    //数据加载等待控件初始化
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    [self onSearch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
}
- (void)onSearch
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *code = [userDefaults objectForKey:@"code"];
    NSString *userID = [userDefaults objectForKey:@"UserID"];

    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.rmID forKey:@"recruitmentID"];
    [dicParam setObject:code forKey:@"code"];
    [dicParam setObject:userID forKey:@"paMainID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetMyInviteCpLogList" Params:dicParam];
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
    
    [recruitmentCpData removeAllObjects];
    recruitmentCpData = requestData;
    [recruitmentCpData retain];
    [self.tvRecruitmentCpList reloadData];
    [self.tvRecruitmentCpList footerEndRefreshing];
    
    //结束等待动画
    [loadView stopAnimating];
}

//绑定数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell =
    [[[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"cpList"] autorelease];
    
    NSDictionary *rowData = recruitmentCpData[indexPath.row];
    //审核图标
    UIImageView *imgShen = [[UIImageView alloc] initWithFrame:CGRectMake(20, 16, 14, 14)];
    imgShen.image = [UIImage imageNamed:@"ico_shen.png"];
    [cell.contentView addSubview:imgShen];
    [imgShen release];
    
    //企业名称
    NSString *strCpName = rowData[@"companyName"];
    UIFont *titleFont = [UIFont systemFontOfSize:14];
    CGFloat titleWidth = 220;
    CGSize titleSize = CGSizeMake(titleWidth, 5000.0f);
    CGSize labelSize = [CommonController CalculateFrame:strCpName fontDemond:titleFont sizeDemand:titleSize];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(35, 15, labelSize.width, labelSize.height)];
    lbTitle.text = strCpName;
    lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
    lbTitle.numberOfLines = 0;
    lbTitle.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:(lbTitle)];
    
    //应聘职位前面的label
    UILabel *lbPreCpName = [[UILabel alloc] initWithFrame:CGRectMake(20, lbTitle.frame.origin.y+lbTitle.frame.size.height+5, 60, 15)];
    lbPreCpName.text = @"应聘职位：";
    lbPreCpName.textColor = [UIColor grayColor];
    lbPreCpName.font = [UIFont systemFontOfSize:12];
    [cell.contentView addSubview:lbPreCpName];
    [lbPreCpName release];
    
    //应聘职位
    NSString *strAddress = rowData[@"JobName"];
    labelSize = [CommonController CalculateFrame:strAddress fontDemond:[UIFont systemFontOfSize:12] sizeDemand:titleSize];
    UILabel *lbPaInfo = [[UILabel alloc] initWithFrame:CGRectMake(80, lbTitle.frame.origin.y+lbTitle.frame.size.height + 5, labelSize.width, labelSize.height)];
    lbPaInfo.text = strAddress;
    lbPaInfo.font = [UIFont systemFontOfSize:12];
    lbPaInfo.textColor = [UIColor redColor];
    [cell.contentView addSubview:(lbPaInfo)];
    
    //邀请时间
    NSString *strBeginDate = rowData[@"AddDate"];
    NSDate *dtBeginDate = [CommonController dateFromString:strBeginDate];
    strBeginDate = [CommonController stringFromDate:dtBeginDate formatType:@"yyyy-MM-dd HH:mm"];
    NSString *strWeek = [CommonController getWeek:dtBeginDate];
    strBeginDate = [NSString stringWithFormat:@"邀请时间：%@ %@",strBeginDate,strWeek];
    
    labelSize = [CommonController CalculateFrame:strBeginDate fontDemond:[UIFont systemFontOfSize:12] sizeDemand:titleSize];
    UILabel *lbBegin = [[UILabel alloc] initWithFrame:CGRectMake(20, lbPaInfo.frame.origin.y+lbPaInfo.frame.size.height + 5, labelSize.width, labelSize.height)];
    lbBegin.text = strBeginDate;
    lbBegin.font = [UIFont systemFontOfSize:12];
    lbBegin.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbBegin)];
    
    //参会按钮
    NSString *strStatus = rowData[@"Status"];
   
    UILabel *lbStatus = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, 40, 15)];;//参会状态
    //UILabel *lbWillRun;
    UIImageView *imgWillRun = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    //如果未答复，没有图片，只显示“已预约”三个字
    if ([strStatus isEqualToString:@"0"]) {
        lbStatus.frame = CGRectMake(260, 18, 40, 15);
        lbStatus.text = @"未答复";
        lbStatus.font = [UIFont systemFontOfSize:12];
        lbStatus.textColor = [UIColor whiteColor];
        lbStatus.textAlignment = NSTextAlignmentCenter;
        lbStatus.layer.cornerRadius = 7;
        lbStatus.layer.backgroundColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
    }else if ([strStatus isEqualToString:@"1"]) {
        //如果参会
        lbStatus.frame = CGRectMake(260, 18, 40, 15);
        lbStatus.text = @"参会";
        lbStatus.font = [UIFont systemFontOfSize:12];
        lbStatus.textColor = [UIColor whiteColor];
        lbStatus.textAlignment = NSTextAlignmentCenter;
        lbStatus.layer.cornerRadius = 7;
        lbStatus.layer.backgroundColor = [UIColor greenColor].CGColor;
        //参展号码
        UILabel *lbDeskNo = [[UILabel alloc] initWithFrame:CGRectMake(240, 30, 60, 15)];
        NSString *strDeskNo = rowData[@"DeskNo"];
        lbDeskNo.text = [NSString stringWithFormat:@"展位号：%@", strDeskNo];
        lbDeskNo.textColor = [UIColor grayColor];
        lbDeskNo.font = [UIFont systemFontOfSize:12];
        lbDeskNo.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:lbDeskNo];
        [lbDeskNo release];
        //答复时间
        UILabel *lbReplyTime = [[UILabel alloc] initWithFrame:CGRectMake(200, 50, 160, 15)];
        NSString *strReplyDate = rowData[@"ReplyDate"];
        NSDate *dtReplyDate = [CommonController dateFromString:strReplyDate];
        strReplyDate = [CommonController stringFromDate:dtReplyDate formatType:@"yyyy-MM-dd HH:mm"];
        strWeek = [CommonController getWeek:dtReplyDate];
        strReplyDate = [NSString stringWithFormat:@"答复时间：%@ %@",dtReplyDate,strWeek];
        lbReplyTime.textColor = [UIColor grayColor];
        lbReplyTime.font = [UIFont systemFontOfSize:12];
        lbReplyTime.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:lbReplyTime];
        [lbReplyTime release];
    }else{
        //不参会
        lbStatus.frame = CGRectMake(260, 18, 40, 15);
        lbStatus.text = @"不参会";
        lbStatus.font = [UIFont systemFontOfSize:12];
        lbStatus.textColor = [UIColor whiteColor];
        lbStatus.textAlignment = NSTextAlignmentCenter;
        lbStatus.layer.cornerRadius = 7;
        lbStatus.layer.backgroundColor = [UIColor orangeColor].CGColor;
        
        //答复时间
        UILabel *lbReplyTime = [[UILabel alloc] initWithFrame:CGRectMake(200, 320, 160, 15)];
        NSString *strReplyDate = rowData[@"ReplyDate"];
        NSDate *dtReplyDate = [CommonController dateFromString:strReplyDate];
        strReplyDate = [CommonController stringFromDate:dtReplyDate formatType:@"yyyy-MM-dd HH:mm"];
        strWeek = [CommonController getWeek:dtReplyDate];
        strReplyDate = [NSString stringWithFormat:@"答复时间：%@ %@",dtReplyDate,strWeek];
        lbReplyTime.textColor = [UIColor grayColor];
        lbReplyTime.font = [UIFont systemFontOfSize:12];
        lbReplyTime.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:lbReplyTime];
        [lbReplyTime release];
    }
   
    [cell.contentView addSubview:lbStatus];
    
    [lbStatus release];
    [imgWillRun release];
    [lbTitle release];
    [lbPaInfo release];
    [lbBegin release];
    return cell;
}

//点击某一行,到达企业页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *jobSearchStoryboard = [UIStoryboard storyboardWithName:@"JobSearch" bundle:nil];
    SuperJobMainViewController *jobCtrl = (SuperJobMainViewController*)[jobSearchStoryboard instantiateViewControllerWithIdentifier: @"SuperJobMainView"];
    jobCtrl.cpMainID = recruitmentCpData[indexPath.row][@"cpMainID"];
    jobCtrl.JobID = recruitmentCpData[indexPath.row][@"JobID"];
    [self.navigationController pushViewController:jobCtrl animated:true];
}

//点击我要参会
-(void) bookinginterview:(UIButton *)sender{
    NSLog(@"%d",sender.tag);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [recruitmentCpData count];
}

//每一行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}



- (void)dealloc {
    [_tvRecruitmentCpList release];
    [super dealloc];
}
@end
