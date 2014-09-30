#import "InterviewNoticeViewController.h"
#import "MyRecruitmentViewController.h"
#import "MJRefresh.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import <objc/runtime.h>
#import "RmCpMain.h"
#import "MapViewController.h"
#import "Toast+UIView.h"

@interface InterviewNoticeViewController ()<NetWebServiceRequestDelegate, UITextViewDelegate>
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NetWebServiceRequest *runningRequestGetCvList;
@property (retain, nonatomic) IBOutlet UITableView *tvReceivedInvitationList;
@property (retain, nonatomic) IBOutlet UILabel *lbMessage;
@property (retain, nonatomic) NSMutableArray *arrayHeight;
@property (retain, nonatomic) NSMutableArray *arrayTxtView;
@end

@implementation InterviewNoticeViewController
#define HEIGHT [[UIScreen mainScreen] bounds].size.height
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
    self.arrayTxtView = [[NSMutableArray alloc] init];//临时存放
    self.lbMessage.layer.borderColor=[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
    self.lbMessage.layer.borderWidth = 0.5;
    selectRowIndex = 0;
    selectRowHeight = 110;//选择行的高度
    self.tvReceivedInvitationList.frame = CGRectMake(0, self.tvReceivedInvitationList.frame.origin.y, 320, HEIGHT-160);
    //数据加载等待控件初始化
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //[self onSearch];
    //不显示列表分隔线
    self.tvReceivedInvitationList.separatorStyle = UITableViewCellSeparatorStyleNone;
   
}

- (void)onSearch
{
    [loadView startAnimating];
    //首先获得简历
    [self GetBasicCvList];
}

