#import "RmCpJobListViewController.h"
#import "NetWebServiceRequest.h"
#import "CommonController.h"

@interface RmCpJobListViewController ()<NetWebServiceRequestDelegate>
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) IBOutlet UITableView *tvCpJobList;

@end

@implementation RmCpJobListViewController
@synthesize delegate;
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
    UIBarButtonItem *btnMyRecruitment = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(btnMyRecruitmentClick:)];
    btnMyRecruitment.title = @"我的招聘会";
    self.navigationItem.rightBarButtonItem=btnMyRecruitment;
    
    //数据加载等待控件初始化
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    [self onSearch];
}

-(void) addNavigationBar{
    
}

-(void) btnMyRecruitmentClick:(UIBarButtonItem *)sender
{
    //MyRecruitmentViewController *myRmCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MyRecruitmentView"];
    //[self.navigationController pushViewController:myRmCtrl animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)onSearch
{
    [JobListData removeAllObjects];
    [self.tvCpJobList reloadData];
    
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.cpMainID forKey:@"cpMainID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetJobList" Params:dicParam];
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
    [JobListData removeAllObjects];
    JobListData = requestData;
    
    [self.tvCpJobList reloadData];
    //[self.tvCpJobList footerEndRefreshing];
    
    //结束等待动画
    [loadView stopAnimating];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat titleWidth = 235;
    CGSize titleSize = CGSizeMake(titleWidth, 5000.0f);
    
    UITableViewCell *cell =
    [[[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"paList"] autorelease];
    NSDictionary *rowData = JobListData[indexPath.row];
    //职位名称
    NSString *strJobName = rowData[@"Name"];
    UIFont *titleFont = [UIFont systemFontOfSize:12];
    CGSize labelSize = [CommonController CalculateFrame:strJobName fontDemond:titleFont sizeDemand:titleSize];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 200, labelSize.height)];
    lbTitle.text = strJobName;
    lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
    lbTitle.numberOfLines = 0;
    lbTitle.font = titleFont;
    [cell.contentView addSubview:(lbTitle)];
    [lbTitle release];
    //时间
    NSString *strefreshDate = rowData[@"RefreshDate"];
    NSDate *dtefreshDate = [CommonController dateFromString:strefreshDate];
    strefreshDate = [CommonController stringFromDate:dtefreshDate formatType:@"MM-dd HH:mm"];
    UILabel *lbeRfreshDate = [[UILabel alloc] initWithFrame:CGRectMake(220, lbTitle.frame.origin.y, 80, labelSize.height)];
    lbeRfreshDate.text = strefreshDate;
    lbeRfreshDate.textAlignment = NSTextAlignmentRight;
    lbeRfreshDate.font = [UIFont systemFontOfSize:12];
    lbeRfreshDate.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbeRfreshDate)];
    [lbeRfreshDate release];
    //地区
    NSString *strAge = rowData[@"Region"];
    //学历
    NSString *strDegree = [CommonController getDictionaryDesc:rowData[@"dcEducationID"] tableName:@"dcEducation"];
    //[CommonController getDictionary:rowData[@"dcEducationID"]];
    NSString *strInfo = [NSString stringWithFormat:@"%@|%@", strAge, strDegree];
    UILabel *lbInfo = [[UILabel alloc] initWithFrame:CGRectMake(20, lbTitle.frame.origin.y+lbTitle.frame.size.height + 5, 200, labelSize.height)];
    lbInfo.text = strInfo;
    lbInfo.font = [UIFont systemFontOfSize:12];
    lbInfo.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbInfo)];
    [lbInfo release];    
    //工资
    NSString *strdcSalaryID = rowData[@"dcSalaryID"];
    UILabel *lbSalary = [[UILabel alloc] initWithFrame:CGRectMake(220, lbTitle.frame.origin.y+lbTitle.frame.size.height + 5, 80, labelSize.height)];
    lbSalary.text = [CommonController getDictionaryDesc:strdcSalaryID tableName:@"dcSalary"];
    //[CommonController GetSalary:strdcSalaryID];
    lbSalary.font = [UIFont systemFontOfSize:12];
    lbSalary.textAlignment = NSTextAlignmentRight;
    lbSalary.textColor = [UIColor redColor];
    [cell.contentView addSubview:(lbSalary)];
    [lbSalary release];
    
    return cell;
}

//点击某一行,选择一个职位
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //NSArray *arr = JobListData[indexPath.row];
    NSString *cpMainID = JobListData[indexPath.row][@"cpMainID"];
    NSString *jobID = JobListData[indexPath.row][@"ID"];
    NSString *name = JobListData[indexPath.row][@"Name"];
    [cpMainID retain];
    [jobID retain];
    [name retain];
    [delegate SetJob:cpMainID jobID:jobID JobName:name];
    [self dismissViewControllerAnimated:YES completion:nil];    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [JobListData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

//- (void)footerRereshing{
//    page++;
//    [self onSearch];
//}


- (void)dealloc {
    [_tvCpJobList release];
    [super dealloc];
}
@end
