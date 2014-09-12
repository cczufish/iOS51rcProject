#import "InterviewNoticeViewController.h"
#import "MyRecruitmentViewController.h"
#import "MJRefresh.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"

@interface InterviewNoticeViewController ()<NetWebServiceRequestDelegate>
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) IBOutlet UITableView *tvReceivedInvitationList;
@end

@implementation InterviewNoticeViewController
@synthesize gotoMyInvitedCpViewDelegate;
@synthesize gotoRmViewDelegate;

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
    selectRowIndex = 0;
    selectRowHeight = 110;//选择行的高度
    //数据加载等待控件初始化
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //[self onSearch];
}

- (void)onSearch
{
    [recruitmentCpData removeAllObjects];
    [self.tvReceivedInvitationList reloadData];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *code = [userDefaults objectForKey:@"code"];
    NSString *userID = [userDefaults objectForKey:@"UserID"];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:userID forKey:@"paMainID"];//21142013
    [dicParam setObject:code forKey:@"code"];//152014391908
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetPaInterviewListByID" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 1;
    self.runningRequest = request;
    [dicParam release];
}

//成功
- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSMutableArray *)requestData
{
    [recruitmentCpData removeAllObjects];
    recruitmentCpData = requestData;
    
    [self.tvReceivedInvitationList reloadData];
    [self.tvReceivedInvitationList footerEndRefreshing];
    
    //结束等待动画
    [loadView stopAnimating];
}

