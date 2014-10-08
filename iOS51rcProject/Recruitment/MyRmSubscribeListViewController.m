#import "MyRmSubscribeListViewController.h"
#import "MJRefresh.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "RecruitmentViewController.h"
#import "RmInviteCpViewController.h"
#import "RmSearchJobForInviteViewController.h"
#import "MapViewController.h"
#import "MyRmInviteCpListViewController.h"

//我的预约
@interface MyRmSubscribeListViewController ()<NetWebServiceRequestDelegate>
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) IBOutlet UITableView *tvRecruitmentCpList;
@property (retain, nonatomic) IBOutlet UIView *viewBottom;
@property (retain, nonatomic) IBOutlet UIButton *btnInviteCp;
@property (retain, nonatomic) NSMutableArray *recruitmentCpData;

@end

@implementation MyRmSubscribeListViewController
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
    self.viewBottom.layer.borderColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
    self.viewBottom.layer.borderWidth = 0.5;
    self.viewBottom.frame = CGRectMake(0, self.view.frame.size.height - self.viewBottom.frame.size.height - 109, 320, self.viewBottom.frame.size.height);
    self.btnInviteCp.layer.cornerRadius = 5;
    self.btnInviteCp.backgroundColor =  [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
    //数据加载等待控件初始化
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //不显示列表分隔线
    self.tvRecruitmentCpList.separatorStyle = UITableViewCellSeparatorStyleNone;
}
- (void)onSearch
{
    [self.recruitmentCpData removeAllObjects];
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
    [loadView startAnimating];
}