//成功
- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSMutableArray *)requestData
{
    UIViewController *pCtrl = [CommonController getFatherController:self.view];
    if (request.tag == 1) {
        if (requestData.count>0) {
            [self.recruitmentCpData removeAllObjects];
            self.recruitmentCpData = requestData;
            
            [self.tvReceivedInvitationList reloadData];
            [self.tvReceivedInvitationList footerEndRefreshing];
        }else{
            //没有面试通知记录
            self.lbMessage.text = @" ";
            self.lbMessage.layer.borderColor = [UIColor whiteColor].CGColor;
            
            UIView *viewHsaNoCv = [[[UIView alloc] initWithFrame:CGRectMake(20, 100, 240, 80)]autorelease];
            UIImageView *img = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 60)] autorelease];
            img.image = [UIImage imageNamed:@"pic_noinfo.png"];
            [viewHsaNoCv addSubview:img];
            
            UILabel *lb1 = [[[UILabel alloc]initWithFrame:CGRectMake(50, 10, 220, 20)] autorelease];
            lb1.text = @"亲，您没有面试通知记录,申请的";
            lb1.font = [UIFont systemFontOfSize:13];
            lb1.textAlignment = NSTextAlignmentCenter;
            [viewHsaNoCv addSubview:lb1];
            
            UILabel *lb2 = [[[UILabel alloc] initWithFrame:CGRectMake(50, 30, 300, 20)] autorelease];
            lb2.text = @"职位越多，收到的面试通知就会越多。";
            lb2.font = [UIFont systemFontOfSize:13];
            lb2.textAlignment = NSTextAlignmentLeft;
            [viewHsaNoCv addSubview:lb2];
            
            UILabel *lb3 = [[[UILabel alloc] initWithFrame:CGRectMake(50, 50, 200, 20)] autorelease];
            lb3.text = @"现在就去申请职位吧。";
            lb3.font = [UIFont systemFontOfSize:13];
            lb3.textColor =  [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
            lb3.textAlignment = NSTextAlignmentCenter;
            [viewHsaNoCv addSubview:lb3];
            
            [self.view addSubview:viewHsaNoCv];
        }
        
        //结束等待动画
        [loadView stopAnimating];
    }
    else if(request.tag == 2)
    {
        if ([result isEqualToString:@"1"]) {
            //[self onSearch];//加载完后重新刷新
            [self.recruitmentCpData removeAllObjects];
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
            [pCtrl.view makeToast:@"回复成功"];
        }
        else{
            [pCtrl.view makeToast:@"回复失败"];
        }
    }
    else if(request.tag == 3)
    {
        if (requestData.count > 0) {
            //如果有简历，才查询数据
            [self.recruitmentCpData removeAllObjects];
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
        else{
            //没有简历的提醒
            self.lbMessage.text = @" ";
            self.lbMessage.layer.borderColor = [UIColor whiteColor].CGColor;
            
            UIView *viewHsaNoCv = [[[UIView alloc] initWithFrame:CGRectMake(30, 100, 240, 80)]autorelease];
            UIImageView *img = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 60)] autorelease];
            img.image = [UIImage imageNamed:@"pic_noinfo.png"];
            [viewHsaNoCv addSubview:img];
            
            UILabel *lb1 = [[[UILabel alloc]initWithFrame:CGRectMake(50, 10, 220, 20)] autorelease];
            lb1.text = @"亲，您没有完整的简历";
            lb1.font = [UIFont systemFontOfSize:13];
            lb1.textAlignment = NSTextAlignmentCenter;
            [viewHsaNoCv addSubview:lb1];
            
            UILabel *lb2 = [[[UILabel alloc] initWithFrame:CGRectMake(50, 30, 150, 20)] autorelease];
            lb2.text = @"HR关注不到您，建议您";
            lb2.font = [UIFont systemFontOfSize:13];
            lb2.textAlignment = NSTextAlignmentLeft;
            [viewHsaNoCv addSubview:lb2];
            
            UILabel *lb3 = [[[UILabel alloc] initWithFrame:CGRectMake(lb2.frame.origin.x + lb2.frame.size.width - 5, 30, 140, 20)] autorelease];
            lb3.text = @"立即完善简历";
            lb3.font = [UIFont systemFontOfSize:13];
            lb3.textColor =  [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
            lb3.textAlignment = NSTextAlignmentLeft;
            [viewHsaNoCv addSubview:lb3];
            
            [self.view addSubview:viewHsaNoCv];
            //结束等待动画
            [loadView stopAnimating];
        }
    }
}

//获得简历列表
-(void) GetBasicCvList{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *code = [userDefaults objectForKey:@"code"];
    NSString *userID = [userDefaults objectForKey:@"UserID"];
    
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:userID forKey:@"paMainID"];
    [dicParam setObject:code forKey:@"code"];
    
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetBasicCvListByPaMainID" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 3;
    self.runningRequestGetCvList = request;
    [dicParam release];
}

