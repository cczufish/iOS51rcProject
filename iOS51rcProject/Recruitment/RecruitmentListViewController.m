#import "RecruitmentListViewController.h"
#import "NetWebServiceRequest.h"
#import "CommonController.h"
#import "MJRefresh.h"
#import "DictionaryPickerView.h"
#import "Toast+UIView.h"
#import "RecruitmentViewController.h"
#import "SlideNavigationController.h"
#import "MyRecruitmentViewController.h"
#import "LoginViewController.h"
#import "RmSearchJobForInviteViewController.h"
#import <objc/runtime.h> 

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
@property (nonatomic, retain) NetWebServiceRequest *runningRequestJoinRm;//预约
@property (strong, nonatomic) DictionaryPickerView *DictionaryPicker;
@property (nonatomic, retain) AttendRMPopUp *cPopup;
@property (nonatomic, retain) DatePickerView *pickDate;

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
    [self.pickDate canclDatePicker];
    [self.DictionaryPicker cancelPicker];
    self.DictionaryPicker.delegate = nil;
    self.DictionaryPicker = nil;
    [_DictionaryPicker release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //右侧导航按钮
    UIButton *myRmBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 90, 30)];
    //myRmBtn.titleLabel.text = @"我的招聘会";//这样无法赋值
    [myRmBtn setTitle: @"我的招聘会" forState: UIControlStateNormal];
    myRmBtn.titleLabel.textColor = [UIColor whiteColor];
    myRmBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    myRmBtn.layer.cornerRadius = 5;
    myRmBtn.layer.backgroundColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1].CGColor;
    myRmBtn.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    myRmBtn.layer.borderWidth = 0.3;
    [myRmBtn addTarget:self action:@selector(btnMyRecruitmentClick:) forControlEvents:UIControlEventTouchUpInside];
    //我的招聘会
    UIBarButtonItem *btnMyRecruitment = [[UIBarButtonItem alloc] initWithCustomView:myRmBtn];
    self.navigationItem.rightBarButtonItem=btnMyRecruitment;
    
    [myRmBtn release];
    [btnMyRecruitment release];
    
    self.recruitmentData = [NSMutableArray arrayWithCapacity:10];
    self.placeData = [NSMutableArray arrayWithCapacity:10];
    //添加检索边框
    self.btnDateSet.layer.masksToBounds = YES;
    self.btnDateSet.layer.borderWidth = 1.0;
    self.btnDateSet.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    
    self.btnProvinceSel.layer.masksToBounds = YES;
    self.btnProvinceSel.layer.borderWidth = 1.0;
    self.btnProvinceSel.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    
    self.btnPlaceSel.layer.masksToBounds = YES;
    self.btnPlaceSel.layer.borderWidth = 1.0;
    self.btnPlaceSel.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    
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
    self.begindate = @"";
    self.page = 1;
    self.placeid = @"";
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    self.regionid = [userDefault objectForKey:@"subSiteId"];
    self.lbProvince.text = [userDefault objectForKey:@"subSiteCity"];
    [self onSearch];
    
    //场馆初始化
    [self reloadPlace];
}

-(void) btnMyRecruitmentClick:(UIButton *)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
     if ([userDefaults objectForKey:@"UserID"]) {
         MyRecruitmentViewController *myRmCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MyRecruitmentView"];
         myRmCtrl.navigationItem.title = @"我的招聘会";
         [self.navigationController pushViewController:myRmCtrl animated:YES];        
     }else{
         UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
         LoginViewController *loginC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginView"];
         [self.navigationController pushViewController:loginC animated:true];
     }   
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:true];
    
}

