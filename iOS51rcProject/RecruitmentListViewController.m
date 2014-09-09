#import "RecruitmentListViewController.h"
#import "NetWebServiceRequest.h"
#import "CommonController.h"
#import "MJRefresh.h"
#import "DictionaryPickerView.h"
#import "Toast+UIView.h"
#import "RecruitmentViewController.h"
#import "SlideNavigationController.h"
#import "MyRecruitmentViewController.h"

@interface RecruitmentListViewController ()<NetWebServiceRequestDelegate,DatePickerDelegate,DictionaryPickerDelegate,SlideNavigationControllerDelegate>
@property (retain, nonatomic) IBOutlet UITableView *tvRecruitmentList;
@property (retain, nonatomic) IBOutlet UIButton *btnProvinceSel;
@property (retain, nonatomic) IBOutlet UIButton *btnPlaceSel;
@property (retain, nonatomic) IBOutlet UILabel *lbPlace;
@property (retain, nonatomic) IBOutlet UILabel *lbDateSet;
@property (retain, nonatomic) IBOutlet UILabel *lbProvince;
@property (retain, nonatomic) IBOutlet UIButton *btnDateSet;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest2;
@property (strong, nonatomic) DictionaryPickerView *DictionaryPicker;
-(void)cancelDicPicker;
@end

@implementation RecruitmentListViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)cancelDicPicker
{
    [self.DictionaryPicker cancelPicker];
    self.DictionaryPicker.delegate = nil;
    self.DictionaryPicker = nil;
    [_DictionaryPicker release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //右侧导航按钮
    UIButton *myRmBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 22)];
    //myRmBtn.titleLabel.text = @"我的招聘会";//这样无法赋值
    [myRmBtn setTitle: @"我的招聘会" forState: UIControlStateNormal];
    myRmBtn.titleLabel.textColor = [UIColor whiteColor];
    myRmBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    myRmBtn.layer.cornerRadius = 5;
    myRmBtn.layer.backgroundColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1].CGColor;
    [myRmBtn addTarget:self action:@selector(btnMyRecruitmentClick:) forControlEvents:UIControlEventTouchUpInside];
    //我的招聘会
    UIBarButtonItem *btnMyRecruitment = [[UIBarButtonItem alloc] initWithCustomView:myRmBtn];
    self.navigationItem.rightBarButtonItem=btnMyRecruitment;
    
    [myRmBtn release];
    [btnMyRecruitment release];
    
    recruitmentData = [[NSMutableArray alloc] init];
    placeData = [[NSMutableArray alloc] init];
    //添加检索边框
    self.btnDateSet.layer.masksToBounds = YES;
    self.btnDateSet.layer.borderWidth = 1.0;
    self.btnDateSet.layer.borderColor = [[UIColor grayColor] CGColor];
    
    self.btnProvinceSel.layer.masksToBounds = YES;
    self.btnProvinceSel.layer.borderWidth = 1.0;
    self.btnProvinceSel.layer.borderColor = [[UIColor grayColor] CGColor];
    
    self.btnPlaceSel.layer.masksToBounds = YES;
    self.btnPlaceSel.layer.borderWidth = 1.0;
    self.btnPlaceSel.layer.borderColor = [[UIColor grayColor] CGColor];
    
    //时间选择控件
    pickDate = [[DatePicker alloc] init];
    pickDate.delegate = self;
    [self.btnDateSet addTarget:self action:@selector(showDateSelect) forControlEvents:UIControlEventTouchUpInside];
    [self.btnProvinceSel addTarget:self action:@selector(showRegionSelect) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPlaceSel addTarget:self action:@selector(showPlaceSelect) forControlEvents:UIControlEventTouchUpInside];
    //数据加载等待控件初始化
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //开始等待动画
    [loadView startAnimating];
    
    //添加上拉加载更多
    [self.tvRecruitmentList addFooterWithTarget:self action:@selector(footerRereshing)];
    //不显示列表分隔线
    self.tvRecruitmentList.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //搜索初始化
    begindate = @"";
    page = 1;
    placeid = @"";
    regionid = @"32";
    [self onSearch];
    
    //场馆初始化
    [self reloadPlace];
}

-(void) btnMyRecruitmentClick:(UIButton *)sender
{
    MyRecruitmentViewController *myRmCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MyRecruitmentView"];
    [self.navigationController pushViewController:myRmCtrl animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];
    
}