//绑定数据
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"cpList"] autorelease];
    
    NSDictionary *rowData = self.recruitmentCpData[indexPath.row];
    NSString *strReply = rowData[@"Reply"];
    //标题左侧的红线(已经处理则显示灰色)
    UILabel *lbLeft = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, 5, 20)];
    if ([strReply isEqualToString:@"0"]) {
        lbLeft.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:90/255.0 blue:49/255.0 alpha:1].CGColor;
    }else{
        lbLeft.layer.backgroundColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
    }
    
    [cell.contentView addSubview:lbLeft];
    [lbLeft release];
    //职位标题
    BOOL isDelete = [rowData[@"IsDelete"] boolValue];
    NSString *strJobName = rowData[@"JobName"];
    if (isDelete) {
        strJobName = [NSString stringWithFormat:@"（已删除）%@", strJobName];
    }
    NSString *issueEnd = rowData[@"IssueEND"];
    NSDate *dtIssueEnd = [CommonController dateFromString:issueEnd];
    NSDate * now = [NSDate date];
    if ([now laterDate:dtIssueEnd] == now  && !isDelete) {//过期，并且为删除
        strJobName = [NSString stringWithFormat:@"（已过期）%@", strJobName];
    }
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
    BOOL isOnline = [rowData[@"IsOnline"] boolValue];
    if (isOnline) {
        UIButton *btnChat = [[UIButton alloc] initWithFrame:CGRectMake(labelSize.width + 20, 6, 28, 15)];
        UIImageView *imgOnline = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 15)];
        imgOnline.image = [UIImage imageNamed:@"ico_joblist_online.png"];
        [btnChat addSubview:imgOnline];
        [cell.contentView addSubview:btnChat];
        [btnChat release];
        [imgOnline release];
    }
    
    //公司名称
    NSString *strCpName = rowData[@"cpName"];
    labelSize = [CommonController CalculateFrame:strCpName fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(200, 15)];
    UILabel *lbCpName = [[UILabel alloc] initWithFrame:CGRectMake(20, lbTitle.frame.origin.y + lbTitle.frame.size.height + 5, labelSize.width, 15)];
    lbCpName.text = strCpName;
    lbCpName.font = [UIFont systemFontOfSize:12];
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
    lbInviteTime.font = [UIFont systemFontOfSize:12];
    lbInviteTime.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbInviteTime)];
    [lbInviteTime release];
    
    //当前选择行，显示详细信息
    if (selectRowIndex == indexPath.row) {
        //面试时间
        UILabel *lbPreViewTime = [[[UILabel alloc] initWithFrame:CGRectMake(20, lbInviteTime.frame.origin.y + lbInviteTime.frame.size.height + 5, 60, 15)] autorelease];
        lbPreViewTime.text = @"面试时间：";
        lbPreViewTime.font  = [UIFont systemFontOfSize:12];
        lbPreViewTime.textColor = [UIColor grayColor];
        [cell.contentView addSubview:(lbPreViewTime)];
        
        UILabel *lbInterviewTime = [[[UILabel alloc] initWithFrame:CGRectMake(80, lbInviteTime.frame.origin.y + lbInviteTime.frame.size.height + 5, titleWidth, 15)] autorelease];
        NSString *strInterviewTime = rowData[@"InterviewDate"];
        //NSDate *dtViewDate = [CommonController dateFromString:strInterviewTime];
        //strBeginDate = [CommonController stringFromDate:dtViewDate formatType:@"yyyy-MM-dd HH:mm"];
        lbInterviewTime.text = [NSString stringWithFormat:@"%@",strInterviewTime];
        lbInterviewTime.font = [UIFont systemFontOfSize:12];
        lbInterviewTime.textColor =  [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
        
        [cell.contentView addSubview:(lbInterviewTime)];

        //面试地点
        UILabel *lbPrePlace = [[[UILabel alloc] initWithFrame:CGRectMake(20, lbInterviewTime.frame.origin.y + lbInterviewTime.frame.size.height + 5, 60, 15)] autorelease];
        lbPrePlace.text = @"面试地点：";
        lbPrePlace.font  = [UIFont systemFontOfSize:12];
        lbPrePlace.textColor = [UIColor grayColor];
        [cell.contentView addSubview:(lbPrePlace)];
        
        NSString *strPlace = rowData[@"InterViewPlace"];
        labelSize = [CommonController CalculateFrame:strPlace fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(240, 15)];
        UILabel *lbPlace = [[UILabel alloc] initWithFrame:CGRectMake(80, lbInterviewTime.frame.origin.y + lbInterviewTime.frame.size.height + 5, labelSize.width, 15)];
        lbPlace.text = strPlace;
        lbPlace.font = [UIFont systemFontOfSize:12];
        lbPlace.textColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
        [cell.contentView addSubview:(lbPlace)];
        [lbPlace release];

        //联系人
        UILabel *lbPreLinkMan = [[[UILabel alloc]initWithFrame:CGRectMake(20, lbPlace.frame.origin.y + lbPlace.frame.size.height + 5, 60, 15)] autorelease];
        lbPreLinkMan.text = @"联 系 人：";
        lbPreLinkMan.font  = [UIFont systemFontOfSize:12];
        lbPreLinkMan.textColor = [UIColor grayColor];
        [cell.contentView addSubview:lbPreLinkMan];
        
        NSString *strLinkman = rowData[@"LinkMan"];
        labelSize = [CommonController CalculateFrame:strLinkman fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(200, 15)];
        UILabel *lbLinkman = [[UILabel alloc] initWithFrame:CGRectMake(80, lbPlace.frame.origin.y + lbPlace.frame.size.height + 5, labelSize.width, 15)];
        lbLinkman.text = strLinkman;
        lbLinkman.font = [UIFont systemFontOfSize:12];
        lbLinkman.textColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
        [cell.contentView addSubview:(lbLinkman)];
        [lbLinkman release];
        
        //手机号Button
        UIButton *btnCall = [[[UIButton alloc] initWithFrame:CGRectMake(80,  lbLinkman.frame.origin.y + lbLinkman.frame.size.height + 5, 260, 15)] autorelease ];
        [btnCall addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];
        //联系电话四个字
        UILabel *lbPreMobile = [[[UILabel alloc]initWithFrame:CGRectMake(20, lbLinkman.frame.origin.y + lbLinkman.frame.size.height + 5, 60, 15)] autorelease];
        lbPreMobile.text = @"联系电话：";
        lbPreMobile.font  = [UIFont systemFontOfSize:12];
        lbPreMobile.textColor = [UIColor grayColor];
        [cell.contentView addSubview:lbPreMobile];
        //联系电话具体值
        self.strPhone = rowData[@"Telephone"];
        labelSize = [CommonController CalculateFrame:self.strPhone fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(200, 15)];
        UILabel *lbMobile = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, 15)] autorelease];
        lbMobile.text = self.strPhone;
        lbMobile.font = [UIFont systemFontOfSize:12];
        lbMobile.textColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
        [btnCall addSubview:lbMobile];
        //手机号图片
        UIImageView *imagePhone = [[[UIImageView alloc] initWithFrame:CGRectMake(lbMobile.frame.size.width + 5, 0, 15, 15)]autorelease];
        imagePhone.image = [UIImage imageNamed:@"ico_calltelphone.png"];
        [btnCall addSubview:imagePhone];
        btnCall.tag = (NSInteger)rowData[@"ID"];
        [cell.contentView addSubview:btnCall];
      
        //备注
        UILabel *lbPreRemark = [[[UILabel alloc]initWithFrame:CGRectMake(20, btnCall.frame.origin.y + btnCall.frame.size.height + 5, 60, 15)] autorelease];
        lbPreRemark.text = @"备      注：";
        lbPreRemark.font  = [UIFont systemFontOfSize:12];
        lbPreRemark.textColor = [UIColor grayColor];
        lbPreRemark.lineBreakMode = NSLineBreakByCharWrapping;
        lbPreRemark.numberOfLines = 0;
        [cell.contentView addSubview:lbPreRemark];
        
        NSString *strRemark = rowData[@"Remark"];
        if (strRemark == nil) {
            strRemark = @"    ";
        }
        labelSize = [CommonController CalculateFrame:strRemark fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(200, 500)];
        UILabel *lbRemark = [[[UILabel alloc] initWithFrame:CGRectMake(80, btnCall.frame.origin.y + btnCall.frame.size.height + 5, labelSize.width, labelSize.height)] autorelease];
        lbRemark.text = strRemark;
        lbRemark.font = [UIFont systemFontOfSize:12];
        lbRemark.lineBreakMode = NSLineBreakByCharWrapping;
        lbRemark.numberOfLines = 0;
        lbRemark.textColor = [UIColor blackColor];
        [cell.contentView addSubview:(lbRemark)];
        
        //判断是否已经结束，如果没有结束，则可以赴约参会
        if ([strReply isEqualToString:@"0"]) {//未回复
            //不赴约的原因文本框
            UITextView *txtViewReason = [[[UITextView alloc] initWithFrame:CGRectMake(20, lbRemark.frame.origin.y + lbRemark.frame.size.height + 5, 280, 50)] autorelease];
            [cell.contentView addSubview:txtViewReason];
            txtViewReason.layer.borderColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
            txtViewReason.layer.borderWidth = 1;
            txtViewReason.font = [UIFont systemFontOfSize:12];
            txtViewReason.delegate = self;
            txtViewReason.text = @"如果不能赴约参加面试，请说明理由";
            //把文本框添加到临时的变量内，用于传参
            self.arrayTxtView = [[NSMutableArray alloc] init];//临时存放
            NSDictionary *dicTxtView = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%d",indexPath.row],@"id",
                                        txtViewReason,@"value"
                                        ,nil] autorelease];
            [self.arrayTxtView addObject:dicTxtView];
            
            //为TextView设置键盘隐藏
            UIToolbar * topView = [[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)] autorelease];
            [topView setBarStyle:UIBarStyleBlack];
            UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
            UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"输入完成" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard:)];
            objc_setAssociatedObject(doneButton, @"lbReason", txtViewReason, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            // objc_setAssociatedObject(btnInvite, "rmCpMain", cpMain, OBJC_ASSOCIATION_RETAIN_NONATOMIC);//传递对象
            NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];
            [doneButton release];
            [btnSpace release];
            [topView setItems:buttonsArray];
            [txtViewReason setInputAccessoryView:topView];
            
            //赴约参会
            UIButton *btnAccept = [[UIButton alloc] initWithFrame:CGRectMake(50, txtViewReason.frame.origin.y + txtViewReason.frame.size.height+ 5, 90, 30)];
            btnAccept.tag = (NSInteger)rowData[@"ID"];
            objc_setAssociatedObject(btnAccept, @"AcceptReason", [NSString stringWithFormat:@"%d", indexPath.row], OBJC_ASSOCIATION_COPY_NONATOMIC);
            [btnAccept addTarget:self action:@selector(btnAcceptClick:) forControlEvents:UIControlEventTouchUpInside];
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
            UIButton *btnReject = [[UIButton alloc] initWithFrame:CGRectMake(170, txtViewReason.frame.origin.y + txtViewReason.frame.size.height + 5, 99, 30)];
            btnReject.tag = (NSInteger)rowData[@"ID"];
            objc_setAssociatedObject(btnReject, @"RejectReason", [NSString stringWithFormat:@"%d", indexPath.row], OBJC_ASSOCIATION_COPY_NONATOMIC);
            [btnReject addTarget:self action:@selector(btnRejectClick:) forControlEvents:UIControlEventTouchUpInside];
            btnReject.layer.backgroundColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
            btnReject.layer.cornerRadius = 5;
            UILabel *lbReject = [[[UILabel alloc] initWithFrame:CGRectMake(30, 0, 99, 30)] autorelease];
            lbReject.text = @"不赴约";
            lbReject.textColor = [UIColor whiteColor];
            lbReject.font = [UIFont systemFontOfSize:12];
            [btnReject addSubview:lbReject];
            [cell.contentView addSubview:btnReject];
            [btnReject release];
            selectRowHeight = btnReject.frame.origin.y + btnReject.frame.size.height + 15;
        }
        else {
            //不赴约状态
            UILabel *lbPreRemark = [[[UILabel alloc]initWithFrame:CGRectMake(20, lbRemark.frame.origin.y + lbRemark.frame.size.height + 5, 60, 15)] autorelease];
            lbPreRemark.text = @"回复状态：";
            lbPreRemark.font  = [UIFont systemFontOfSize:12];
            lbPreRemark.textColor = [UIColor grayColor];
            [cell.contentView addSubview:lbPreRemark];
          
            UILabel *lbApply = [[[UILabel alloc] initWithFrame:CGRectMake(80, lbRemark.frame.origin.y + lbRemark.frame.size.height + 5, 40, 15)] autorelease];
            lbApply.text = strRemark;
            lbApply.layer.cornerRadius = 5;
            lbApply.layer.masksToBounds = YES;
            lbApply.font = [UIFont systemFontOfSize:12];
            lbApply.textColor = [UIColor whiteColor];
            lbApply.textAlignment = NSTextAlignmentCenter;
            if ([strReply isEqualToString:@"1"]) {
                lbApply.text = @"赴约";
                lbApply.backgroundColor = [UIColor colorWithRed:3/255.0 green:187/255.0 blue:34/255.0 alpha:1];
                selectRowHeight = lbApply.frame.origin.y + lbApply.frame.size.height + 15;
            }
            else{
                lbApply.text = @"不赴约";
                lbApply.backgroundColor = [UIColor colorWithRed:170.f/255.f green:170.f/255.f blue:170.f/255.f alpha:1];
                //不赴约原因
                UILabel *lbReason = [[[UILabel alloc] initWithFrame:CGRectMake(20, lbApply.frame.origin.y+lbApply.frame.size.height + 5, 280, 15)] autorelease];
                lbReason.text = [NSString stringWithFormat:@"原      因：%@", rowData[@"ReplyMessage"]];
                lbReason.textColor = [UIColor grayColor];
                lbReason.layer.cornerRadius = 5;
                lbReason.font = [UIFont systemFontOfSize:12];
                [cell.contentView addSubview:(lbReason)];
                selectRowHeight = lbReason.frame.origin.y + lbReason.frame.size.height + 5;
            }
            [cell.contentView addSubview:(lbApply)];

            
        }
    }else{
        selectRowHeight = 70;
    }
    
    if (indexPath.row<self.recruitmentCpData.count-1) {
        //分割线
        UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, selectRowHeight - 2, 320, 0.5)];
        [viewSeparate setBackgroundColor:[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1]];
        [cell.contentView addSubview:viewSeparate];
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.recruitmentCpData count];
}

