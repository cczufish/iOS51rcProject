#import "ChatOnlineLogViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"

@interface ChatOnlineLogViewController ()<NetWebServiceRequestDelegate,UITableViewDataSource,UITableViewDelegate>
@property (retain, nonatomic) IBOutlet UIView *viewTop;
@property (retain, nonatomic) IBOutlet UIView *viewBottom;
@property (retain, nonatomic) IBOutlet UITextField *textSend;
@property (retain, nonatomic) IBOutlet UIButton *btnSend;
@property (retain, nonatomic) IBOutlet UITableView *tvChatOnlineLogList;

@property (retain, nonatomic) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NSMutableArray *chatOnlineLogData;
@end

@implementation ChatOnlineLogViewController
{
    LoadingAnimationView *loadView;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {}
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //顶部view边框
    self.viewTop.frame = CGRectMake(0, 40, 320, 40);
    self.viewTop.layer.backgroundColor = [UIColor colorWithRed:244.f/255.f green:244.f/255.f blue:244.f/255.f alpha:1].CGColor;
    self.viewTop.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.viewTop.layer.borderWidth = 0.5;
    
    //标题
    UIImageView *imgOnline = [[[UIImageView alloc] initWithFrame:CGRectMake(30, 7, 8, 12)] autorelease];
    if ([self.isOnline isEqualToString:@"1"]) {
        imgOnline.image = [UIImage imageNamed:@"ico_onlinechat_online.png"];
    }else{
        imgOnline.image = [UIImage imageNamed:@"ico_onlinechat_offline.png"];
    }
    [self.viewTop addSubview:imgOnline];
    
    //公司名称
    UILabel *lbCpName = [[[UILabel alloc]initWithFrame:CGRectMake(40, 7, 180, 15)] autorelease];
    lbCpName.font = [UIFont systemFontOfSize:12];
    lbCpName.text = self.cpName;
    [self.viewTop addSubview:lbCpName];
    
    //企业用户名称
    UILabel *lbCaName = [[[UILabel alloc] initWithFrame:CGRectMake(260, 7, 60, 15)]autorelease];
    lbCaName.font = [UIFont systemFontOfSize:12];
    lbCaName.text = self.caName;
    [self.viewTop addSubview:lbCaName];
    
    //底部背景色
    self.viewBottom.layer.backgroundColor = [UIColor colorWithRed:244.f/255.f green:244.f/255.f blue:244.f/255.f alpha:1].CGColor;
    self.textSend.layer.cornerRadius = 5;
    self.btnSend.layer.backgroundColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1].CGColor;
    
    //不显示列表分隔线
    self.tvChatOnlineLogList.separatorStyle = UITableViewCellSeparatorStyleNone;
    //获取数据
    [self getChatOnlineLog];
}

