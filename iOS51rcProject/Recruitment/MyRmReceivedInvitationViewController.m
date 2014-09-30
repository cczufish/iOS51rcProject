#import "MyRmReceivedInvitationViewController.h"
#import "MyRecruitmentViewController.h"
#import "MJRefresh.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "MapViewController.h"

//收到的邀请
@interface MyRmReceivedInvitationViewController ()<NetWebServiceRequestDelegate>
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) IBOutlet UITableView *tvReceivedInvitationList;
@end

@implementation MyRmReceivedInvitationViewController
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
    //不显示列表分隔线
    self.tvReceivedInvitationList.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetMyReceivedInvitationList" Params:dicParam];
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
    if (requestData.count>0) {
        [recruitmentCpData removeAllObjects];
        recruitmentCpData = requestData;
        
        [recruitmentCpData retain];
        [self.tvReceivedInvitationList reloadData];
        [self.tvReceivedInvitationList footerEndRefreshing];
    }else{
        //记录
        UIView *viewHsaNoCv = [[[UIView alloc] initWithFrame:CGRectMake(20, 100, 240, 80)]autorelease];
        UIImageView *img = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 60)] autorelease];
        img.image = [UIImage imageNamed:@"pic_noinfo.png"];
        [viewHsaNoCv addSubview:img];
        
        NSString *strMsg = @"亲，您没有收到邀请记录，建议您线报名参加招聘会，主动邀请企业参会.";
        CGSize labelSize = [CommonController CalculateFrame:strMsg fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(220, 500)];
        UILabel *lb1 = [[[UILabel alloc]initWithFrame:CGRectMake(50, 10, labelSize.width, labelSize.height)] autorelease];
        lb1.text = strMsg;
        lb1.numberOfLines = 0;
        lb1.font = [UIFont systemFontOfSize:14];
        lb1.textAlignment = NSTextAlignmentLeft;
        [viewHsaNoCv addSubview:lb1];       
        
        [self.view addSubview:viewHsaNoCv];
    }
    
    //结束等待动画
    [loadView stopAnimating];
}