- (void)onSearch
{
    if (self.page == 1) {
        [self.recruitmentData removeAllObjects];
        [self.tvRecruitmentList reloadData];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([CommonController isLogin]) {
        [dicParam setObject:[userDefault objectForKey:@"UserID"] forKey:@"paMainID"];
        [dicParam setObject:self.begindate forKey:@"strBeginDate"];
        [dicParam setObject:self.placeid forKey:@"strPlaceID"];
        [dicParam setObject:self.regionid forKey:@"strRegionID"];
        [dicParam setObject:[NSString stringWithFormat:@"%d",self.page] forKey:@"page"];
        [dicParam setObject:[userDefault objectForKey:@"code"] forKey:@"code"];
    }
    else {
        [dicParam setObject:@"0" forKey:@"paMainID"];
        [dicParam setObject:self.begindate forKey:@"strBeginDate"];
        [dicParam setObject:self.placeid forKey:@"strPlaceID"];
        [dicParam setObject:self.regionid forKey:@"strRegionID"];
        [dicParam setObject:[NSString stringWithFormat:@"%d",self.page] forKey:@"page"];
        [dicParam setObject:@"0" forKey:@"code"];
    }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell =
        [[[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:@"rmList"] autorelease];
    
    NSDictionary *rowData = self.recruitmentData[indexPath.row];
    
    //初始化对象，用以选择时使用
    RM *rmInfo = [[[RM alloc] init] autorelease];
    rmInfo.ID = rowData[@"ID"];
    rmInfo.Name = rowData[@"RecruitmentName"];
    rmInfo.Address = rowData[@"Address"];
    rmInfo.Place = rowData[@"PlaceName"];
    rmInfo.BeginDate = rowData[@"BeginDate"];   
    
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
    lbBegin.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:(lbBegin)];
    [lbBegin release];
    
    CGSize placeSize = [CommonController CalculateFrame:[NSString stringWithFormat:@"举办场馆：%@",rowData[@"PlaceName"]] fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(3000, 15)];
    
    UILabel *lbPlace = [[UILabel alloc] initWithFrame:CGRectMake(20, (labelSize.height + 35),  MIN(placeSize.width, titleWidth-20) , 15)];
    lbPlace.text = [NSString stringWithFormat:@"举办场馆：%@",rowData[@"PlaceName"]];
    lbPlace.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:(lbPlace)];
    [lbPlace release];
    
    UIImageView *imgPlace = [[UIImageView alloc] initWithFrame:CGRectMake((lbPlace.frame.origin.x + lbPlace.frame.size.width + 2), (labelSize.height + 35), 12, 15)];
    [imgPlace setImage:[UIImage imageNamed:@"ico_cpinfo_cpaddress.png"]];
    [cell.contentView addSubview:(imgPlace)];
    [imgPlace release];
    
    UILabel *lbAddress = [[UILabel alloc] initWithFrame:CGRectMake(20, (labelSize.height + 55), titleWidth, 15)];
    lbAddress.text = [NSString stringWithFormat:@"具体地址：%@",rowData[@"Address"]];
    lbAddress.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:(lbAddress)];
    [lbAddress release];

    UILabel *lbSeparator = [[UILabel alloc] initWithFrame:CGRectMake(0, 119, 320, 1)];
    lbSeparator.backgroundColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1];
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
        if (!rowData[@"orderTime"]) {
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
            //传值
            objc_setAssociatedObject(rightButton, @"RM", rmInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [rightButton addTarget:self action:@selector(joinRecruitment:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:rightButton];
            [rightButton release];
            [lbWillRun release];
            [imgWillRun release];
        }
        else {
            UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 35, 30, 45)];
            UILabel *lbWillRun = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 40, 15)];
            lbWillRun.text = @"已预约";
            lbWillRun.font = [UIFont systemFontOfSize:12];
            lbWillRun.textAlignment = NSTextAlignmentCenter;
            [rightButton addSubview:lbWillRun];
            [cell.contentView addSubview:rightButton];
            [lbWillRun release];
            [rightButton release];
        }        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RecruitmentViewController *detailC = (RecruitmentViewController*)[self.storyboard
                                                                      instantiateViewControllerWithIdentifier: @"RecruitmentView"];
    detailC.recruitmentID = self.recruitmentData[indexPath.row][@"ID"];
    [self.navigationController pushViewController:detailC animated:true];
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:false];
}

//点击我要参会
-(void) joinRecruitment:(UIButton *)sender{
    if ([CommonController isLogin]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *code = [userDefaults objectForKey:@"code"];
        NSString *userID = [userDefaults objectForKey:@"UserID"];
        
        RM *rmInfo = objc_getAssociatedObject(sender, @"RM");
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setObject:rmInfo.ID forKey:@"RmID"];
        [dicParam setObject:userID forKey:@"paMainID"];
        [dicParam setObject:code forKey:@"code"];
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"AddPaRmAppointment" Params:dicParam];
        [request setDelegate:self];
        [request startAsynchronous];
        request.tag = 2;
        self.runningRequestJoinRm = request;
        loadView = [[[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self] autorelease];
        [loadView startAnimating];
        [dicParam release];
        //选择的招聘会
        selectedRM = rmInfo;

    }else{
        //转到登录界面
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        LoginViewController *loginC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginView"];
        [self.navigationController pushViewController:loginC animated:true];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.recruitmentData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}

- (void)footerRereshing{
    self.page++;
    [self onSearch];
}