//成功
- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result responseData:(NSMutableArray *)requestData
{
    if (requestData.count>0) {
        [self.recruitmentCpData removeAllObjects];
        self.recruitmentCpData = requestData;
        [self.recruitmentCpData retain];
        
        if (self.recruitmentCpData.count>0) {
            [self.tvRecruitmentCpList reloadData];
            [self.tvRecruitmentCpList footerEndRefreshing];
        }
    }else{
        //记录
        UIView *viewHsaNoCv = [[[UIView alloc] initWithFrame:CGRectMake(20, 100, 240, 80)]autorelease];
        UIImageView *img = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 60)] autorelease];
        img.image = [UIImage imageNamed:@"pic_noinfo.png"];
        [viewHsaNoCv addSubview:img];
        
        NSString *strMsg = @"亲，您还没有预约参加招聘会，现在就去报名预约参会吧.";
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
    UITableViewCell *cell =
    [[[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"cpList"] autorelease];
    
    NSDictionary *rowData = self.recruitmentCpData[indexPath.row];
    //显示标题
    NSString *strRecruitmentName = rowData[@"RecruitmentName"];
    UIFont *titleFont = [UIFont systemFontOfSize:15];
    CGFloat titleWidth = 290;
    CGSize titleSize = CGSizeMake(titleWidth, 5000.0f);
    CGSize labelSize = [CommonController CalculateFrame:strRecruitmentName fontDemond:titleFont sizeDemand:titleSize];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, labelSize.width, labelSize.height)];
    lbTitle.text = strRecruitmentName;
    lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
    lbTitle.numberOfLines = 0;
    lbTitle.font = titleFont;
    [cell.contentView addSubview:(lbTitle)];
    [lbTitle release];
    
    //显示举办时间 举办场馆 具体地址
    UILabel *lbBegin = [[UILabel alloc] initWithFrame:CGRectMake(15, (labelSize.height + 15), titleWidth, 15)];
    NSString *strBeginDate = rowData[@"BeginDate"];
    NSDate *dtBeginDate = [CommonController dateFromString:strBeginDate];
    strBeginDate = [CommonController stringFromDate:dtBeginDate formatType:@"yyyy-MM-dd HH:mm"];
    NSString *strWeek = [CommonController getWeek:dtBeginDate];
    lbBegin.text = [NSString stringWithFormat:@"举办时间：%@ %@",strBeginDate,strWeek];
    lbBegin.font = [UIFont systemFontOfSize:14];
    lbBegin.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbBegin)];
    [lbBegin release];
    
    //举办场馆
    NSString *strPrePlace = @"举办场馆：";
    UILabel *lbPrePlace = [[UILabel alloc] initWithFrame:CGRectMake(15, lbBegin.frame.origin.y + lbBegin.frame.size.height + 5, 70, 17)];
    lbPrePlace.text = strPrePlace;
    lbPrePlace.font = [UIFont systemFontOfSize:14];
    lbPrePlace.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbPrePlace)];
    [lbPrePlace release];
    //具体场馆地址
    NSString *strPlace = rowData[@"PlaceName"];
    labelSize = [CommonController CalculateFrame:strPlace fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(140, 400)];
    UILabel *lbPlace = [[UILabel alloc] initWithFrame:CGRectMake(85, lbBegin.frame.origin.y + lbBegin.frame.size.height + 5, MIN(labelSize.width, 133), 17)];
    lbPlace.text = strPlace;
    lbPlace.numberOfLines = 0;
    lbPlace.lineBreakMode = NSLineBreakByCharWrapping;
    lbPlace.font = [UIFont systemFontOfSize:14];
    lbPlace.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbPlace)];
    [lbPlace release];
    
    //坐标
    UIButton *btnLngLat = [[UIButton alloc] initWithFrame:CGRectMake(lbPlace.frame.origin.x + lbPlace.frame.size.width, lbPlace.frame.origin.y, 15, 15)];
    UIImageView *imgLngLat = [[UIImageView alloc] initWithFrame:CGRectMake(3, 0, 13, 17)];
    imgLngLat.image = [UIImage imageNamed:@"ico_cpinfo_cpaddress.png"];
    [btnLngLat addSubview:imgLngLat];
    btnLngLat.tag = indexPath.row;
    [btnLngLat addTarget:self action:@selector(btnLngLatClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnLngLat];
    [btnLngLat release];
    [imgLngLat release];
    
    //具体地址
    NSString *strPreAddress = @"具体地址：";
    UILabel *lbPreAddress = [[UILabel alloc] initWithFrame:CGRectMake(15, lbPlace.frame.origin.y + lbPlace.frame.size.height + 5, 70, 17)];
    lbPreAddress.text = strPreAddress;
    lbPreAddress.font = [UIFont systemFontOfSize:14];
    lbPreAddress.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbPreAddress)];
    [lbPreAddress release];
    
    NSString *strAddress = rowData[@"Address"];
    labelSize = [CommonController CalculateFrame:strAddress fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(140, 80)];
    UILabel *lbAddress = [[UILabel alloc] initWithFrame:CGRectMake(84, lbPlace.frame.origin.y + lbPlace.frame.size.height + 5, labelSize.width, labelSize.height)];
    lbAddress.text = strAddress;
    lbAddress.numberOfLines = 0;
    lbAddress.lineBreakMode = NSLineBreakByCharWrapping;
    lbAddress.font = [UIFont systemFontOfSize:14];
    lbAddress.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbAddress)];
    [lbAddress release];
    
    //我邀请的企业(右侧的小方块)
    NSString *myRmCpCount = rowData[@"myInvitCpNum"] ;
    UIButton *btnMyRmCp = [[UIButton alloc] initWithFrame:CGRectMake(237, lbBegin.frame.origin.y + 15, 76, 40)];
    UILabel *lbMyRmCp = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 80, 10)];
    lbMyRmCp.text = @"我邀请的企业";
    lbMyRmCp.font = [UIFont systemFontOfSize:11];
    lbMyRmCp.textColor = [UIColor blackColor];
    lbMyRmCp.textAlignment = NSTextAlignmentCenter;
    [btnMyRmCp addSubview:lbMyRmCp];
    //我邀请的企业个数
    UILabel *lbMyRmCpCount = [[UILabel alloc] initWithFrame:CGRectMake(17, 7, 40, 10)];
    lbMyRmCpCount.text = myRmCpCount;
    lbMyRmCpCount.font = [UIFont systemFontOfSize:12];
    lbMyRmCpCount.textColor = [UIColor redColor];
    lbMyRmCpCount.textAlignment = NSTextAlignmentCenter;
    [btnMyRmCp addSubview:lbMyRmCpCount];
    //我邀请的企业按钮
    btnMyRmCp.tag = [rowData[@"id"] intValue];
    btnMyRmCp.layer.borderWidth = 0.5;
    btnMyRmCp.layer.borderColor = [UIColor lightGrayColor].CGColor;
    if (![myRmCpCount isEqualToString:@"0"]) {//大于0才可以点击
        [btnMyRmCp addTarget:self action:@selector(myInvitedCp:) forControlEvents:UIControlEventTouchUpInside];
    }
    [cell.contentView addSubview:btnMyRmCp];
    
    [btnMyRmCp release];
    [lbMyRmCp release];
    [lbMyRmCpCount release];
    
    //分割线
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, lbAddress.frame.origin.y+lbAddress.frame.size.height + 2, 320, 1)];
    [viewSeparate setBackgroundColor:[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1]];
    [cell.contentView addSubview:viewSeparate];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.recruitmentCpData count];
}