- (void)onSearch
{
    if (page == 1) {
        [recruitmentData removeAllObjects];
        [self.tvRecruitmentList reloadData];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:@"0" forKey:@"paMainID"];
    [dicParam setObject:begindate forKey:@"strBeginDate"];
    [dicParam setObject:placeid forKey:@"strPlaceID"];
    [dicParam setObject:regionid forKey:@"strRegionID"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",page] forKey:@"page"];
    [dicParam setObject:@"0" forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetRecruitMentList" Params:dicParam];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell =
        [[[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"rmList"] autorelease];
    
    NSDictionary *rowData = recruitmentData[indexPath.row];
    //显示标题
    NSString *strRecruitmentName = rowData[@"RecruitmentName"];
    UIFont *titleFont = [UIFont systemFontOfSize:15];
    CGFloat titleWidth = 235;
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
    [cell.contentView addSubview:(lbBegin)];
    [lbBegin release];
    
    UILabel *lbPlace = [[UILabel alloc] initWithFrame:CGRectMake(20, (labelSize.height + 35), titleWidth, 15)];
    lbPlace.text = [NSString stringWithFormat:@"举办场馆：%@",rowData[@"PlaceName"]];
    lbPlace.font = [UIFont systemFontOfSize:12];
    [cell.contentView addSubview:(lbPlace)];
    [lbPlace release];
    
    UILabel *lbAddress = [[UILabel alloc] initWithFrame:CGRectMake(20, (labelSize.height + 55), titleWidth, 15)];
    lbAddress.text = [NSString stringWithFormat:@"举办场馆：%@",rowData[@"Address"]];
    lbAddress.font = [UIFont systemFontOfSize:12];
    [cell.contentView addSubview:(lbAddress)];
    [lbAddress release];

    UILabel *lbSeparator = [[UILabel alloc] initWithFrame:CGRectMake(0, 119, 320, 1)];
    lbSeparator.backgroundColor = [UIColor grayColor];
    [cell.contentView addSubview:(lbSeparator)];
    [lbSeparator release];

    //显示状态
    int runStatus = 0;
    NSDate *dtEndDate = [CommonController dateFromString:rowData[@"EndDate"]];
    NSDate *dtNow = [NSDate date];
    NSDate *dtCompare = [dtBeginDate earlierDate:dtNow];
    if (dtNow == dtCompare) {
        runStatus = 3; //未开始
    }
    else{
        dtCompare = [dtEndDate earlierDate:dtNow];
        if(dtNow == dtCompare){
            runStatus = 1; //正在进行
        }
        else{
            runStatus = 2; //已过期
        }
    }
    if (runStatus == 1) {
        UIView *rightContent = [[UIView alloc] initWithFrame:CGRectMake(260, 35, 30, 45)];
        UILabel *lbRunning = [[UILabel alloc] initWithFrame:CGRectMake(0, 35, 30, 10)];
        lbRunning.text = @"进行中";
        lbRunning.font = [UIFont systemFontOfSize:10];
        lbRunning.textColor = [UIColor colorWithRed:107.f/255.f green:217.f/255.f blue:70.f/255.f alpha:1];
        lbRunning.textAlignment = NSTextAlignmentCenter;
        [rightContent addSubview:lbRunning];
        
        UIImageView *imgRunning = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        imgRunning.image = [UIImage imageNamed:@"ico_clock.png"];
        
        [rightContent addSubview:imgRunning];
        [cell.contentView addSubview:rightContent];
        [rightContent release];
        [lbRunning release];
        [imgRunning release];
    }
    else if (runStatus == 2){
        UIImageView *imgExpired = [[UIImageView alloc] initWithFrame:CGRectMake(280, 0, 40, 40)];
        imgExpired.image = [UIImage imageNamed:@"ico_expire.png"];
        [cell.contentView addSubview:imgExpired];
        [imgExpired release];
    }
    else if (runStatus == 3){
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 35, 30, 45)];
        UILabel *lbWillRun = [[UILabel alloc] initWithFrame:CGRectMake(-5, 35, 40, 10)];
        lbWillRun.text = @"我要参会";
        lbWillRun.font = [UIFont systemFontOfSize:10];
        lbWillRun.textColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:40.f/255.f alpha:1];
        lbWillRun.textAlignment = NSTextAlignmentCenter;
        [rightButton addSubview:lbWillRun];
        
        UIImageView *imgWillRun = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        imgWillRun.image = [UIImage imageNamed:@"ico_rm_group.png"];
        rightButton.tag = (NSInteger)rowData[@"ID"];
        [rightButton addSubview:imgWillRun];
        [rightButton addTarget:self action:@selector(joinRecruitment:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:rightButton];
        [rightButton release];
        [lbWillRun release];
        [imgWillRun release];
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    RecruitmentViewController *detailC = (RecruitmentViewController*)[self.storyboard
                                                                      instantiateViewControllerWithIdentifier: @"RecruitmentView"];
    detailC.recruitmentID = recruitmentData[indexPath.row][@"ID"];
    [self.navigationController pushViewController:detailC animated:true];
}

-(void) joinRecruitment:(UIButton *)sender{
    NSLog(@"点击我要参会：%d",sender.tag);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [recruitmentData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
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
            [recruitmentData removeAllObjects];
            recruitmentData = requestData;
        }
        else{
            [recruitmentData addObjectsFromArray:requestData];
        }
        [self.tvRecruitmentList reloadData];
        [self.tvRecruitmentList footerEndRefreshing];
        
        //结束等待动画
        [loadView stopAnimating];
    }
    else {
        NSMutableArray *arrPlace = [[NSMutableArray alloc] init];
        for (int i = 0; i < requestData.count; i++) {
            NSDictionary *dicPlace = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                        requestData[i][@"id"],@"id",
                                        requestData[i][@"PlaceName"],@"value"
                                        ,nil] autorelease];
            [arrPlace addObject:dicPlace];
        }
        placeData = arrPlace;
    }
}

