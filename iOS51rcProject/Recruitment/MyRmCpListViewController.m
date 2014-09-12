#import "MyRmCpListViewController.h"
#import "MJRefresh.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "RecruitmentViewController.h"

//我邀请的企业列表
@interface MyRmCpListViewController ()<NetWebServiceRequestDelegate>
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) IBOutlet UITableView *tvRecruitmentCpList;
@property (retain, nonatomic) IBOutlet UIButton *btnInviteCp;

@end

@implementation MyRmCpListViewController
@synthesize gotoRmViewDelegate;
@synthesize gotoMyInvitedCpViewDelegate;

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
    
    self.btnInviteCp.layer.cornerRadius = 5;
    //数据加载等待控件初始化
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    [self onSearch];
    self.btnInviteCp.frame = CGRectMake(100, 300, 100, 50);
}
- (void)onSearch
{
    [recruitmentCpData removeAllObjects];
    [self.tvRecruitmentCpList reloadData];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *code = [userDefaults objectForKey:@"code"];
    NSString *userID = [userDefaults objectForKey:@"UserID"];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:userID forKey:@"paMainID"];//25056119
    [dicParam setObject:code forKey:@"code"];//152014391908
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetMyBespeakList" Params:dicParam];
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
    //显示标题
    NSString *strRecruitmentName = rowData[@"RecruitmentName"];
    UIFont *titleFont = [UIFont systemFontOfSize:15];
    CGFloat titleWidth = 270;
    CGSize titleSize = CGSizeMake(titleWidth, 5000.0f);
    CGSize labelSize = [CommonController CalculateFrame:strRecruitmentName fontDemond:titleFont sizeDemand:titleSize];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, labelSize.width, labelSize.height)];
    lbTitle.text = strRecruitmentName;
    lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
    lbTitle.numberOfLines = 0;
    lbTitle.font = titleFont;
    [cell.contentView addSubview:(lbTitle)];
    [lbTitle release];
    
    //显示举办时间 举办场馆 具体地址
    UILabel *lbBegin = [[UILabel alloc] initWithFrame:CGRectMake(20, (labelSize.height + 15), titleWidth, 15)];
    NSString *strBeginDate = rowData[@"BeginDate"];
    NSDate *dtBeginDate = [CommonController dateFromString:strBeginDate];
    strBeginDate = [CommonController stringFromDate:dtBeginDate formatType:@"yyyy-MM-dd HH:mm"];
    NSString *strWeek = [CommonController getWeek:dtBeginDate];
    lbBegin.text = [NSString stringWithFormat:@"举办时间：%@ %@",strBeginDate,strWeek];
    lbBegin.font = [UIFont systemFontOfSize:12];
    lbBegin.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbBegin)];
    [lbBegin release];
    
    //举办场馆
    NSString *strPlace = [NSString stringWithFormat:@"举办场馆：%@",rowData[@"PlaceName"]];
    labelSize = [CommonController CalculateFrame:strPlace fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(200, 40)];
    UILabel *lbPlace = [[UILabel alloc] initWithFrame:CGRectMake(20, lbBegin.frame.origin.y + lbBegin.frame.size.height + 5, labelSize.width, labelSize.height)];
    lbPlace.text = strPlace;
    lbPlace.font = [UIFont systemFontOfSize:12];
    lbPlace.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbPlace)];
    [lbPlace release];
    
    //坐标
    UIButton *btnLngLat = [[UIButton alloc] initWithFrame:CGRectMake(20 + lbPlace.frame.size.width, lbPlace.frame.origin.y, 15, 15)];
    //NSString *lng = rowData[@"lng"];
    //NSString *lat = rowData[@"lat"];
    UIImageView *imgLngLat = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    imgLngLat.image = [UIImage imageNamed:@"ico_coordinate_red.png"];
    [btnLngLat addSubview:imgLngLat];
    btnLngLat.tag = (NSInteger)rowData[@"ID"];
    [btnLngLat addTarget:self action:@selector(btnLngLatClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnLngLat];
    [btnLngLat release];
    [imgLngLat release];
    
    //举办地址
    NSString *strAddress =[NSString stringWithFormat:@"举办地址：%@",rowData[@"Address"]];
    labelSize = [CommonController CalculateFrame:strPlace fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(200, 40)];
    UILabel *lbAddress = [[UILabel alloc] initWithFrame:CGRectMake(20, lbPlace.frame.origin.y + lbPlace.frame.size.height + 5, labelSize.width, labelSize.height)];
    lbAddress.text = strAddress;
    lbAddress.font = [UIFont systemFontOfSize:12];
    lbAddress.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbAddress)];
    [lbAddress release];
    
    //我邀请的企业
    NSString *myRmCpCount = rowData[@"myInvitCpNum"] ;
    UIButton *btnMyRmCp = [[UIButton alloc] initWithFrame:CGRectMake(237, 58, 75, 40)];
    UILabel *lbMyRmCp = [[UILabel alloc] initWithFrame:CGRectMake(7, 25, 60, 10)];
    lbMyRmCp.text = @"我邀请的企业";
    lbMyRmCp.font = [UIFont systemFontOfSize:10];
    lbMyRmCp.textColor = [UIColor blackColor];
    lbMyRmCp.textAlignment = NSTextAlignmentCenter;
    [btnMyRmCp addSubview:lbMyRmCp];
    
    UILabel *lbMyRmCpCount = [[UILabel alloc] initWithFrame:CGRectMake(17, 9, 40, 10)];
    lbMyRmCpCount.text = myRmCpCount;
    lbMyRmCpCount.font = [UIFont systemFontOfSize:9];
    lbMyRmCpCount.textColor = [UIColor redColor];
    lbMyRmCpCount.textAlignment = NSTextAlignmentCenter;
    [btnMyRmCp addSubview:lbMyRmCpCount];
  
    //我邀请的企业按钮
    btnMyRmCp.tag = (NSInteger)rowData[@"paMainID"];
    btnMyRmCp.layer.borderWidth = 0.5;
    btnMyRmCp.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [btnMyRmCp addTarget:self action:@selector(joinRecruitment:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnMyRmCp];
    
    [btnMyRmCp release];
    [lbMyRmCp release];
    [lbMyRmCpCount release];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [recruitmentCpData count];
}

//邀请企业参会
- (IBAction)btnInviteCp:(id)sender {
    NSLog(@"邀请企业参会");
}

//点击坐标
-(void)btnLngLatClick:(UIButton *) sender{
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
}

//每一行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
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
    [_tvRecruitmentCpList release];
    [_btnInviteCp release];
    [super dealloc];
}
@end