-(IBAction)dismissKeyBoard:(UIButton*)sender
{
    UITextView *txtView = objc_getAssociatedObject(sender, @"lbReason");
    [txtView resignFirstResponder];
}

//打电话
- (void)call:(UIButton *)sender {
    NSString *strCallNumber = self.strPhone;
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
    //mapC.lat = [self.lat floatValue];
    //mapC.lng = [self.lng floatValue];
    UIViewController *superJobC = [CommonController getFatherController:self.view];
    [mapC.navigationItem setTitle:superJobC.navigationItem.title];
    [superJobC.navigationController pushViewController:mapC animated:true];
}

//点击赴约
-(void)btnAcceptClick:(UIButton *) sender{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    NSInteger index = [objc_getAssociatedObject(sender, @"AcceptReason") integerValue];
    NSDictionary *dicTxtView = self.arrayTxtView[0];
    UITextView *tmpView = (UITextView *) dicTxtView[@"value"];
    [tmpView resignFirstResponder];//隐藏键盘
    NSString *msg = tmpView.text;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *code = [userDefaults objectForKey:@"code"];
    NSString *userID = [userDefaults objectForKey:@"UserID"];
    NSString *userName = [userDefaults objectForKey:@"UserName"];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    NSDictionary *tmpDic = self.recruitmentCpData[index];
     NSString *strCpID =tmpDic[@"cpID"];
    
    [dicParam setObject:userName forKey:@"paName"];
    [dicParam setObject:[userDefaults objectForKey:@"subSiteId"] forKey:@"dcRegionId"];
    [dicParam setObject: strCpID forKey:@"cpMainID"];
    [dicParam setObject:msg forKey:@"message"];
    [dicParam setObject:[NSString stringWithFormat:@"%d", sender.tag] forKey:@"id"];
    [dicParam setObject:@"1" forKey:@"reply"];
    [dicParam setObject:userID forKey:@"paMainID"];
    [dicParam setObject:code forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"ReplyInterview" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 2;
    self.runningRequest = request;
    [dicParam release];
}

//点击不赴约
-(void)btnRejectClick:(UIButton *) sender{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    NSInteger index = [objc_getAssociatedObject(sender, @"RejectReason") integerValue];
    NSDictionary *dicTxtView = self.arrayTxtView[0];
    UITextView *tmpView = (UITextView *) dicTxtView[@"value"];
    [tmpView resignFirstResponder];//隐藏键盘
    if ([tmpView.text isEqualToString:@""] || [tmpView.text isEqualToString:@"如果不能赴约参加面试，请说明理由"]) {
        tmpView.layer.borderColor =  [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1].CGColor;
        tmpView.layer.borderWidth = 1;
        return;
    }
    NSString *msg = tmpView.text;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *code = [userDefaults objectForKey:@"code"];
    NSString *userID = [userDefaults objectForKey:@"UserID"];
    NSString *userName = [userDefaults objectForKey:@"UserName"];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    
    NSDictionary *tmpDic = self.recruitmentCpData[index];
    NSString *strCpID =tmpDic[@"cpID"];
    [dicParam setObject:userName forKey:@"paName"];
    [dicParam setObject:[userDefaults objectForKey:@"subSiteId"] forKey:@"dcRegionId"];
    [dicParam setObject: strCpID forKey:@"cpMainID"];
    [dicParam setObject:msg forKey:@"message"];
    [dicParam setObject:[NSString stringWithFormat:@"%d", sender.tag] forKey:@"id"];
    [dicParam setObject:@"2" forKey:@"reply"];
    [dicParam setObject:userID forKey:@"paMainID"];
    [dicParam setObject:code forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"ReplyInterview" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 2;
    self.runningRequest = request;
    [dicParam release];
}


//点击某一行,到达企业页面--调用代理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [gotoRmViewDelegate gotoRmView:self.recruitmentCpData[indexPath.row][@"id"]];
    selectRowIndex = indexPath.row;
    //重新加载
    [self.tvReceivedInvitationList reloadData];
    [self.tvReceivedInvitationList footerEndRefreshing];
}

//每一行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger height = 70;
    NSString *strReply = self.recruitmentCpData[indexPath.row][@"Reply"];
    if (selectRowIndex == indexPath.row) {
        NSString *strRemark = self.recruitmentCpData[indexPath.row][@"Remark"];
        CGSize labelSize = [CommonController CalculateFrame:strRemark fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(200, 500)];
        height += labelSize.height - 15;
        //如果未结束，并且没操作
        if ([strReply isEqualToString:@"0"]) {
            height +=  210;
        }
        else {
            height +=  140;
        }
        //如果有未结束原因
        NSString *replyMessage = self.recruitmentCpData [indexPath.row][@"ReplyMessage"];
        labelSize = [CommonController CalculateFrame:replyMessage fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(200, 500)];
        height += labelSize.height - 15;
    }
    
    return height;
}

//开始编辑输入框的时候，软键盘出现，执行此事件
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"如果不能赴约参加面试，请说明理由"]) {
        textView.text = @"";
    }
    CGRect frame = textView.frame;
    int offset = frame.origin.y - (self.view.frame.size.height - 216.0);//键盘高度216
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    self.view.frame = CGRectMake(0.0f, offset, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}


//输入框编辑完成以后，将视图恢复到原始状态
-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"如果不能赴约参加面试，请说明理由";
    }
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_arrayHeight release];
    [_runningRequest release];
    [_runningRequestGetCvList release];
    [_strPhone release];
    [_recruitmentCpData release];
    [_tvReceivedInvitationList release];
    [_lbMessage release];
    [super dealloc];
}
@end