- (void)dealloc {
    [recruitmentData release];
    [placeData release];
    [pickDate release];
    [loadView release];
    [_tvRecruitmentList release];
    [_btnDateSet release];
    [_btnProvinceSel release];
    [_btnPlaceSel release];
    [_lbDateSet release];
    [_lbProvince release];
    [_lbPlace release];
    [_runningRequest release];
    [_runningRequest2 release];
    [super dealloc];
}

-(void)showDateSelect{
    [pickDate showDatePicker:self dateTitle:@"请选择举办日期"];
}

-(void)saveDate:(NSDate *)selectDate{
    NSString *strSelDate = [CommonController stringFromDate:selectDate formatType:@"MM-dd"];
    self.lbDateSet.text = strSelDate;
    begindate = [CommonController stringFromDate:selectDate formatType:@"yyyy-MM-dd"];
    page = 1;
    [self onSearch];
    [pickDate removeDatePicker];
    //开始等待动画
    [loadView startAnimating];
}

-(void)resetDate{
    self.lbDateSet.text = @"日期";
    begindate = @"";
    page = 1;
    [self onSearch];
    [pickDate removeDatePicker];
    //开始等待动画
    [loadView startAnimating];
}

-(void)showRegionSelect {
    [self cancelDicPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCustom:DictionaryPickerWithRegionL2 pickerMode:DictionaryPickerModeOne pickerInclude:DictionaryPickerIncludeParent delegate:self defaultValue:regionid defaultName:@"山东省"] autorelease];

    self.DictionaryPicker.tag = 1;
    [self.DictionaryPicker showInView:self.view];
}

- (void)showPlaceSelect {
    if ([placeData count] == 0) {
        [self.view makeToast:@"没有该地区的场馆信息"];
        return;
    }
    [self cancelDicPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithDictionary:self defaultArray:placeData defalutValue:placeid defalutName:@"" pickerMode:DictionaryPickerModeOne] autorelease];
    self.DictionaryPicker.tag = 2;
    [self.DictionaryPicker showInView:self.view];
}

- (void)pickerDidChangeStatus:(DictionaryPickerView *)picker
                  selectedValue:(NSString *)selectedValue
                   selectedName:(NSString *)selectedName {
    [self cancelDicPicker];
    if (picker.tag == 1) { //地区选择
        regionid = selectedValue;
        placeid = @"";
        [self.lbPlace setText:@"全部场馆"];
        [self.lbProvince setText:selectedName];
        //加载场馆
        [self reloadPlace];
    }
    else { //场馆选择
        placeid = selectedValue;
        [self.lbPlace setText:selectedName];
    }
    //重新加载列表
    page = 1;
    [self onSearch];
    //开始等待动画
    [loadView startAnimating];
}

- (void)reloadPlace {
    //加载场馆
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:begindate forKey:@"strBeginDate"];
    [dicParam setObject:regionid forKey:@"RegionID"];
    [dicParam setObject:@"1" forKey:@"isDistinct"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetPlaceListByBeginDate" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest2 = request;
    [dicParam release];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (int)slideMenuItem
{
    return 5;
}

@end