//绑定数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"cpList"] autorelease];
    //主要信息
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
        lbLeft.layer.backgroundColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
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
    //右侧的参会不参会标记
    UILabel *lbStatus = [[UILabel alloc] initWithFrame:CGRectMake(260, 6, 50, 18)];
    lbStatus.layer.cornerRadius = 7;
    lbStatus.textColor = [UIColor whiteColor];
    lbStatus.font = [UIFont systemFontOfSize:14];
    lbStatus.textAlignment = NSTextAlignmentCenter;
    //if (!isPassed) {
        if ([strStatus isEqualToString:@"1"]) {//参会
            lbStatus.layer.backgroundColor = [UIColor colorWithRed:3/255.0 green:187/255.0 blue:34/255.0 alpha:1].CGColor;
            lbStatus.text = @"参会";
        }else{
            lbStatus.layer.backgroundColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
            lbStatus.text = @"不参会";
        }
    //}
    [cell.contentView addSubview:lbStatus];
    [lbStatus release];
    //公司名称
    NSString *strCpName = rowData[@"companyName"];
    labelSize = [CommonController CalculateFrame:strCpName fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(200, 15)];
    UILabel *lbCpName = [[UILabel alloc] initWithFrame:CGRectMake(20, lbTitle.frame.origin.y + lbTitle.frame.size.height + 5, labelSize.width, 15)];
    lbCpName.text = strCpName;
    lbCpName.font = [UIFont systemFontOfSize:14];
    lbCpName.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbCpName)];
    [lbCpName release];
    //邀请时间
    UILabel *lbInviteTime = [[UILabel alloc] initWithFrame:CGRectMake(20, lbCpName.frame.origin.y + lbCpName.frame.size.height + 5, titleWidth, 15)];
    NSString *strBeginDate = rowData[@"AddDate"];
    NSDate *dtBeginDate = [CommonController dateFromString:strBeginDate];
    strBeginDate = [CommonController stringFromDate:dtBeginDate formatType:@"yyyy-MM-dd HH:mm"];
    NSString *strWeek = [CommonController getWeek:dtBeginDate];
    lbInviteTime.text = [NSString stringWithFormat:@"邀请时间：%@ %@",strBeginDate,strWeek];
    lbInviteTime.font = [UIFont systemFontOfSize:14];
    lbInviteTime.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbInviteTime)];
    [lbInviteTime release];
    //分隔线
    UILabel *lbLine1 = [[UILabel alloc] initWithFrame:CGRectMake(20, lbInviteTime.frame.origin.y+lbInviteTime.frame.size.height + 5, 300, 1)];
    lbLine1.text = @"--------------------------------------------------------------------------";
    lbLine1.textColor = [UIColor grayColor];
    [cell.contentView addSubview:lbLine1];
    [lbLine1 release];
    //招聘会名称
    NSString *strRmName = rowData[@"RecruitmentName"];
    labelSize = [CommonController CalculateFrame:strRmName fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(200, 15)];
    UILabel *lbRmName = [[UILabel alloc] initWithFrame:CGRectMake(20, lbInviteTime.frame.origin.y + 23, labelSize.width, 15)];
    lbRmName.text = strRmName;
    lbRmName.font = [UIFont systemFontOfSize:14];
    lbRmName.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbRmName)];
    [lbRmName release];

    //当前选择行，显示详细信息
    if (selectRowIndex == indexPath.row) {
        //举办时间
        UILabel *lbBeginTime = [[UILabel alloc] initWithFrame:CGRectMake(20, lbRmName.frame.origin.y + lbRmName.frame.size.height + 5, titleWidth, 15)];
        NSString *strBeginDate = rowData[@"BeginDate"];
        dtBeginDate = [CommonController dateFromString:strBeginDate];
        strBeginDate = [CommonController stringFromDate:dtBeginDate formatType:@"yyyy-MM-dd HH:mm"];
        NSString *strWeek = [CommonController getWeek:dtBeginDate];
        lbBeginTime.text = [NSString stringWithFormat:@"举办时间：%@ %@",strBeginDate,strWeek];
        lbBeginTime.font = [UIFont systemFontOfSize:14];
        lbBeginTime.textColor = [UIColor grayColor];
        [cell.contentView addSubview:(lbBeginTime)];
        [lbBeginTime release];
        //举办场馆
        NSString *strPlace = [NSString stringWithFormat:@"举办场馆：%@",rowData[@"PlaceName"]];
        labelSize = [CommonController CalculateFrame:strPlace fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(200, 15)];
        UILabel *lbPlace = [[UILabel alloc] initWithFrame:CGRectMake(20, lbBeginTime.frame.origin.y + lbBeginTime.frame.size.height + 5, labelSize.width, 15)];
        lbPlace.text = strPlace;
        lbPlace.font = [UIFont systemFontOfSize:14];
        lbPlace.textColor = [UIColor grayColor];
        [cell.contentView addSubview:(lbPlace)];
        [lbPlace release];
        //坐标
        UIButton *btnLngLat = [[UIButton alloc] initWithFrame:CGRectMake(20 + lbPlace.frame.size.width, lbPlace.frame.origin.y, 15, 15)];
        self.lng = rowData[@"lng"];
        self.lat = rowData[@"lat"];
        UIImageView *imgLngLat = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        imgLngLat.image = [UIImage imageNamed:@"ico_coordinate_red.png"];
        [btnLngLat addSubview:imgLngLat];
        btnLngLat.tag = (NSInteger)rowData[@"ID"];
        [btnLngLat addTarget:self action:@selector(btnLngLatClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnLngLat];
        [btnLngLat release];
        [imgLngLat release];
        //展位号
        UILabel *lbDeskNo = [[UILabel alloc] initWithFrame:CGRectMake(20, lbPlace.frame.origin.y + lbPlace.frame.size.height + 5, titleWidth, 15)];
        NSString *strDeskNo = rowData[@"DeskNo"];
        if (strDeskNo == nil) {
            strDeskNo = @"";
        }
        lbDeskNo.text = [NSString stringWithFormat:@"展 位号：%@",strDeskNo];
        lbDeskNo.font = [UIFont systemFontOfSize:14];
        lbDeskNo.textColor = [UIColor grayColor];
        [cell.contentView addSubview:(lbDeskNo)];
        [lbDeskNo release];
        //具体地址
        NSString *strAddress = [NSString stringWithFormat:@"具体地址：%@",rowData[@"Address"]];
        labelSize = [CommonController CalculateFrame:strAddress fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(200, 15)];
        UILabel *lbAddress = [[UILabel alloc] initWithFrame:CGRectMake(20, lbDeskNo.frame.origin.y + lbDeskNo.frame.size.height + 5, labelSize.width, 15)];
        lbAddress.text = strPlace;
        lbAddress.font = [UIFont systemFontOfSize:14];
        lbAddress.textColor = [UIColor grayColor];
        [cell.contentView addSubview:(lbAddress)];
        [lbAddress release];
        //携带材料
        NSString *strXdcl = [NSString stringWithFormat:@"携带材料：%@",rowData[@"Address"]];
        labelSize = [CommonController CalculateFrame:strAddress fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(200, 15)];
        UILabel *lbXdcl = [[UILabel alloc] initWithFrame:CGRectMake(20, lbAddress.frame.origin.y + lbAddress.frame.size.height + 5, labelSize.width, 15)];
        lbXdcl.text = strXdcl;
        lbXdcl.font = [UIFont systemFontOfSize:14];
        lbXdcl.textColor = [UIColor grayColor];
        [cell.contentView addSubview:(lbXdcl)];
        [lbXdcl release];
        //分隔线2
        UILabel *lbLine2 = [[UILabel alloc] initWithFrame:CGRectMake(20, lbXdcl.frame.origin.y+lbXdcl.frame.size.height + 5, 300, 1)];
        lbLine2.text = @"--------------------------------------------------------------------------";
        lbLine2.textColor = [UIColor grayColor];
        [cell.contentView addSubview:lbLine2];
        [lbLine2 release];
        //参会人
        NSString *strLinkman = [NSString stringWithFormat:@"参会人：%@",rowData[@"linkman"]];
        labelSize = [CommonController CalculateFrame:strAddress fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(200, 15)];
        UILabel *lbLinkman = [[UILabel alloc] initWithFrame:CGRectMake(20, lbLine2.frame.origin.y + lbLine2.frame.size.height + 5, labelSize.width, 15)];
        lbLinkman.text = strLinkman;
        lbLinkman.font = [UIFont systemFontOfSize:14];
        lbLinkman.textColor = [UIColor grayColor];
        [cell.contentView addSubview:(lbLinkman)];
        [lbLinkman release];
        //手机号
        self.strMobile = rowData[@"Mobile"];
        labelSize = [CommonController CalculateFrame:[NSString stringWithFormat:@"手机号：%@",self.strMobile] fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(200, 15)];
        UILabel *lbMobile = [[UILabel alloc] initWithFrame:CGRectMake(20, lbLinkman.frame.origin.y + lbLinkman.frame.size.height + 5, labelSize.width, 15)];
        lbMobile.text = [NSString stringWithFormat:@"手机号：%@",self.strMobile];
        lbMobile.font = [UIFont systemFontOfSize:14];
        lbMobile.textColor = [UIColor grayColor];
        [cell.contentView addSubview:(lbMobile)];
        [lbMobile release];
        //手机号后面的图标
        UIButton *btnCallMobile = [[[UIButton alloc] initWithFrame:CGRectMake(lbMobile.frame.origin.x+lbMobile.frame.size.width+5, lbMobile.frame.origin.y+2, 15, 15)] autorelease];
        [btnCallMobile setImage:[UIImage imageNamed:@"ico_calltelphone.png"] forState:UIControlStateNormal];
        btnCallMobile.tag = (NSInteger)rowData[@"ID"];
        [cell.contentView addSubview:btnCallMobile];
        [btnCallMobile addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];
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
            lbAccept.font = [UIFont systemFontOfSize:14];
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
            lbReject.font = [UIFont systemFontOfSize:14];
            [btnReject addSubview:lbReject];
            [cell.contentView addSubview:btnReject];
            [btnReject release];
            selectRowHeight = btnReject.frame.origin.y + btnReject.frame.size.height + 10;
        }
        else{
            selectRowHeight = lbMobile.frame.origin.y + lbMobile.frame.size.height + 10;
        }
    }else{
        selectRowHeight = 100;
    }
    //分割线
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, selectRowHeight - 5, 320, 0.5)];
    [viewSeparate setBackgroundColor:[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1]];
    [cell.contentView addSubview:viewSeparate];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [recruitmentCpData count];
}

//点击招聘会
- (IBAction)btnInviteCp:(id)sender {
    NSLog(@"");
}

//打电话
- (void)call:(UIButton *)sender {
    NSString *strCallNumber = self.strMobile;
    NSLog(@"%@", strCallNumber);
    UIWebView*callWebview =[[[UIWebView alloc] init] autorelease];
    NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",strCallNumber]];
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    //记得添加到view上
    [self.view addSubview:callWebview];
}

//点击坐标
-(void)btnLngLatClick:(UIButton *) sender{
    NSLog(@"%d", sender.tag);
    MapViewController *mapC = [[UIStoryboard storyboardWithName:@"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"MapView"];
    mapC.lat = [self.lat floatValue];
    mapC.lng = [self.lng floatValue];
    UIViewController *superJobC = [CommonController getFatherController:self.view];
    [mapC.navigationItem setTitle:superJobC.navigationItem.title];
    [superJobC.navigationController pushViewController:mapC animated:true];
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


- (void)dealloc {
    [_tvReceivedInvitationList release];
    [recruitmentCpData release];
    [super dealloc];
}
@end
