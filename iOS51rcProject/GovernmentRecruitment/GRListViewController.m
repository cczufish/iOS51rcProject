#import "GRListViewController.h"
#import "NetWebServiceRequest.h"
#import "CommonController.h"
#import "MJRefresh.h"
#import "DictionaryPickerView.h"
#import "Toast+UIView.h"
#import "SlideNavigationController.h"
#import "GRItemDetailsViewController.h"

@interface GRListViewController ()<NetWebServiceRequestDelegate,SlideNavigationControllerDelegate>
@property (retain, nonatomic) IBOutlet UICollectionView *tvGRList;
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
    self.view.backgroundColor = [UIColor colorWithRed:250.f/255.f green:250.f/255.f blue:250.f/255.f alpha:1];
    self.tvGRList.backgroundColor = [UIColor colorWithRed:250.f/255.f green:250.f/255.f blue:250.f/255.f alpha:1];
    [self.navigationItem setTitle:@"政府招考"];
    
    self.gRListData = [[NSMutableArray alloc] init];    
   
    //数据加载等待控件初始化
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //开始等待动画
    [loadView startAnimating];
    
    //添加上拉加载更多
    [self.tvGRList addFooterWithTarget:self action:@selector(footerRereshing)];
   
    page = 1;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    regionid = [userDefault objectForKey:@"subSiteId"];
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
        [self.gRListData removeAllObjects];
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

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"grList" forIndexPath:indexPath];
    //清除以前的
    for (UIView*view in cell.contentView.subviews) {
        if (view) {
            [view removeFromSuperview];
        }
    }
    NSDictionary *rowData = self.gRListData[indexPath.row];
   
    cell.layer.borderWidth = 1;
    cell.layer.borderColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
    cell.backgroundColor = [UIColor whiteColor];//与背景颜色区分开
    //点击
    UIButton *buttonTitle = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 300, 55)] autorelease];
    [buttonTitle setTag:[rowData[@"ID"] intValue]];
    [buttonTitle addTarget:self action:@selector(btnGrItemClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:buttonTitle];
    //显示标题
    NSString *strTitle = rowData[@"Title"];
    strTitle = [strTitle stringByReplacingOccurrencesOfString:@"（图）" withString:@""];
    UIFont *titleFont = [UIFont systemFontOfSize:13];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 290, 17)];
    lbTitle.text = strTitle;
    lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
    lbTitle.numberOfLines = 0;
    lbTitle.font = titleFont;
    [cell.contentView addSubview:(lbTitle)];
    [lbTitle release];
    //来源
    UILabel *lbAuthor = [[UILabel alloc] initWithFrame:CGRectMake(10, (lbTitle.frame.origin.x + lbTitle.frame.size.height)+5, 200, 15)];
    lbAuthor.text = rowData[@"Author"];
    lbAuthor.font = [UIFont systemFontOfSize:12];
    lbAuthor.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbAuthor)];
    [lbAuthor release];
    //显示举办时间
    UILabel *lbTime = [[UILabel alloc] initWithFrame:CGRectMake(200, (lbTitle.frame.origin.x + lbTitle.frame.size.height)+5, 80, 15)];
    NSString *strDate = rowData[@"RefreshDate"];
    NSDate *dtBeginDate = [CommonController dateFromString:strDate];
    strDate = [CommonController stringFromDate:dtBeginDate formatType:@"MM-dd HH:mm"];
    lbTime.text = strDate;
    lbTime.textColor = [UIColor grayColor];
    lbTime.font = [UIFont systemFontOfSize:12];
    lbTime.textAlignment = NSTextAlignmentRight;
    [cell.contentView addSubview:(lbTime)];
    [lbTime release];
    //New图片
    NSDate *today = [NSDate date];
    NSString *strToday = [CommonController stringFromDate:today formatType:@"yyyy-MM-dd"];
    NSString *tmpDate = [CommonController stringFromDate:dtBeginDate formatType:@"yyyy-MM-dd"];
    if ([strToday isEqualToString:tmpDate]) {
        UIImageView *imgNew = [[UIImageView alloc] initWithFrame:CGRectMake(280, 0, 30, 30)];
        imgNew.image = [UIImage imageNamed:@"ico_jobnews_searchresult.png"];
        [cell.contentView addSubview:imgNew];
        [imgNew release];
    }
    
    return cell;
}

- (void)btnGrItemClick:(UIButton *)sender
{
    GRItemDetailsViewController *detailCtrl = (GRItemDetailsViewController*)[self.storyboard
                                                                          instantiateViewControllerWithIdentifier: @"GRItemDetailsView"];
    detailCtrl.strNewsID = [NSString stringWithFormat:@"%d",sender.tag];
    [self.navigationController pushViewController:detailCtrl animated:true];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.gRListData count];
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
            [self.gRListData removeAllObjects];
            self.gRListData = requestData;
        }
        else{
            [self.gRListData addObjectsFromArray:requestData];
        }
        [self.tvGRList reloadData];
        [self.tvGRList footerEndRefreshing];
        
        //结束等待动画
        [loadView stopAnimating];
    }
}

- (void)dealloc {
    [_gRListData release];
    [loadView release];
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
