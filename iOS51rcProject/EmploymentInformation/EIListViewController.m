#import "EIListViewController.h"
#import "NetWebServiceRequest.h"
#import "CommonController.h"
#import "MJRefresh.h"
#import "DictionaryPickerView.h"
#import "Toast+UIView.h"
#import "EIItemDetailsViewController.h"
#import "EiSearchViewController.h"

@interface EIListViewController ()<NetWebServiceRequestDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tvEIList;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@end

@implementation EIListViewController
//@synthesize
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
    UIButton *button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [button setTitle: @"就业资讯" forState: UIControlStateNormal];
    [button sizeToFit];
    self.navigationItem.titleView = button;
    //返回按钮
    UIButton *leftBtn = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)] autorelease];
    [leftBtn addTarget:self action:@selector(btnBackClick:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *lbLeft = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 40)] autorelease];
    lbLeft.text = @"返回";
    lbLeft.font = [UIFont systemFontOfSize:13];
    //lbLeft.textColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
    lbLeft.textColor = [UIColor whiteColor];
    [leftBtn addSubview:lbLeft];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem=backButton;
    
    eiListData = [[NSMutableArray alloc] init];
    placeData = [[NSMutableArray alloc] init];
    
    //数据加载等待控件初始化
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //开始等待动画
    [loadView startAnimating];
    
    //添加上拉加载更多
    [self.tvEIList addFooterWithTarget:self action:@selector(footerRereshing)];
    //不显示列表分隔线
    self.tvEIList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    page = 1;
    regionid = @"32";
    [self onSearch];
}

//后退
-(void) btnBackClick:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];
}

- (void)onSearch
{
    if (page == 1) {
        [eiListData removeAllObjects];
        [self.tvEIList reloadData];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:regionid forKey:@"dcRegionID"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",page] forKey:@"pageNum"];
    [dicParam setObject:@"20" forKey:@"pageSize"];
    [dicParam setObject:self.strKeyWord forKey:@"strKeyword"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetNewsListByKeyWordSearch" Params:dicParam];
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
    
    NSDictionary *rowData = eiListData[indexPath.row];
    
    //显示标题
    NSString *strTitle = rowData[@"Title"];
    UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 310, 55)];
    tmpView.layer.borderWidth = 0.5;
    tmpView.layer.borderColor = [UIColor grayColor].CGColor;
    
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
    NSString *strAuthor = rowData[@"Author"];
    UILabel *lbAuthor = [[UILabel alloc] initWithFrame:CGRectMake(10, (lbTitle.frame.origin.x + lbTitle.frame.size.height)+5, 200, 15)];
    lbAuthor.text = strAuthor;
    lbAuthor.font = [UIFont systemFontOfSize:11];
    lbAuthor.textColor = [UIColor grayColor];
    [tmpView addSubview:(lbAuthor)];
    [lbAuthor release];
    
    NSString *strDate = rowData[@"RefreshDate"];
    
    UILabel *lbTime = [[UILabel alloc] initWithFrame:CGRectMake(220, (lbTitle.frame.origin.x + lbTitle.frame.size.height)+5, 80, 15)];
    NSDate *dtBeginDate = [CommonController dateFromString:strDate];
    strDate = [CommonController stringFromDate:dtBeginDate formatType:@"MM-dd HH:mm"];
    lbTime.text = strDate;
    lbTime.textColor = [UIColor grayColor];
    lbTime.font = [UIFont systemFontOfSize:11];
    lbTime.textAlignment = NSTextAlignmentRight;
    [tmpView addSubview:(lbTime)];
    [lbTime release];
       [cell.contentView addSubview:tmpView];
    [tmpView autorelease];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     EIItemDetailsViewController *detailCtrl = (EIItemDetailsViewController*)[self.storyboard
                                                                             instantiateViewControllerWithIdentifier: @"EIItemDetailsView"];
    detailCtrl.strNewsID = eiListData[indexPath.row][@"Id"];
    [self.navigationController pushViewController:detailCtrl animated:true];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [eiListData count];
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
            [eiListData removeAllObjects];
            eiListData = requestData;
        }
        else{
            [eiListData addObjectsFromArray:requestData];
        }
        [self.tvEIList reloadData];
        [self.tvEIList footerEndRefreshing];
        
        //结束等待动画
        [loadView stopAnimating];
    }
}

- (void)dealloc {
    
    [placeData release];
    [loadView release];
    [_tvEIList release];
    [_runningRequest release];
    [super dealloc];
}
@end