//成功
- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSMutableArray *)requestData
{
    if (request.tag == 1) {
        if(self.page == 1){
            [self.recruitmentData removeAllObjects];
            self.recruitmentData = requestData;
        }
        else{
            [self.recruitmentData addObjectsFromArray:requestData];
        }
        [self.tvRecruitmentList reloadData];
        [self.tvRecruitmentList footerEndRefreshing];
    }else if(request.tag == 2){
        //刷新页面
        [self onSearch];
        self.cPopup = [[[AttendRMPopUp alloc] initPopup] autorelease];
        [self.cPopup setDelegate:self];
        [self.cPopup showPopup:self.view];
    }else {
        NSMutableArray *arrPlace = [[NSMutableArray alloc] init];
        for (int i = 0; i < requestData.count; i++) {
            NSDictionary *dicPlace = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                        requestData[i][@"id"],@"id",
                                        requestData[i][@"PlaceName"],@"value"
                                        ,nil] autorelease];
            [arrPlace addObject:dicPlace];
        }
        self.placeData = arrPlace;
        [arrPlace release];
    }
    //结束等待动画
    [loadView stopAnimating];
}

//预约成功，打开搜索、申请、收藏界面
-(void) attendRM{
    RmSearchJobForInviteViewController *searchView = [self.storyboard instantiateViewControllerWithIdentifier:@"RmSearchJobForInviteView"];
    NSString *strBeginDate = selectedRM.BeginDate;
    NSDate *tmpDtBeginDate = [CommonController dateFromString:strBeginDate];
    
    NSString *strTime = [NSString stringWithFormat:@"%@",[CommonController stringFromDate:tmpDtBeginDate formatType:@"yyyy-MM-dd HH:mm"]];
    searchView.strBeginTime = strTime;
    searchView.strAddress = selectedRM.Address;
    searchView.strPlace = selectedRM.Place;
    searchView.rmID = selectedRM.ID;
    [self.navigationController pushViewController:searchView animated:YES];
}

- (void)dealloc {
    [_recruitmentData release];
    [_placeData release];
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
    [_runningRequestJoinRm release];
    [_begindate release];
    [_placeid release];
    [_regionid release];
    [super dealloc];
}

-(void)showDateSelect{
    [self cancelDicPicker];
    self.pickDate = [[DatePickerView alloc] initWithCustom:DatePickerTypeDay dateButton:DatePickerWithReset maxYear:2016 minYear:2000 selectYear:0 delegate:self];
    [self.pickDate showDatePicker:self.view];
}

- (void)getSelectDate:(NSString *)date
{
    self.lbDateSet.text = [date substringFromIndex:5];
    self.begindate = date;
    self.page = 1;
    [self onSearch];
    //开始等待动画
    [loadView startAnimating];
    //加载场馆
    [self reloadPlace];
}

- (void)cancelPickDate
{
    self.lbDateSet.text = @"日期";
    self.begindate = @"";
    self.page = 1;
    [self onSearch];
    //开始等待动画
    [loadView startAnimating];
}

-(void)showRegionSelect {
    [self cancelDicPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCustom:DictionaryPickerWithRegionL2 pickerMode:DictionaryPickerModeOne pickerInclude:DictionaryPickerIncludeParent delegate:self defaultValue:self.regionid defaultName:self.lbProvince.text] autorelease];

    self.DictionaryPicker.tag = 1;
    [self.DictionaryPicker showInView:self.view];
}

- (void)showPlaceSelect {
    if ([self.placeData count] == 0) {
        [self.view makeToast:@"没有该地区的场馆信息"];
        return;
    }
    [self cancelDicPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithDictionary:self defaultArray:self.placeData defaultValue:self.placeid defaultName:@"" pickerMode:DictionaryPickerModeOne] autorelease];
    self.DictionaryPicker.tag = 2;
    [self.DictionaryPicker showInView:self.view];
}

- (void)pickerDidChangeStatus:(DictionaryPickerView *)picker
                  selectedValue:(NSString *)selectedValue
                   selectedName:(NSString *)selectedName {
    [self cancelDicPicker];
    if (picker.tag == 1) { //地区选择
        self.regionid = selectedValue;
        self.placeid = @"";
        [self.lbPlace setText:@"全部场馆"];
        [self.lbProvince setText:selectedName];
        //加载场馆
        [self reloadPlace];
    }
    else { //场馆选择
        self.placeid = selectedValue;
        [self.lbPlace setText:selectedName];
    }
    //重新加载列表
    self.page = 1;
    [self onSearch];
    //开始等待动画
    [loadView startAnimating];
}

- (void)reloadPlace {
    //加载场馆
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.begindate forKey:@"strBeginDate"];
    [dicParam setObject:self.regionid forKey:@"RegionID"];
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
