#import "CpJobsViewController.h"
#import "CommonController.h"

//公司职位列表页面
@interface CpJobsViewController ()<NetWebServiceRequestDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tvCpJobList;
@property (retain, nonatomic) IBOutlet UIButton *btnApply;
@property (retain, nonatomic) IBOutlet UIView *ViewBottom;
@end

@implementation CpJobsViewController
//@synthesize delegate;
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
    if (self.frameHeight == 0) {
        self.frameHeight = 496;
    }
    self.btnApply.layer.cornerRadius = 5;
    //根据外部传来的高度设置本页面的高度
    self.view.frame = CGRectMake(0, 0, 320, self.frameHeight);
    //设置下方View的位置
    self.ViewBottom.frame = CGRectMake(0, self.frameHeight-50, 320, 50);
    
    //数据加载等待控件初始化
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //[self onSearch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];  
}
- (void)onSearch
{
    [jobListData removeAllObjects];
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
    [jobListData removeAllObjects];
    jobListData = requestData;
    
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
    NSDictionary *rowData = jobListData[indexPath.row];
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [jobListData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)footerRereshing{
    page++;
    [self onSearch];
}


- (void)dealloc {
    [_tvCpJobList release];
    [_ViewBottom release];
    [_btnApply release];
    [super dealloc];
}
@end
