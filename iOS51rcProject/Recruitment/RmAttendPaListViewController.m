#import "RmAttendPaListViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "MJRefresh.h"
#import "MyRecruitmentViewController.h"
#import "MJRefresh.h"

@interface RmAttendPaListViewController ()<NetWebServiceRequestDelegate>
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) IBOutlet UITableView *tvRecruitmentPaList;
@end

@implementation RmAttendPaListViewController

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
    //添加上拉加载更多
    [self.tvRecruitmentPaList addFooterWithTarget:self action:@selector(footerRereshing)];
    //不显示列表分隔线
    self.tvRecruitmentPaList.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIButton *button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [button setTitle: @"参会个人" forState: UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button sizeToFit];
    self.navigationItem.titleView = button;
    page = 1;
    pageSize = 20;
    //数据加载等待控件初始化
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    [self onSearch];
}

-(void) btnMyRecruitmentClick:(UIBarButtonItem *)sender
{
    MyRecruitmentViewController *myRmCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MyRecruitmentView"];
    [self.navigationController pushViewController:myRmCtrl animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)onSearch
{
    if (page == 1) {
        [self.recruitmentPaData removeAllObjects];
        [self.tvRecruitmentPaList reloadData];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.rmID forKey:@"ID"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",page] forKey:@"pageNum"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",pageSize] forKey:@"pageSize"];   
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetRmPersonList" Params:dicParam];
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
        if(page == 1){
            [self.recruitmentPaData removeAllObjects];
            self.recruitmentPaData = requestData;
        }
        else{
            [self.recruitmentPaData addObjectsFromArray:requestData];
        }
        [self.tvRecruitmentPaList reloadData];
        [self.tvRecruitmentPaList footerEndRefreshing];
        
        //结束等待动画
        [loadView stopAnimating];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell =
    [[[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"paList"] autorelease];
    
    NSDictionary *rowData = self.recruitmentPaData[indexPath.row];
    //标题：现职位
    NSString *strJobName = rowData[@"JobName"];
    if (strJobName == nil) {
        strJobName = @"应届毕业生";
    }
    
    UIFont *titleFont = [UIFont systemFontOfSize:14];
    CGFloat titleWidth = 235;
    CGSize titleSize = CGSizeMake(titleWidth, 5000.0f);
    CGSize labelSize = [CommonController CalculateFrame:strJobName fontDemond:titleFont sizeDemand:titleSize];
    //现职位这三个字的label
    UILabel *lbPreTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 50, 20)];
    lbPreTitle.text = @"[现职位]";
    lbPreTitle.textColor = [UIColor grayColor];
    lbPreTitle.font = [UIFont systemFontOfSize:14];
    //职位名称
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(lbPreTitle.frame.origin.x+lbPreTitle.frame.size.width + 1, lbPreTitle.frame.origin.y, labelSize.width, 20)];
    
    lbTitle.text = strJobName;
    lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
    lbTitle.numberOfLines = 0;
    lbTitle.font = [UIFont systemFontOfSize:14];
    
    [cell.contentView addSubview:lbPreTitle];
    [cell.contentView addSubview:(lbTitle)];
    
    //性别
    BOOL sex = [rowData[@"Gender"] boolValue];
    NSString *strSex;
    if (!sex) {
        strSex = @"男";
    }else{
        strSex = @"女";
    }
    //年龄
    NSString *strAge = rowData[@"BirthDay"];
    NSDate *nowDate =  [NSDate date];
    NSString *strNow = [CommonController stringFromDate:nowDate formatType:@"yyyy-MM-dd"];
    int age = [[strNow substringToIndex:4] intValue] - [[strAge substringToIndex:4] intValue];
    //学历
    NSString *strDegree = rowData[@"Degree"];
    if (strDegree == nil) {
        strDegree = @"";
    }else{
        strDegree = [NSString stringWithFormat:@"/%@", strDegree];
    }
    //经验
    NSString *strRelatedWorkYears = rowData[@"RelatedWorkYears"];
    if (strRelatedWorkYears == nil) {
        strRelatedWorkYears = @"";
    }else if([strRelatedWorkYears isEqualToString:@"0"]){
        strRelatedWorkYears = @"/应届毕业生";
    }else{
        strRelatedWorkYears = [NSString stringWithFormat:@"/%@年", strRelatedWorkYears];
    }
    //所在地
    NSString *strLivePlace = rowData[@"LivePlace"];
    if (strLivePlace == nil) {
        strLivePlace = @"";
    }else{
        strLivePlace = [NSString stringWithFormat:@"%@", strLivePlace];
    }
    NSString *strPaInfo = [NSString stringWithFormat:@"%@/%d岁%@%@  %@ ", strSex, age, strDegree, strRelatedWorkYears, strLivePlace];
    labelSize = [CommonController CalculateFrame:strPaInfo fontDemond:[UIFont systemFontOfSize:12] sizeDemand:titleSize];
    UILabel *lbPaInfo = [[UILabel alloc] initWithFrame:CGRectMake(20, lbTitle.frame.origin.y+lbTitle.frame.size.height + 5, labelSize.width, labelSize.height)];
    lbPaInfo.text = strPaInfo;
    lbPaInfo.font = [UIFont systemFontOfSize:12];
    lbPaInfo.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbPaInfo)];
    //参会时间
    NSString *strBeginDate = rowData[@"BeginDate"];
    NSDate *dtBeginDate = [CommonController dateFromString:strBeginDate];
    strBeginDate = [CommonController stringFromDate:dtBeginDate formatType:@"yyyy-MM-dd HH:mm"];
    NSString *strWeek = [CommonController getWeek:dtBeginDate];
    strBeginDate = [NSString stringWithFormat:@"参会时间：%@ %@",strBeginDate,strWeek];
    
    labelSize = [CommonController CalculateFrame:strBeginDate fontDemond:[UIFont systemFontOfSize:12] sizeDemand:titleSize];
    UILabel *lbBegin = [[UILabel alloc] initWithFrame:CGRectMake(20, lbPaInfo.frame.origin.y+lbPaInfo.frame.size.height + 5, labelSize.width, labelSize.height)];
    lbBegin.text = strBeginDate;
    lbBegin.font = [UIFont systemFontOfSize:12];
    lbBegin.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbBegin)];
    
    //分割线
    UIView *viewSeparate = [[[UIView alloc] initWithFrame:CGRectMake(0, lbBegin.frame.origin.y+lbBegin.frame.size.height + 5, 320, 0.5)] autorelease];
    [viewSeparate setBackgroundColor:[UIColor lightGrayColor]];
    [cell.contentView addSubview:viewSeparate];

    [lbPreTitle release];
    [lbTitle release];
    [lbPaInfo release];
    [lbBegin release];
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.recruitmentPaData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

- (void)footerRereshing{
    page++;
    [self onSearch];
}

- (void)dealloc {
    [_recruitmentPaData release];
    [_tvRecruitmentPaList release];
    [super dealloc];
}
@end