//绑定数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"cpList"] autorelease];
    //主要信息
    //UIView *viewJobMain;
    NSDictionary *rowData = recruitmentCpData[indexPath.row];
    
    //是否已经结束
    BOOL isPassed = false;
    NSString *strEndDate = rowData[@"EndDate"];
    NSDate *dtEndDate = [CommonController dateFromString:strEndDate];
    NSDate *earlierDate =  [dtEndDate earlierDate:[NSDate date]];//与当前时间比较
    if (earlierDate != dtEndDate) {
        isPassed = false;
    }else{
        isPassed = true;
    }
    //操作状态
    NSString *strStatus = rowData[@"Status"];
    
    //标题左侧的红线(已经处理则显示灰色)
    UILabel *lbLeft = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, 5, 20)];
    if (![strStatus isEqualToString:@"0"]) {
        lbLeft.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:90/255.0 blue:49/255.0 alpha:1].CGColor;
    }else{
        lbLeft.layer.backgroundColor = [UIColor grayColor].CGColor;
    }
    
    [cell.contentView addSubview:lbLeft];
    [lbLeft release];
    //职位标题
    NSString *strJobName = rowData[@"JobName"];
    UIFont *titleFont = [UIFont systemFontOfSize:15];
    CGFloat titleWidth = 235;
    CGSize titleSize = CGSizeMake(titleWidth, 5000.0f);
    CGSize labelSize = [CommonController CalculateFrame:strJobName fontDemond:titleFont sizeDemand:titleSize];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, labelSize.width, labelSize.height)];
    lbTitle.text = strJobName;
    lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
    lbTitle.numberOfLines = 0;
    lbTitle.font = titleFont;
    [cell.contentView addSubview:(lbTitle)];
    [lbTitle release];
    //在线离线图标
    UIButton *btnChat = [[UIButton alloc] initWithFrame:CGRectMake(labelSize.width + 20, 6, 28, 15)];
    UIImageView *imgOnline = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 15)];
    imgOnline.image = [UIImage imageNamed:@"ico_joblist_online.png"];
    [btnChat addSubview:imgOnline];
    [cell.contentView addSubview:btnChat];
    [btnChat release];
    [imgOnline release];
    //公司名称
    NSString *strCpName = rowData[@"cpName"];
    labelSize = [CommonController CalculateFrame:strCpName fontDemond:[UIFont systemFontOfSize:11] sizeDemand:CGSizeMake(200, 15)];
    UILabel *lbCpName = [[UILabel alloc] initWithFrame:CGRectMake(20, lbTitle.frame.origin.y + lbTitle.frame.size.height + 5, labelSize.width, 15)];
    lbCpName.text = strCpName;
    lbCpName.font = [UIFont systemFontOfSize:11];
    lbCpName.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbCpName)];
    [lbCpName release];
    //通知时间
    UILabel *lbInviteTime = [[UILabel alloc] initWithFrame:CGRectMake(20, lbCpName.frame.origin.y + lbCpName.frame.size.height + 5, titleWidth, 15)];
    NSString *strBeginDate = rowData[@"AddDate"];
    NSDate *dtBeginDate = [CommonController dateFromString:strBeginDate];
    strBeginDate = [CommonController stringFromDate:dtBeginDate formatType:@"yyyy-MM-dd HH:mm"];
    NSString *strWeek = [CommonController getWeek:dtBeginDate];
    lbInviteTime.text = [NSString stringWithFormat:@"通知时间：%@ %@",strBeginDate,strWeek];
    lbInviteTime.font = [UIFont systemFontOfSize:11];
    lbInviteTime.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbInviteTime)];
    [lbInviteTime release];
    
    //当前选择行，显示详细信息
    if (selectRowIndex == indexPath.row) {
        //面试时间
        UILabel *lbPreViewTime = [[[UILabel alloc] initWithFrame:CGRectMake(20, lbInviteTime.frame.origin.y + lbInviteTime.frame.size.height + 5, 40, 15)] autorelease];
        lbPreViewTime.text = @"面试时间：";
        lbPreViewTime.font  = [UIFont systemFontOfSize:11];
        lbPreViewTime.textColor = [UIColor lightGrayColor];
        
        UILabel *lbInterviewTime = [[[UILabel alloc] initWithFrame:CGRectMake(60, lbInviteTime.frame.origin.y + lbInviteTime.frame.size.height + 5, titleWidth, 15)] autorelease];
        NSString *strInterviewTime = rowData[@"InterviewDate"];
        NSDate *dtViewDate = [CommonController dateFromString:strInterviewTime];
        strBeginDate = [CommonController stringFromDate:dtViewDate formatType:@"yyyy-MM-dd HH:mm"];
        lbInterviewTime.text = [NSString stringWithFormat:@"%@",strBeginDate];
        lbInterviewTime.font = [UIFont systemFontOfSize:11];
        lbInterviewTime.textColor =  [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
        
        [cell.contentView addSubview:(lbInterviewTime)];

        //面试地点
        UILabel *lbPrePlace = [[[UILabel alloc] initWithFrame:CGRectMake(20, lbInterviewTime.frame.origin.y + lbInterviewTime.frame.size.height + 5, 40, 15)] autorelease];
        lbPrePlace.text = @"面试地点";
        lbPrePlace.font  = [UIFont systemFontOfSize:11];
        lbPrePlace.textColor = [UIColor lightGrayColor];
        
        NSString *strPlace = rowData[@"InterViewPlace"];
        labelSize = [CommonController CalculateFrame:strPlace fontDemond:[UIFont systemFontOfSize:11] sizeDemand:CGSizeMake(200, 15)];
        UILabel *lbPlace = [[UILabel alloc] initWithFrame:CGRectMake(20, lbInterviewTime.frame.origin.y + lbInterviewTime.frame.size.height + 5, labelSize.width, 15)];
        lbPlace.text = strPlace;
        lbPlace.font = [UIFont systemFontOfSize:11];
        lbPlace.textColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
        [cell.contentView addSubview:(lbPlace)];
        [lbPlace release];

        //联系人
        NSString *strLinkman = [NSString stringWithFormat:@"联 系 人：%@",rowData[@"LinkMan"]];
        labelSize = [CommonController CalculateFrame:strLinkman fontDemond:[UIFont systemFontOfSize:11] sizeDemand:CGSizeMake(200, 15)];
        UILabel *lbLinkman = [[UILabel alloc] initWithFrame:CGRectMake(20, lbPlace.frame.origin.y + lbPlace.frame.size.height + 5, labelSize.width, 15)];
        lbLinkman.text = strLinkman;
        lbLinkman.font = [UIFont systemFontOfSize:11];
        lbLinkman.textColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
        [cell.contentView addSubview:(lbLinkman)];
        [lbLinkman release];
        //手机号
        NSString *strMobile = [NSString stringWithFormat:@"联系电话：%@",rowData[@"Telephone"]];
        labelSize = [CommonController CalculateFrame:strMobile fontDemond:[UIFont systemFontOfSize:11] sizeDemand:CGSizeMake(200, 15)];
        UILabel *lbMobile = [[UILabel alloc] initWithFrame:CGRectMake(20, lbLinkman.frame.origin.y + lbLinkman.frame.size.height + 5, labelSize.width, 15)];
        lbMobile.text = strMobile;
        lbMobile.font = [UIFont systemFontOfSize:11];
        lbMobile.textColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
        [cell.contentView addSubview:(lbMobile)];
        [lbMobile release];
        //手机号后面的图标
        UIImageView *imgMobile = [[UIImageView alloc] initWithFrame:CGRectMake(lbMobile.frame.origin.x + lbMobile.frame.size.width, lbMobile.frame.origin.y, 15, 15)];
        imgMobile.image = [UIImage imageNamed:@"ico_calltelphone.png"];
        imgMobile.tag = (NSInteger)rowData[@"ID"];
        [cell.contentView addSubview:imgMobile];
        [imgMobile release];
        //备注
        NSString *strRemark = [NSString stringWithFormat:@"备   注：%@",rowData[@"Remark"]];
        labelSize = [CommonController CalculateFrame:strRemark fontDemond:[UIFont systemFontOfSize:11] sizeDemand:CGSizeMake(200, 15)];
        UILabel *lbRemark = [[[UILabel alloc] initWithFrame:CGRectMake(20, lbMobile.frame.origin.y + lbMobile.frame.size.height + 5, labelSize.width, 15)] autorelease];
        lbRemark.text = strRemark;
        lbRemark.font = [UIFont systemFontOfSize:11];
        lbRemark.textColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
        [cell.contentView addSubview:(lbRemark)];
        
        //不赴约的原因
        UITextView *txtViewReason = [[[UITextView alloc] initWithFrame:CGRectMake(20, lbRemark.frame.origin.y + lbRemark.frame.size.height + 5, 280, 30)] autorelease];
        [cell.contentView addSubview:txtViewReason];
        
        //赴约、不赴约
        UIButton *btnAccept = [[[UIButton alloc] initWithFrame:CGRectMake(60, lbRemark.frame.origin.y+lbRemark.frame.size.height, 60, 40 )] autorelease];
        btnAccept.layer.backgroundColor = [UIColor greenColor].CGColor;
        [btnAccept setTitle:@"赴约" forState:UIControlStateNormal];
        
        UIButton *btnReject = [[[UIButton alloc] initWithFrame:CGRectMake(180, lbRemark.frame.origin.y+lbRemark.frame.size.height, 60, 40 )] autorelease];
        btnReject.layer.backgroundColor = [UIColor greenColor].CGColor;
        [btnReject setTitle:@"赴约" forState:UIControlStateNormal];
        
        //判断是否已经结束，如果没有结束，则可以赴约参会
        if (!isPassed && [strStatus isEqualToString:@"0"]) {
            //赴约参会
            UIButton *btnAccept = [[UIButton alloc] initWithFrame:CGRectMake(50, lbMobile.frame.origin.y + 30, 90, 30)];
            btnAccept.tag = (NSInteger)rowData[@"ID"];
            [btnAccept addTarget:self action:@selector(btnLngLatClick:) forControlEvents:UIControlEventTouchUpInside];
            btnAccept.layer.backgroundColor = [UIColor colorWithRed:3/255.0 green:187/255.0 blue:34/255.0 alpha:1].CGColor;
            btnAccept.layer.cornerRadius = 5;
            UILabel *lbAccept = [[[UILabel alloc] initWithFrame:CGRectMake(33, 0, 99, 30)] autorelease];
            lbAccept.text = @"赴约";
            lbAccept.textColor = [UIColor whiteColor];
            lbAccept.font = [UIFont systemFontOfSize:12];
            [btnAccept addSubview:lbAccept];
            [cell.contentView addSubview:btnAccept];
            [btnAccept release];
            //不赴约
            UIButton *btnReject = [[UIButton alloc] initWithFrame:CGRectMake(170, lbMobile.frame.origin.y + 30, 99, 30)];
            btnReject.tag = (NSInteger)rowData[@"ID"];
            [btnReject addTarget:self action:@selector(btnLngLatClick:) forControlEvents:UIControlEventTouchUpInside];
            btnReject.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:90/255.0 blue:49/255.0 alpha:1].CGColor;
            btnReject.layer.cornerRadius = 5;
            UILabel *lbReject = [[[UILabel alloc] initWithFrame:CGRectMake(30, 0, 99, 30)] autorelease];
            lbReject.text = @"不赴约";
            lbReject.textColor = [UIColor whiteColor];
            lbReject.font = [UIFont systemFontOfSize:12];
            [btnReject addSubview:lbReject];
            [cell.contentView addSubview:btnReject];
            [btnReject release];
            selectRowHeight = btnReject.frame.origin.y + btnReject.frame.size.height + 5;
        }
        else{
            selectRowHeight = lbMobile.frame.origin.y + lbMobile.frame.size.height + 5;
        }
    }else{
        selectRowHeight = 100;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [recruitmentCpData count];
}

