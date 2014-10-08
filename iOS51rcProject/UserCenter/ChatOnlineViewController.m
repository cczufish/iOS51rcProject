#import "ChatOnlineViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "ChatOnlineLogViewController.h"
#import "JSBadgeView.h"

@interface ChatOnlineViewController ()<NetWebServiceRequestDelegate,UITableViewDataSource,UITableViewDelegate>
{
    LoadingAnimationView *loadView;
}

@property (retain, nonatomic) IBOutlet UITableView *tvChatOnlineList;
@property (nonatomic, retain) NSMutableArray *chatOnlineListData;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@end

@implementation ChatOnlineViewController
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
    self.navigationItem.title = @"在线沟通";
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    
    //不显示列表分隔线
    self.tvChatOnlineList.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self onSearch];
}

- (void)viewDidAppear:(BOOL)animated{
    //[self onSearch];
}

- (void)onSearch
{
    //开始等待动画
    [loadView startAnimating];
   
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *code = [userDefaults objectForKey:@"code"];
    NSString *userID = [userDefaults objectForKey:@"UserID"];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:userID forKey:@"paMainID"];//21142013
    [dicParam setObject:code forKey:@"code"];//152014391908
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetChatOnlineList" Params:dicParam];
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
        [self.chatOnlineListData removeAllObjects];
        self.chatOnlineListData = requestData;
        //重新加载列表
        [self.tvChatOnlineList reloadData];
    }
    //结束等待动画
    [loadView stopAnimating];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatOnlineListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont *fontCell = [UIFont systemFontOfSize:14];
    UIColor *colorText = [UIColor colorWithRed:120.f/255.f green:120.f/255.f blue:120.f/255.f alpha:1];
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"jobList"] autorelease];
    NSDictionary *rowData = self.chatOnlineListData[indexPath.row];
    
    //左侧图片
    UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(5, 8, 40, 40)]autorelease];
    imgView.image = [UIImage imageNamed:@"ico_onlinechat_cphead_online.png"];
    [cell.contentView addSubview:imgView];
    
    //未读数目
    NSString *strNoViewedNum = rowData[@"NoViewedNum"];
    if (![strNoViewedNum isEqualToString:@"0"]) {
        JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:imgView alignment:JSBadgeViewAlignmentTopRight];
        badgeView.badgeText = [NSString stringWithFormat:@"%@", strNoViewedNum];
    }
    
    //公司名称
    UILabel *lbCompanyName = [[UILabel alloc] initWithFrame:CGRectMake(50, 8, 180, 15)];
    [lbCompanyName setText:rowData[@"Name"]];
    [lbCompanyName setFont:[UIFont systemFontOfSize:13]];
    [lbCompanyName setTextColor:[UIColor blackColor]];
    [cell.contentView addSubview:lbCompanyName];
    [lbCompanyName release];
    
    //时间
    UILabel *lbRefreshDate = [[UILabel alloc] initWithFrame:CGRectMake(lbCompanyName.frame.origin.x + lbCompanyName.frame.size.width, lbCompanyName.frame.origin.y, 80, 15)];
    NSString *strDate = [CommonController stringFromDate:[CommonController dateFromString:rowData[@"SendDate"]] formatType:@"MM-dd HH:mm"];
    [lbRefreshDate setText:strDate];
    [lbRefreshDate setFont:[UIFont systemFontOfSize:14]];
    [lbRefreshDate setTextColor:colorText];
    [lbRefreshDate setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbRefreshDate];
    [lbRefreshDate release];
    
    //消息内容
    NSString *strMsg = rowData[@"Message"];
    strMsg = [strMsg stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    strMsg = [strMsg stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    strMsg = [strMsg stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    UILabel *lbMsg = [[[UILabel alloc] initWithFrame:CGRectMake(50, 25, 270, 20)] autorelease];
    [lbMsg setText:strMsg];
    [lbMsg setFont:fontCell];
    [lbMsg setTextAlignment:NSTextAlignmentLeft];
    [cell.contentView addSubview:lbMsg];
    
    //分割线
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, 55, 320, 1)];
    [viewSeparate setBackgroundColor:[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1]];
    [cell.contentView addSubview:viewSeparate];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *rowData = self.chatOnlineListData[indexPath.row];
    ChatOnlineLogViewController *logCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatOnlineLogView"];
    logCtrl.cvMainID = rowData[@"CvMainID"];
    logCtrl.caMainID = rowData[@"CaMainID"];
    logCtrl.cpName = rowData[@"Name"];
    logCtrl.caName = rowData[@"caName"];
    logCtrl.cpMainID = rowData[@"cpMainID"];
    logCtrl.isOnline = rowData[@"OnlineStatus"];
    logCtrl.navigationItem.title = @"在线沟通";    
    [self.navigationController pushViewController:logCtrl animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
    [_runningRequest release];
    [_chatOnlineListData release];
    [super dealloc];
}
@end