//获取聊天记录
-(void) getChatOnlineLog{
    //开始等待动画
    [loadView startAnimating];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *code = [userDefaults objectForKey:@"code"];
    NSString *userID = [userDefaults objectForKey:@"UserID"];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:userID forKey:@"paMainID"];//21142013
    [dicParam setObject:code forKey:@"code"];//152014391908
    [dicParam setObject:self.cvMainID forKey:@"cvMainID"];
    [dicParam setObject:self.caMainID forKey:@"caMainID"];
    [dicParam setObject:@"1" forKey:@"isRead"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetChatMainByCvCaID" Params:dicParam];
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
    if (request.tag == 1) {
        [self.chatOnlineLogData removeAllObjects];
        self.chatOnlineLogData = requestData;
        //重新加载列表
        [self.tvChatOnlineLogList reloadData];
    }
    //结束等待动画
    [loadView stopAnimating];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatOnlineLogData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"jobList"] autorelease];
    NSDictionary *rowData = self.chatOnlineLogData[indexPath.row];
    
    int tmpHeight = 40;
    int senderType = [rowData[@"SenderType"] integerValue];
    //企业发送
    if (senderType == 1) {
        //左侧图片
        UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(5, 8, 40, 40)]autorelease];
        imgView.image = [UIImage imageNamed:@"ico_onlinechat_cphead_online.png"];
        [cell.contentView addSubview:imgView];
        //消息内容View
        UIView *viewMsg = [[[UIView alloc] initWithFrame:CGRectMake(50, 8, 270, 60)] autorelease];
        viewMsg.layer.cornerRadius = 5;
        viewMsg.layer.backgroundColor = [UIColor colorWithRed:143.f/255.f green:202.f/255.f blue:221.f/255.f alpha:1].CGColor;
        //消息内容
        NSString *strMsg = rowData[@"Message"];
        CGSize labelSize = [CommonController CalculateFrame:strMsg fontDemond:[UIFont systemFontOfSize:10] sizeDemand:CGSizeMake(250, 500)];
        strMsg = [strMsg stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
        strMsg = [strMsg stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
        UILabel *lbMsg = [[[UILabel alloc] initWithFrame:CGRectMake(10, 5, labelSize.width, labelSize.height)] autorelease];
        [lbMsg setText:strMsg];
        lbMsg.lineBreakMode = NSLineBreakByCharWrapping;
        lbMsg.numberOfLines = 0;
        [lbMsg setFont:[UIFont systemFontOfSize:10]];
        [lbMsg setTextAlignment:NSTextAlignmentLeft];
        [viewMsg addSubview:lbMsg];
        //发送时间
        UILabel *lbRefreshDate = [[[UILabel alloc] initWithFrame:CGRectMake(lbMsg.frame.origin.x, lbMsg.frame.origin.y + lbMsg.frame.size.height + 5, 80, 15)] autorelease];
        NSString *strDate = [CommonController stringFromDate:[CommonController dateFromString:rowData[@"AddDate"]] formatType:@"MM-dd HH:mm"];
        [lbRefreshDate setText:strDate];
        [lbRefreshDate setFont:[UIFont systemFontOfSize:10]];
        [lbRefreshDate setTextColor:[UIColor whiteColor]];
        [lbRefreshDate setTextAlignment:NSTextAlignmentRight];
        [viewMsg addSubview:lbRefreshDate];
        //重新设置消息内容的大小
        viewMsg.frame = CGRectMake(50, 8, labelSize.width + 10, labelSize.height + 15 + 10);
        [cell.contentView addSubview:viewMsg];
        if (viewMsg.frame.size.height > 40) {
            tmpHeight = viewMsg.frame.size.height;
        }
    }else{
        //右侧图片
        UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(320-40-5, 8, 40, 40)]autorelease];
        imgView.image = [UIImage imageNamed:@"ico_onlinechat_cphead_online.png"];
        [cell.contentView addSubview:imgView];
        //消息内容View
        UIView *viewMsg = [[[UIView alloc] initWithFrame:CGRectMake(50, 8, 270, 60)] autorelease];
        viewMsg.layer.backgroundColor = [UIColor colorWithRed:190.f/255.f green:188.f/255.f blue:189.f/255.f alpha:1].CGColor;
        viewMsg.layer.cornerRadius = 5;
        //消息内容
        NSString *strMsg = rowData[@"Message"];
        CGSize labelSize = [CommonController CalculateFrame:strMsg fontDemond:[UIFont systemFontOfSize:10] sizeDemand:CGSizeMake(240, 500)];
        strMsg = [strMsg stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
        strMsg = [strMsg stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
        //最右端的坐标是320-50=270
        UILabel *lbMsg = [[[UILabel alloc] initWithFrame:CGRectMake(10, 5, labelSize.width + 10, labelSize.height)] autorelease];
        [lbMsg setText:strMsg];
        [lbMsg setFont:[UIFont systemFontOfSize:10]];
        lbMsg.lineBreakMode = NSLineBreakByCharWrapping;
        lbMsg.numberOfLines = 0;
        [lbMsg setTextAlignment:NSTextAlignmentLeft];
        [viewMsg addSubview:lbMsg];
        //发送时间
        UILabel *lbRefreshDate = [[[UILabel alloc] initWithFrame:CGRectMake(lbMsg.frame.origin.x, lbMsg.frame.origin.y + lbMsg.frame.size.height + 5, 80, 15)] autorelease];
        NSString *strDate = [CommonController stringFromDate:[CommonController dateFromString:rowData[@"AddDate"]] formatType:@"MM-dd HH:mm"];
        [lbRefreshDate setText:strDate];
        [lbRefreshDate setFont:[UIFont systemFontOfSize:10]];
        [lbRefreshDate setTextColor:[UIColor whiteColor]];
        [lbRefreshDate setTextAlignment:NSTextAlignmentRight];
        [viewMsg addSubview:lbRefreshDate];
        
        //重新设置消息内容的大小
        viewMsg.frame = CGRectMake(270-labelSize.width - 20, 8, labelSize.width + 20, labelSize.height + 20 + 10);
        [cell.contentView addSubview:viewMsg];
        if (viewMsg.frame.size.height > 40) {
            tmpHeight = viewMsg.frame.size.height;
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tmpDic = self.chatOnlineLogData[indexPath.row];
    NSString *strMsg = tmpDic[@"Message"];
     CGSize labelSize = [CommonController CalculateFrame:strMsg fontDemond:[UIFont systemFontOfSize:10] sizeDemand:CGSizeMake(250, 500)];
    if (labelSize.height>20) {
        return 40+ labelSize.height;
    }else{
        return 50;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
    [_viewBottom release];
    [_textSend release];
    [_btnSend release];
    [_viewTop release];    
    [super dealloc];
}
@end