//点击招聘会
- (IBAction)btnInviteCp:(id)sender {
    NSLog(@"");
}

//点击坐标
-(void)btnLngLatClick:(UIButton *) sender{
    NSLog(@"%d", sender.tag);
}

//点击参会
-(void)btnAcceptClick:(UIButton *) sender{
    NSLog(@"%d", sender.tag);
}

//点击不参会
-(void)btnRejectClick:(UIButton *) sender{
    NSLog(@"%d", sender.tag);
}

//点击我参会的企业
-(void)joinRecruitment:(UIButton *) sender{
    NSLog(@"%d", sender.tag);
    [gotoMyInvitedCpViewDelegate GoToMyInvitedCpView:[@(sender.tag) stringValue]];
}

//点击某一行,到达企业页面--调用代理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [gotoRmViewDelegate gotoRmView:recruitmentCpData[indexPath.row][@"id"]];
    selectRowIndex = indexPath.row;
    //重新加载
    [self.tvReceivedInvitationList reloadData];
    [self.tvReceivedInvitationList footerEndRefreshing];
}

//每一行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *strStatus = recruitmentCpData[indexPath.row][@"Status"];
    BOOL isPassed = false;
    NSString *strEndDate = recruitmentCpData[indexPath.row][@"EndDate"];
    NSDate *dtEndDate = [CommonController dateFromString:strEndDate];
    NSDate *earlierDate =  [dtEndDate earlierDate:[NSDate date]];//与当前时间比较
    if (earlierDate != dtEndDate) {
        isPassed = false;
    }else{
        isPassed = true;
    }
    
    if (selectRowIndex == indexPath.row) {
        //如果未结束，并且没操作
        if (!isPassed&&[strStatus isEqualToString:@"0"]) {
            return 280;
        }
        else {
            return 245;
        }
        
    }else {
        return 95;
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
    [_tvReceivedInvitationList release];
    [super dealloc];
}
@end