//邀请企业参会
- (IBAction)btnInviteCp:(id)sender {
    UIViewController *pCtrl = [CommonController getFatherController:self.view];
    RmSearchJobForInviteViewController *inviteViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"RmSearchJobForInviteView"];
    [pCtrl.navigationController pushViewController:inviteViewCtrl animated:true];   
    inviteViewCtrl.navigationItem.title = @"邀请企业参会";
}

//点击坐标
-(void)btnLngLatClick:(UIButton *) sender{
    NSDictionary *rowData = self.recruitmentCpData[sender.tag];
    MapViewController *mapC = [[UIStoryboard storyboardWithName:@"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"MapView"];
    mapC.lat = [rowData[@"lat"] floatValue];
    mapC.lng = [rowData[@"lng"] floatValue];
    [mapC.navigationItem setTitle:rowData[@"PlaceName"]];
    UIViewController *superJobC = [CommonController getFatherController:self.view];
    [superJobC.navigationController pushViewController:mapC animated:true];
}

//点击我邀请的企业
-(void)myInvitedCp:(UIButton *) sender{
    UIViewController *pCtrl = [CommonController getFatherController:self.view];
    MyRmInviteCpListViewController *rmViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MyRmInviteCpListView"];
    rmViewCtrl.rmID = [NSString stringWithFormat:@"%d", sender.tag];
    [pCtrl.navigationController pushViewController:rmViewCtrl animated:true];   
}

//点击某一行,到达企业页面--调用代理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [gotoRmViewDelegate gotoRmView:self.recruitmentCpData[indexPath.row][@"id"]];
}


//每一行的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     NSInteger height = 12;
    NSString *strRecruitmentName = self.recruitmentCpData[indexPath.row][@"RecruitmentName"];
    CGSize titleSize = CGSizeMake(290, 5000.0f);
    CGSize labelSize = [CommonController CalculateFrame:strRecruitmentName fontDemond:[UIFont systemFontOfSize:15] sizeDemand:titleSize];
    height +=labelSize.height + 5;
    //举办时间＝15+5
    height += 20;
    NSString *strAddress = self.recruitmentCpData[indexPath.row][@"Address"];
    labelSize = [CommonController CalculateFrame:strAddress fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(140, 400)];
    height +=labelSize.height + 5;
    
    NSString *strPlace = self.recruitmentCpData[indexPath.row][@"PlaceName"];
    labelSize = [CommonController CalculateFrame:strPlace fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(140, 400)];
    height +=labelSize.height + 5;
    
    return height;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [loadView release];
    [_tvRecruitmentCpList release];
    [self.recruitmentCpData release];
    [_btnInviteCp release];
    [_viewBottom release];
    [super dealloc];
}
@end
