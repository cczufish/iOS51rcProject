#import "RmCpJobListViewController.h"
#import "NetWebServiceRequest.h"
#import "CommonController.h"
#import "RmCpMain.h"
#import "RmInviteCpViewController.h"

@interface RmCpJobListViewController ()<NetWebServiceRequestDelegate>
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NSMutableArray *jobListData;
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
    //数据加载等待控件初始化
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    [self onSearch];
}

-(void) addNavigationBar{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onSearch
{
    [self.jobListData removeAllObjects];
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
    [self.jobListData removeAllObjects];
    self.jobListData = requestData;
    
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
    NSDictionary *rowData = self.jobListData[indexPath.row];
    //职位名称
    NSString *strJobName = rowData[@"Name"];
    UIFont *titleFont = [UIFont systemFontOfSize:14];
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
    lbeRfreshDate.font = [UIFont systemFontOfSize:14];
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
    lbInfo.font = [UIFont systemFontOfSize:14];
    lbInfo.textColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbInfo)];
    [lbInfo release];    
    //工资
    NSString *strdcSalaryID = rowData[@"dcSalaryID"];
    UILabel *lbSalary = [[UILabel alloc] initWithFrame:CGRectMake(220, lbTitle.frame.origin.y+lbTitle.frame.size.height + 5, 80, labelSize.height)];
    lbSalary.text = [CommonController getDictionaryDesc:strdcSalaryID tableName:@"dcSalary"];
    if ([strdcSalaryID isEqualToString:@"100"]) {
        lbSalary.text = @"面议";
    }
    
    lbSalary.font = [UIFont systemFontOfSize:14];
    lbSalary.textAlignment = NSTextAlignmentRight;
    lbSalary.textColor = [UIColor redColor];
    [cell.contentView addSubview:(lbSalary)];
    [lbSalary release];
    
    return cell;
}

//点击某一行,选择一个职位
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cpMainID = self.jobListData[indexPath.row][@"cpMainID"] ;
    NSString *jobID = self.jobListData[indexPath.row][@"ID"];
    NSString *name = self.jobListData[indexPath.row][@"Name"];
    [cpMainID retain];
    [jobID retain];
    [name retain];
    RmCpMain *tmpCp = [[RmCpMain alloc]init];
    tmpCp.CpID = cpMainID;
    tmpCp.jobID = jobID;
    tmpCp.Name = name;
    [tmpCp retain];
    
    RmInviteCpViewController *viewC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    viewC.returnedCp = tmpCp;
    viewC.returnType = 1;
    [self.navigationController popViewControllerAnimated:true];
    //[delegate SetJob:cpMainID jobID:jobID JobName:name];
    //[self dismissViewControllerAnimated:YES  completion:^(void){}];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.jobListData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)dealloc {
    [_jobListData release];
    [_tvCpJobList release];
    [super dealloc];
}
@end
