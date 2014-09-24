#import "GRListViewController.h"
#import "NetWebServiceRequest.h"
#import "CommonController.h"
#import "MJRefresh.h"
#import "DictionaryPickerView.h"
#import "Toast+UIView.h"
#import "SlideNavigationController.h"
#import "GRItemDetailsViewController.h"

@interface GRListViewController ()<NetWebServiceRequestDelegate,SlideNavigationControllerDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tvGRList;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@end

@implementation GRListViewController

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
    //右侧导航按钮
    UIButton *myRmBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 22)];
    //myRmBtn.titleLabel.text = @"我的招聘会";//这样无法赋值
    [myRmBtn setTitle: @"政府招考" forState: UIControlStateNormal];
    myRmBtn.titleLabel.textColor = [UIColor whiteColor];
    myRmBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    myRmBtn.layer.cornerRadius = 5;
    myRmBtn.layer.backgroundColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1].CGColor;
    [myRmBtn addTarget:self action:@selector(btnMyRecruitmentClick:) forControlEvents:UIControlEventTouchUpInside];
    [myRmBtn release];
    
    gRListData = [[NSMutableArray alloc] init];
    placeData = [[NSMutableArray alloc] init];
   
    //数据加载等待控件初始化
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //开始等待动画
    [loadView startAnimating];
    
    //添加上拉加载更多
    [self.tvGRList addFooterWithTarget:self action:@selector(footerRereshing)];
    //不显示列表分隔线
    self.tvGRList.separatorStyle = UITableViewCellSeparatorStyleNone;
   
    page = 1;
    regionid = @"32";
    [self onSearch];
}

-(void) btnMyRecruitmentClick:(UIButton *)sender
{
    GRItemDetailsViewController *gGItemDetailsCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"GRItemDetailsView"];
    [self.navigationController pushViewController:gGItemDetailsCtrl animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];
}

- (void)onSearch
{
    if (page == 1) {
        [gRListData removeAllObjects];
        [self.tvGRList reloadData];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:@"20" forKey:@"pageSize"];
    [dicParam setObject:regionid forKey:@"dcProvinceID"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",page] forKey:@"pageNum"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetGovNewsListByRegion" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 1;
    self.runningRequest = request;
    [dicParam release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell =
    [[[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"rmList"] autorelease];
    
    NSDictionary *rowData = gRListData[indexPath.row];
    
    UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 310, 55)];
    tmpView.layer.borderWidth = 0.5;
    tmpView.layer.borderColor = [UIColor grayColor].CGColor;
    //显示标题
    NSString *strTitle = rowData[@"Title"];
    UIFont *titleFont = [UIFont systemFontOfSize:12];
    CGFloat titleWidth = 245;
    CGSize titleSize = CGSizeMake(titleWidth, 5000.0f);
    CGSize labelSize = [CommonController CalculateFrame:strTitle fontDemond:titleFont sizeDemand:titleSize];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, labelSize.width, labelSize.height)];
    lbTitle.text = strTitle;
    lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
    lbTitle.numberOfLines = 0;
    lbTitle.font = titleFont;
    [tmpView addSubview:(lbTitle)];
    [lbTitle release];
    //来源
    UILabel *lbAuthor = [[UILabel alloc] initWithFrame:CGRectMake(10, (lbTitle.frame.origin.x + lbTitle.frame.size.height)+5, 200, 15)];
    lbAuthor.text = rowData[@"Author"];
    lbAuthor.font = [UIFont systemFontOfSize:11];
    lbAuthor.textColor = [UIColor grayColor];
    [tmpView addSubview:(lbAuthor)];
    [lbAuthor release];
    //显示举办时间
    UILabel *lbTime = [[UILabel alloc] initWithFrame:CGRectMake(220, (lbTitle.frame.origin.x + lbTitle.frame.size.height)+5, 80, 15)];
    NSString *strDate = rowData[@"RefreshDate"];
    NSDate *dtBeginDate = [CommonController dateFromString:strDate];
    strDate = [CommonController stringFromDate:dtBeginDate formatType:@"MM-dd HH:mm"];
    lbTime.text = strDate;
    lbTime.textColor = [UIColor grayColor];
    lbTime.font = [UIFont systemFontOfSize:11];
    lbTime.textAlignment = NSTextAlignmentRight;
    [tmpView addSubview:(lbTime)];
    [lbTime release];
    //New图片
    NSDate *today = [NSDate date];
    NSString *strToday = [CommonController stringFromDate:today formatType:@"yyyy-MM-dd"];
    //today =[ CommonController dateFromString:strToday];
    NSString *tmpDate = [CommonController stringFromDate:dtBeginDate formatType:@"yyyy-MM-dd"];
    //NSDate *dtEarly = [today earlierDate:dtBeginDate];
    //if ([dtEarly isEqualToDate:today]) {
    if ([strToday isEqualToString:tmpDate]) {
        UIImageView *imgNew = [[UIImageView alloc] initWithFrame:CGRectMake(280, 0, 30, 30)];
        imgNew.image = [UIImage imageNamed:@"ico_jobnews_searchresult.png"];
        [tmpView addSubview:imgNew];
        [imgNew release];
    }
    
    [cell.contentView addSubview:tmpView];
    [tmpView autorelease];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    GRItemDetailsViewController *detailCtrl = (GRItemDetailsViewController*)[self.storyboard
                                                                      instantiateViewControllerWithIdentifier: @"GRItemDetailsView"];
    detailCtrl.strNewsID = gRListData[indexPath.row][@"ID"];
    [self.navigationController pushViewController:detailCtrl animated:true];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [gRListData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 58;
}

- (void)footerRereshing{
    page++;
    [self onSearch];
}

//成功
- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSMutableArray *)requestData
{
    if (request.tag == 1) {
        if(page == 1){
            [gRListData removeAllObjects];
            gRListData = requestData;
        }
        else{
            [gRListData addObjectsFromArray:requestData];
        }
        [self.tvGRList reloadData];
        [self.tvGRList footerEndRefreshing];
        
        //结束等待动画
        [loadView stopAnimating];
    }
}

- (void)dealloc {
    //[placeData release];
    //[loadView release];
    [_tvGRList release];
    [_runningRequest release];
    [super dealloc];
}



- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (int)slideMenuItem
{
    return 6;
}

@end
