#import "CampusTalkViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "MJRefresh.h"
#import "DictionaryPickerView.h"

@interface CampusTalkViewController () <UICollectionViewDataSource,UICollectionViewDelegate,NetWebServiceRequestDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NSMutableArray *campusListData;
@property (nonatomic, retain) NSString *regionId;
@property (nonatomic, retain) NSString *schoolId;
@property int pageNumber;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) DictionaryPickerView *dictionaryPicker;
@property (retain, nonatomic) IBOutlet UICollectionView *collectView;
@end

@implementation CampusTalkViewController

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
    self.automaticallyAdjustsScrollViewInsets = NO;
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //添加上拉加载更多
    [self.collectView addFooterWithTarget:self action:@selector(footerRereshing)];
    self.pageNumber = 1;
    self.regionId = @"";
    self.schoolId = @"";
    [self onSearch];
}

- (void)onSearch
{
    if (self.pageNumber == 1) {
        [self.campusListData removeAllObjects];
        [self.collectView reloadData];
        //开始等待动画
        [loadView startAnimating];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.pageNumber] forKey:@"pageNum"];
    [dicParam setObject:@"30" forKey:@"pageSize"];
    [dicParam setObject:self.regionId forKey:@"dcRegionID"];
    [dicParam setObject:self.schoolId forKey:@"strSchoolID"];
    [dicParam setObject:@"32" forKey:@"strProvinceID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCampusListByRegionAndSchool" Params:dicParam];
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
    if(self.pageNumber == 1){
        [self.campusListData removeAllObjects];
        self.campusListData = requestData;
    }
    else{
        [self.campusListData addObjectsFromArray:requestData];
    }
    [self.collectView footerEndRefreshing];
    //重新加载列表
    [self.collectView reloadData];
    //结束等待动画
    [loadView stopAnimating];
}

- (void)footerRereshing{
    self.pageNumber++;
    [self onSearch];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.campusListData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"campus" forIndexPath:indexPath];
    for (UIView*view in cell.contentView.subviews) {
        if (view) {
            [view removeFromSuperview];
        }
    }
    cell.clearsContextBeforeDrawing = YES;
    cell.layer.borderWidth = 1;
    cell.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    //企业名称
    NSDictionary *rowData = [self.campusListData objectAtIndex:indexPath.row];
    UILabel *lbCompanyName = [[UILabel alloc] initWithFrame:CGRectMake(10, 9, 220, 25)];
    [lbCompanyName setText:rowData[@"CompanyName"]];
    [cell.contentView addSubview:lbCompanyName];
    [lbCompanyName release];
    
    //举办日期
    NSString *strBeginTime = rowData[@"BeginTime"];
    NSDate *dtBeginTime = [CommonController dateFromString:strBeginTime];
    strBeginTime = [CommonController stringFromDate:dtBeginTime formatType:@"MM-dd HH:mm"];
    NSString *strWeek = [CommonController getWeek:dtBeginTime];
    
    UILabel *lbBeginTime = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 220, 20)];
    [lbBeginTime setFont:[UIFont systemFontOfSize:12]];
    [lbBeginTime setTextColor:[UIColor grayColor]];
    [lbBeginTime setText:[NSString stringWithFormat:@"举办时间：%@-%@ %@",strBeginTime,[CommonController stringFromDate:[CommonController dateFromString:rowData[@"EndTime"]] formatType:@"HH:mm"],strWeek]];
    [cell.contentView addSubview:lbBeginTime];
    [lbBeginTime release];
    
    //举办学校
    UILabel *lbSchool = [[UILabel alloc] initWithFrame:CGRectMake(10, 55, 220, 20)];
    [lbSchool setFont:[UIFont systemFontOfSize:12]];
    [lbSchool setTextColor:[UIColor grayColor]];
    [lbSchool setText:[NSString stringWithFormat:@"%@[%@]",rowData[@"RegionName"],rowData[@"SchoolName"]]];
    [cell.contentView addSubview:lbSchool];
    [lbSchool release];
    
    //举办地点
    UILabel *lbPlace = [[UILabel alloc] initWithFrame:CGRectMake(10, 75, 220, 20)];
    [lbPlace setFont:[UIFont systemFontOfSize:12]];
    [lbPlace setTextColor:[UIColor grayColor]];
    [lbPlace setText:[NSString stringWithFormat:@"%@",rowData[@"Address"]]];
    [cell.contentView addSubview:lbPlace];
    [lbPlace release];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",[self.campusListData objectAtIndex:indexPath.row][@"id"]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    [_collectView release];
    [_campusListData release];
    [_regionId release];
    [_schoolId release];
    [_runningRequest release];
    [_dictionaryPicker release];
    [_collectView release];
    [loadView release];
    [super dealloc];
}
@end
