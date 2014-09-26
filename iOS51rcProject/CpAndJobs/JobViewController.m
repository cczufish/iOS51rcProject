#import "JobViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "MJRefresh.h"
#import "CustomPopup.h"
#import "Toast+UIView.h"
#import "LoginViewController.h"
#import "SuperJobMainViewController.h"
#import "MapViewController.h"
#import <objc/runtime.h>

@interface JobViewController ()<NetWebServiceRequestDelegate,UIScrollViewDelegate,CustomPopupDelegate>
@property (retain, nonatomic) IBOutlet UIScrollView *jobMainScroll;
@property (retain, nonatomic) IBOutlet UILabel *lbJobName;
@property (retain, nonatomic) IBOutlet UILabel *lbFereashTime;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) LoadingAnimationView *loading;
@property (retain, nonatomic) IBOutlet UIView *subView;
@property (nonatomic, retain) CustomPopup *cPopup;

@property (retain, nonatomic) IBOutlet UIView *ViewBottom;
@property (retain, nonatomic) IBOutlet UILabel *lbChat;
@property (retain, nonatomic) IBOutlet UIImageView *imgChat;
@end

@implementation JobViewController
#define HEIGHT [[UIScreen mainScreen] bounds].size.height
@synthesize runningRequest = _runningRequest;
@synthesize loading = _loading;
@synthesize JobID;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
}

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
    self.btnApply.layer.cornerRadius = 5;
    self.jobMainScroll.delegate = self;
 }

-(void) onSearch{
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.JobID forKey:@"JobID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetJobInfo" Params:dicParam];
    request.tag = 1;
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
    self.loading = [[[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self] autorelease];
    [dicParam release];
    [self.loading startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSMutableArray *)requestData
{
    //结束等待动画
    [self.loading stopAnimating];
    if (request.tag == 1) { //职位搜索
        if (requestData.count>0) {
            [self didReceiveJobMain:requestData];
        }        
    }
    else if (request.tag == 3) { //获取可投递的简历，默认投递第一份简历
        if (requestData.count == 0) {
            [self.view makeToast:@"您没有有效职位，请先完善您的简历"];
        }
        else {
            self.cPopup = [[[CustomPopup alloc] popupCvSelect:requestData] autorelease];
            [self.cPopup setDelegate:self];
            [self insertJobApply:requestData[0][@"ID"] isFirst:YES];
        }
    }
    else if (request.tag == 4) { //默认投递完之后，显示弹层
        [self.cPopup showJobApplyCvSelect:result view:self.view];
    }
    else if (request.tag == 5) { //重新申请职位成功
        [self.view makeToast:@"重新申请简历成功"];
    }
    else if (request.tag == 6) {
        [self.view makeToast:@"收藏职位成功"];
    }
    else if(request.tag == 9){//其他建议的职位
        [self didReceiveRecommendJob:requestData];
    }
    
    
}

//申请职位，插入数据库
- (void)insertJobApply:(NSString *)cvMainID
               isFirst:(BOOL)isFirst
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.JobID forKey:@"JobID"];
    [dicParam setObject:cvMainID forKey:@"cvMainID"];
    [dicParam setObject:[userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"InsertJobApply" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    if (isFirst) {
        request.tag = 4;
    }
    else {
        request.tag = 5;
    }
    self.runningRequest = request;
    [dicParam release];
}

//点击申请职位按钮
- (IBAction)btnJobApply:(id)sender {
    [self jobApply];
}

- (void)jobApply
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"UserID"]) {
        //连接数据库，读取有效简历
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setObject:[userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
        [dicParam setObject:[userDefaults objectForKey:@"code"] forKey:@"code"];
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCvListByApply" Params:dicParam];
        [request setDelegate:self];
        [request startAsynchronous];
        request.tag = 3;
        self.runningRequest = request;
        [dicParam release];
        [self.loading startAnimating];
    }
    else {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        LoginViewController *loginC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginView"];
        [self.navigationController pushViewController:loginC animated:true];
    }
}
//点击收藏按钮
- (IBAction)btnFavoriteClick:(id)sender {
    [self jobFavorite];
}

- (void)jobFavorite
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"UserID"]) {
        //连接数据库，读取有效简历
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setObject:[userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
        [dicParam setObject:self.JobID forKey:@"jobID"];
        [dicParam setObject:[userDefaults objectForKey:@"code"] forKey:@"code"];
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"InsertPaFavorate" Params:dicParam];
        [request setDelegate:self];
        [request startAsynchronous];
        request.tag = 6;
        self.runningRequest = request;
        [dicParam release];
        [self.loading startAnimating];
    }
    else {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        LoginViewController *loginC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginView"];
        [self.navigationController pushViewController:loginC animated:true];
    }
}

//点击留言按钮
- (IBAction)btnChatClick:(id)sender {
    NSLog(@"留言");
}

- (void) getPopupValue:(NSString *)value
{
    [self insertJobApply:value isFirst:NO];
}

//第一个消息完成了以后再调用第二个消息(绑定其他职位)
-(void) didReceiveRecommendJob:(NSMutableArray *) requestData{
    [self.recommentJobsData removeAllObjects];
    self.recommentJobsData = requestData;
    //浏览过的其他职位子View
    UIView *tmpView = [[[UIView alloc] initWithFrame:CGRectMake(30, tmpHeight, 280, requestData.count*27)] autorelease];
    for (int i=0; i<requestData.count; i++) {
        NSDictionary *rowData = requestData[i];
        UIButton *btnOther = [[[UIButton alloc] initWithFrame:CGRectMake(0, 27*i, 280, 20)] autorelease];
        [btnOther addTarget:self action:@selector(btnOtherJobClick:) forControlEvents:UIControlEventTouchUpInside];
        btnOther.tag = i;
        //职位名称
        UILabel *lbTitle = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 20)]autorelease];
        lbTitle.textColor = [UIColor blackColor];
        lbTitle.font = [UIFont systemFontOfSize:12];
        lbTitle.text = rowData[@"JobName"];
        //待遇
        UILabel *lbSalary = [[[UILabel alloc] initWithFrame:CGRectMake(180, 0, 80, 20)]autorelease];
        lbSalary.text = [CommonController getDictionaryDesc:rowData[@"dcSalaryID"] tableName:@"dcSalary"];
        if (lbSalary.text.length == 0) {
            lbSalary.text = @"面议";
        }
        lbSalary.textColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
        lbSalary.textAlignment = NSTextAlignmentRight;
        lbSalary.font = [UIFont systemFontOfSize:12];
        [btnOther addSubview:lbTitle];
        [btnOther addSubview:lbSalary];
        //分割线
        UILabel *lbLine = [[[UILabel alloc] initWithFrame:CGRectMake(0, 24 , 280, 1)] autorelease];
        lbLine.text = @"----------------------------------------------------------------------";
        lbLine.textColor = [UIColor lightGrayColor];
        [btnOther addSubview:lbLine];
        
        [tmpView addSubview:btnOther];
    }
    [self.subView addSubview:tmpView];
    self.subView.frame = CGRectMake(0, 0, 320, tmpView.frame.origin.y + tmpView.frame.size.height);
    int originY = tmpView.frame.origin.y;
    int originHeight = tmpView.frame.size.height;
    scrolHeight = originHeight + originY;
    [self.jobMainScroll setContentSize:CGSizeMake(320, scrolHeight) ];
    self.ViewBottom.frame = CGRectMake(0, HEIGHT - 170, 320, 50);
    self.jobMainScroll.frame = CGRectMake(0, 0, 320, HEIGHT - 170);
}

//点击其他企业
-(void) btnOtherJobClick:(UIButton *) sender{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"CpAndJob" bundle:nil];
    SuperJobMainViewController *jobC = [storyBoard instantiateViewControllerWithIdentifier:@"SuperJobMainView"];
    NSDictionary *tmpJob = self.recommentJobsData[sender.tag];
    jobC.JobID = tmpJob[@"ID"];
    jobC.cpMainID = tmpJob[@"cpMainID"];
    jobC.navigationItem.title = tmpJob[@"cpName"];
    UIViewController *pCtrl = [CommonController getFatherController:self.view];
    [pCtrl.navigationController pushViewController:jobC animated:YES];
}

//生成福利的小图片
-(void) CreateFuliView:(UIView *) view icoName:(NSString *) icoName title:(NSString *) title{
    //图片+label
    UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(1, 1, 13, 13)] autorelease];
    imgView.image = [UIImage imageNamed:icoName];
    CGSize labelSize = [CommonController CalculateFrame:title fontDemond:[UIFont systemFontOfSize:11] sizeDemand:CGSizeMake(self.lbJobName.frame.size.width, 500)];
    UILabel *lbView = [[[UILabel alloc] initWithFrame:CGRectMake(15, 0, labelSize.width, 15)] autorelease];
    lbView.text =title;
    lbView.font = [UIFont systemFontOfSize:10];
    lbView.textColor = [UIColor grayColor];
    view.frame = CGRectMake(0, 0, 15 + labelSize.width, 15);
    [view addSubview:imgView];
    [view addSubview:lbView];
}

//绑定职位信息
-(void) didReceiveJobMain:(NSArray *) requestData
{
    NSDictionary *dicJob = requestData[0];
    //职位名称
    NSString *jobName = dicJob[@"Name"];
    CGSize labelSize = [CommonController CalculateFrame:jobName fontDemond:[UIFont systemFontOfSize:16] sizeDemand:CGSizeMake(self.lbJobName.frame.size.width, 500)];
    self.lbJobName.frame = CGRectMake(self.lbJobName.frame.origin.x, self.lbJobName.frame.origin.y, self.lbJobName.frame.size.width, labelSize.height);
    self.lbJobName.lineBreakMode = NSLineBreakByCharWrapping;
    self.lbJobName.numberOfLines = 0;
    [self.lbJobName setText:jobName];
    //刷新时间
    self.lbFereashTime.textColor = [UIColor grayColor];
    self.lbFereashTime.frame = CGRectMake(20, self.lbJobName.frame.origin.y + self.lbJobName.frame.size.height + 10, 280, 15);
    NSDate *refreshDate = [CommonController dateFromString:dicJob[@"RefreshDate"]];
    NSString *strRefreshDate = [CommonController stringFromDate:refreshDate formatType:@"MM-dd HH:mm"];
    [self.lbFereashTime setText:[NSString stringWithFormat:@"刷新时间：%@", strRefreshDate]];
    //第一条横线
    UILabel *lbLine1 = [[UILabel alloc] initWithFrame:CGRectMake(0, self.lbFereashTime.frame.origin.y + self.lbFereashTime.frame.size.height + 10,320, 1)];
    lbLine1.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.subView addSubview:lbLine1];
    [lbLine1 release];

    //匹配度
    NSString *strMatch = dicJob[@"matchPercent"];
    if (strMatch != nil) {
        UILabel *lbMatch = [[UILabel alloc] initWithFrame:CGRectMake(270, self.lbJobName.frame.origin.y+5, 45, 20)];
        lbMatch.layer.cornerRadius = 5;
        [lbMatch setText:[NSString stringWithFormat:@"匹配度%@%%",strMatch]];
        [lbMatch setTextAlignment:NSTextAlignmentCenter];
        [lbMatch setTextColor:[UIColor whiteColor]];
        [lbMatch setFont:[UIFont systemFontOfSize:8]];
        [lbMatch setBackgroundColor:[UIColor colorWithRed:14.f/255.f green:170.f/255.f blue:32.f/255.f alpha:1]];
        [self.subView addSubview:lbMatch];
        [lbMatch release];
    }

    //待遇
    NSString *strSalary = dicJob[@"Salary"];
    UILabel *lbSalary = [[[UILabel alloc] initWithFrame:CGRectMake(20, lbLine1.frame.origin.y + lbLine1.frame.size.height+5, 280, 20) ]autorelease];
    lbSalary.text = strSalary;
    lbSalary.textColor = [UIColor redColor];
    [self.subView addSubview:lbSalary];
    
    //公司名称
    NSString *strPreCpName =@"公司名称：";
    UILabel *lbPreCpName = [[[UILabel alloc] initWithFrame:CGRectMake(20, lbSalary.frame.origin.y + lbSalary.frame.size.height + 10, 280, 15) ]autorelease];
    lbPreCpName.text = strPreCpName;
    lbPreCpName.textColor = [UIColor grayColor];
    lbPreCpName.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbPreCpName];
    
     UILabel *lbCpName = [[[UILabel alloc] initWithFrame:CGRectMake(80, lbSalary.frame.origin.y + lbSalary.frame.size.height + 10, 280, 15) ]autorelease];
    [lbCpName setText:dicJob[@"cpName"]];
     lbCpName.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbCpName];
    
    //＝＝＝＝＝＝＝＝＝＝＝＝设置当前View标题＝＝＝＝＝＝＝＝＝＝＝
    UIView *viewTitle = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 125, 45)] autorelease];
    UILabel *lbTitle = [[[UILabel alloc] initWithFrame:CGRectMake(0, 5, 125, 20)] autorelease];
    [lbTitle setText:dicJob[@"cpName"]];
    [lbTitle setFont:[UIFont systemFontOfSize:10]];
    [lbTitle setTextAlignment:NSTextAlignmentCenter];
    [viewTitle addSubview:lbTitle];
    [self.navigationItem setTitleView:viewTitle];
    
    //工作地点
    NSString *strPreJobRegion =@"工作地点：";
    UILabel *lbJobRegion = [[[UILabel alloc] initWithFrame:CGRectMake(20, lbPreCpName.frame.origin.y + lbPreCpName.frame.size.height + 10, 280, 15) ]autorelease];
    lbJobRegion.text = strPreJobRegion;
    lbJobRegion.textColor = [UIColor grayColor];
    lbJobRegion.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbJobRegion];
    
    NSString *strJobRegion = dicJob[@"JobRegion"];
     UILabel *lbWorkPlace = [[[UILabel alloc] initWithFrame:CGRectMake(80, lbPreCpName.frame.origin.y + lbPreCpName.frame.size.height + 10, 280, 15) ]autorelease];
    labelSize = [CommonController CalculateFrame:strJobRegion fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(lbWorkPlace.frame.size.width, 500)];
    [lbWorkPlace setText:strJobRegion];
    lbWorkPlace.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbWorkPlace];
    
    //坐标
    if ([dicJob[@"lng"] length] > 0) {
        UIButton *btnLngLat = [[UIButton alloc] initWithFrame:CGRectMake(85+labelSize.width, lbPreCpName.frame.origin.y + lbPreCpName.frame.size.height + 5, 16, 21)];
        [btnLngLat setBackgroundImage:[UIImage imageNamed:@"ico_cpinfo_cpaddress.png"] forState:UIControlStateNormal];
        self.lng = [dicJob[@"lng"] floatValue];
        self.lat = [dicJob[@"lat"] floatValue];
        btnLngLat.tag = (NSInteger)dicJob[@"ID"];
        [btnLngLat addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
        [self.subView addSubview:btnLngLat];
        [btnLngLat release];
    }
    
    //招聘人数
    NSString *num = dicJob[@"NeedNumber"];
    //学历
    NSString *education = dicJob[@"Education"];
    //年龄
    NSString *minAge = dicJob[@"MinAge"];
    NSString *maxAge = dicJob[@"MaxAge"];
    NSString *strAge = @" ";
    if ([minAge isEqualToString:@"99"]&&[maxAge isEqualToString:@"99"]) {
        strAge = @"年龄不限";
    }else{
        strAge = [NSString stringWithFormat:@"%@-%@", minAge, maxAge];
    }
    //经验
    NSString *experience = dicJob[@"Experience"];
    if (experience == nil) {
        experience = @"经验不限";
    }
    //全职与否
    NSString *employType = dicJob[@"EmployType"];
    //招聘条件
    UILabel *lbJobRequest = [[[UILabel alloc] initWithFrame:CGRectMake(20, lbWorkPlace.frame.origin.y + lbWorkPlace.frame.size.height + 10, 280, 15) ]autorelease];
    [self.subView addSubview:lbJobRequest];
    lbJobRequest.textColor = [UIColor grayColor];
    lbJobRequest.text = @"招聘条件：";
    lbJobRequest.font = [UIFont systemFontOfSize:12];
    
    UILabel *lbJobRequestValue = [[[UILabel alloc] initWithFrame:CGRectMake(80, lbWorkPlace.frame.origin.y + lbWorkPlace.frame.size.height + 10, 280, 15) ]autorelease];
    lbJobRequestValue.text = [NSString stringWithFormat:@"%@|%@|%@|%@|%@", num, education, strAge, experience, employType];
    lbJobRequestValue.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbJobRequestValue];
    
    //===========================福利小图标=============================
    NSMutableArray *fuliArray = [[NSMutableArray alloc] init];
    //获取所有的福利，并判断是否包含。如果包含则创建view
    for (int i= 1; i<19; i++) {
        NSString *tmpStr = [NSString stringWithFormat:@"Welfare%d", i];
        BOOL tmpFuli = [dicJob[tmpStr] boolValue];
        if (tmpFuli == true) {
            UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 60)];
            switch (i) {
                case 1:
                    [self CreateFuliView:tmpView icoName:@"ico_fuli_baoxian.png" title:@"保险"];
                    [fuliArray addObject:tmpView];
                    break;
                case 2:
                    [self CreateFuliView:tmpView icoName:@"ico_fuli_gongjijin.png" title:@"公积金"];
                    [fuliArray addObject:tmpView];
                    break;
                case 3:
                    [self CreateFuliView:tmpView icoName:@"ico_fuli_jiangjin.png" title:@"奖金提成"];
                    [fuliArray addObject:tmpView];
                    break;
                case 4:
                    [self CreateFuliView:tmpView icoName:@"ico_fuli_qqj.png" title:@"全勤奖"];
                    [fuliArray addObject:tmpView];
                    break;
                case 5:
                    [self CreateFuliView:tmpView icoName:@"ico_fuli_jrfl.png" title:@"节日福利"];
                    [fuliArray addObject:tmpView];
                    break;
                case 6:
                    [self CreateFuliView:tmpView icoName:@"ico_fuli_baoxian.png" title:@"双薪"];
                    [fuliArray addObject:tmpView];
                    break;
                case 7:
                    [self CreateFuliView:tmpView icoName:@"ico_fuli_eighthour.png" title:@"八小时工作制"];
                    [fuliArray addObject:tmpView];
                    break;
                case 8:
                    [self CreateFuliView:tmpView icoName:@"ico_fuli_nianjia.png" title:@"带薪年假"];
                    [fuliArray addObject:tmpView];
                    break;
                case 9                    :
                    [self CreateFuliView:tmpView icoName:@"ico_fuli_peixun.png" title:@"公费培训"];
                    [fuliArray addObject:tmpView];
                    break;
                case 10                    :
                    [self CreateFuliView:tmpView icoName:@"ico_fuli_lvyou.png" title:@"公费旅游"];
                    [fuliArray addObject:tmpView];
                    break;
                case 11:
                    [self CreateFuliView:tmpView icoName:@"ico_fuli_tijian.png" title:@"健康体检"];
                    [fuliArray addObject:tmpView];
                    break;
                case 12:
                    [self CreateFuliView:tmpView icoName:@"ico_fuli_txbt.png" title:@"通讯补贴"];
                    [fuliArray addObject:tmpView];
                    break;
                case 13:
                    [self CreateFuliView:tmpView icoName:@"ico_fuli_sushe.png" title:@"提供住宿"];
                    [fuliArray addObject:tmpView];
                    break;
                case 14:
                    [self CreateFuliView:tmpView icoName:@"ico_fuli_canbu.png" title:@"餐补/工作餐"];
                    [fuliArray addObject:tmpView];
                    break;
                case 15:
                    [self CreateFuliView:tmpView icoName:@"ico_fuli_zfbt.png" title:@"住房补贴"];
                    [fuliArray addObject:tmpView];
                    break;
                case 16:
                    [self CreateFuliView:tmpView icoName:@"ico_fuli_jtbt.png" title:@"交通补贴"];
                    [fuliArray addObject:tmpView];
                    break;
                case 17 :
                    [self CreateFuliView:tmpView icoName:@"ico_fuli_banche.png" title:@"班车接送"];
                    [fuliArray addObject:tmpView];
                    break;
                case 18:
                    [self CreateFuliView:tmpView icoName:@"ico_fuli_baoxian.png" title:@"保险"];
                    [fuliArray addObject:tmpView];
                    break;
                default:
                    break;
            }
            
        }
        //[dicParam setObject:fuli forKey:tmpStr];
    }
   
    
    //四个一组
    int y = lbJobRequestValue.frame.origin.y + lbJobRequestValue.frame.size.height + 10;
    UIView *fuliMainView = nil;
    if (fuliArray.count == 0) {
        fuliMainView = [[UIView alloc] initWithFrame:CGRectMake(20, y-10, 300, 0)];
    }
    else if (fuliArray.count <= 4) {
        fuliMainView = [[UIView alloc] initWithFrame:CGRectMake(20, y, 300, 20)];
    }
    else if(fuliArray.count > 4 && fuliArray.count <= 8){
        fuliMainView = [[UIView alloc] initWithFrame:CGRectMake(20, y, 300, 40)];
    }
    else if(fuliArray.count > 8 && fuliArray.count <= 12){
        fuliMainView = [[UIView alloc] initWithFrame:CGRectMake(20, y, 300, 60)];
    }
    else{
        fuliMainView = [[UIView alloc] initWithFrame:CGRectMake(20, y, 300, 80)];
    }
    //遍历所有的福利图标
    for (int i=0; i<fuliArray.count; i++) {
        UIView *tmpView = fuliArray[i];
        //如果是每一行的第一个图标
        if (i == 0 || i==4 || i==8 || i==12|| i==16) {
            tmpView.frame = CGRectMake(0, (i/4)*20, tmpView.frame.size.width, 15);
        }else{
            //找到上一个图标
            UIView *beforeView = fuliArray[i-1];
            tmpView.frame = CGRectMake(beforeView.frame.origin.x + beforeView.frame.size.width+5, beforeView.frame.origin.y, tmpView.frame.size.width, 15) ;
        }
        
        [fuliMainView addSubview: tmpView];
    }
    [self.subView addSubview:fuliMainView];
    [fuliMainView release];
    
    //第二个分割线
    y = fuliMainView.frame.origin.y + fuliMainView.frame.size.height + 10;
    UILabel *lbLine2 = [[UILabel alloc] initWithFrame:CGRectMake(0, y,320, 1)];
    lbLine2.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.subView addSubview:lbLine2];
    [lbLine2 release];
    
    //岗位职责
    UILabel *lbResponsibility = [[UILabel alloc] initWithFrame:CGRectMake(20, lbLine2.frame.origin.y + lbLine2.frame.size.height + 10, 200, 15)];
    lbResponsibility.textColor = [UIColor grayColor];
    lbResponsibility.text = @"岗位职责：";
    lbResponsibility.font = [UIFont systemFontOfSize:12];
    
    NSString *strResponsibility = dicJob[@"Responsibility"];
    labelSize = [CommonController CalculateFrame:strResponsibility fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(280, 500)];
    UILabel *lbResponsibilityInput = [[UILabel alloc] initWithFrame:CGRectMake(20, lbResponsibility.frame.origin.y + lbResponsibility.frame.size.height + 5, labelSize.width, labelSize.height)];
    lbResponsibilityInput.lineBreakMode = NSLineBreakByCharWrapping;
    lbResponsibilityInput.numberOfLines = 0;
    lbResponsibilityInput.font = [UIFont systemFontOfSize:12];
    lbResponsibilityInput.text = strResponsibility;
    [self.subView addSubview:lbResponsibilityInput];
    [self.subView addSubview:lbResponsibility];
    [lbResponsibility release];
    [lbResponsibilityInput release];
    
    //岗位要求
    UILabel *lbDemand = [[UILabel alloc] initWithFrame:CGRectMake(20, lbResponsibilityInput.frame.origin.y+lbResponsibilityInput.frame.size.height + 15, 200, 15)];
    lbDemand.textColor = [UIColor grayColor];
    lbDemand.text = @"岗位要求：";
    lbDemand.font = [UIFont systemFontOfSize:12];
    NSString *strDemand = dicJob[@"Demand"];
    labelSize = [CommonController CalculateFrame:strDemand fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(280, 500)];
    UILabel *lbDemandInput = [[UILabel alloc] initWithFrame:CGRectMake(20, lbDemand.frame.origin.y+lbDemand.frame.size.height + 5, labelSize.width, labelSize.height)];
    lbDemandInput.lineBreakMode = NSLineBreakByCharWrapping;
    lbDemandInput.numberOfLines = 0;
    lbDemandInput.text = strDemand;
    lbDemandInput.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbDemand];
    [self.subView addSubview:lbDemandInput];
    [lbDemand release];
    [lbDemandInput release];
    
    //第三个分割线
    y = lbDemandInput.frame.origin.y + lbDemandInput.frame.size.height + 10;
    UILabel *lbLine3 = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 320, 1)];
    lbLine3.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.subView addSubview:lbLine3];
    [lbLine3 release];
    
    //联系人
    NSString *strCaName = dicJob[@"caName"];
    UILabel *lbCaName = [[UILabel alloc] initWithFrame:CGRectMake(32, lbLine3.frame.origin.y + lbLine3.frame.size.height + 10, 64, 15)];
    lbCaName.textColor = [UIColor grayColor];
    lbCaName.text = @"联系人：";
    lbCaName.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbCaName];
    [lbCaName release];
    
    UILabel *lbCaNameValue = [[UILabel alloc]initWithFrame:CGRectMake(76, lbLine3.frame.origin.y + lbLine3.frame.size.height + 10, 200, 15)];
    lbCaNameValue.text = strCaName;
    lbCaNameValue.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbCaNameValue];
    [lbCaNameValue release];
    
    //职务
    NSString *strCaTitle = dicJob[@"caTitle"];
    UILabel *lbCaTitle = [[UILabel alloc] initWithFrame:CGRectMake(44, lbCaNameValue.frame.origin.y+lbCaNameValue.frame.size.height + 10, 64, 15)];
    UILabel *lbCaTitleValue = [[UILabel alloc] initWithFrame:CGRectMake(76, lbCaNameValue.frame.origin.y+lbCaNameValue.frame.size.height + 10, 200, 15)];
    if ([dicJob[@"caTitle"] length] > 0) {
        lbCaTitle.textColor = [UIColor grayColor];
        lbCaTitle.text = @"职务：";
        lbCaTitle.font = [UIFont systemFontOfSize:12];
        [self.subView addSubview:lbCaTitle];
        
        lbCaTitleValue.text = strCaTitle;
        lbCaTitleValue.font = [UIFont systemFontOfSize:12];
        [self.subView addSubview:lbCaTitleValue];
    }
    else {
        [lbCaTitle setFrame:CGRectMake(44, lbCaNameValue.frame.origin.y+lbCaNameValue.frame.size.height, 1, 1)];
        [self.subView addSubview:lbCaTitle];
        [lbCaTitleValue setFrame:CGRectMake(76, lbCaNameValue.frame.origin.y+lbCaNameValue.frame.size.height, 1, 1)];
        [self.subView addSubview:lbCaTitleValue];
    }
    [lbCaTitle release];
    [lbCaTitleValue release];
    
    //所在部门
    NSString *strCaDept = dicJob[@"caDept"];
    UILabel *lbDept = [[UILabel alloc]initWithFrame:CGRectMake(20, lbCaTitle.frame.origin.y+lbCaTitle.frame.size.height + 10, 64, 15)];
    UILabel *lbDeptValue = [[UILabel alloc] initWithFrame:CGRectMake(76, lbCaTitleValue.frame.origin.y+lbCaTitleValue.frame.size.height + 10 , 200, 15)];
    if ([dicJob[@"caDept"] length] > 0) {
        lbDept.textColor = [UIColor grayColor];
        lbDept.text = @"所在部门：";
        lbDept.font = [UIFont systemFontOfSize:12];
        [self.subView addSubview:lbDept];
        
        lbDeptValue.text = strCaDept;
        lbDeptValue.font = [UIFont systemFontOfSize:12];
        [self.subView addSubview:lbDeptValue];
    }
    else {
        [lbDept setFrame:CGRectMake(44, lbCaTitle.frame.origin.y+lbCaTitle.frame.size.height, 1, 1)];
        [self.subView addSubview:lbDept];
        [lbDeptValue setFrame:CGRectMake(76, lbCaTitleValue.frame.origin.y+lbCaTitleValue.frame.size.height, 1, 1)];
        [self.subView addSubview:lbDeptValue];
    }
    [lbDept release];
    [lbDeptValue release];
    
    //联系电话
    UILabel *lbCaTel = [[UILabel alloc] initWithFrame:CGRectMake(20, lbDept.frame.origin.y+lbDept.frame.size.height  + 10, 64, 15)];
    lbCaTel.textColor = [UIColor grayColor];
    lbCaTel.text = @"联系电话：";
    lbCaTel.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbCaTel];
    [lbCaTel release];
    
    NSString *strCaTel = dicJob[@"caTel"];
    if (strCaTel.length > 0) {
        //固定电话
        labelSize = [CommonController CalculateFrame:strCaTel fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(280, 500)];
        UILabel *lbCaTelValue = [[UILabel alloc]initWithFrame: CGRectMake(76, lbDept.frame.origin.y+lbDept.frame.size.height + 10, labelSize.width, 15)];
        lbCaTelValue.text = strCaTel;
        lbCaTelValue.font = [UIFont systemFontOfSize:12];
        [self.subView addSubview:lbCaTelValue];
        [lbCaTelValue release];
        
        //联系电话后的图片
        UIButton *btnTel = [[UIButton alloc] initWithFrame:CGRectMake(lbCaTelValue.frame.origin.x + lbCaTelValue.frame.size.width+5, lbCaTelValue.frame.origin.y, 15, 15)];
        [btnTel setBackgroundImage:[UIImage imageNamed:@"ico_calltelphone.png"] forState:UIControlStateNormal];
        [btnTel addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];
        strCaTel = [strCaTel substringToIndex:[strCaTel rangeOfString:@" "].location];
        NSRange rangeTel = [strCaTel rangeOfString:@"转"];
        if (rangeTel.length > 0) {
            strCaTel = [strCaTel substringToIndex:rangeTel.location];
        }
        strCaTel = [strCaTel stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [btnTel setTitle:strCaTel forState:UIControlStateNormal];
        [btnTel setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [self.subView addSubview:btnTel];
        [btnTel release];
    }
    
    NSString *strCaMobile = dicJob[@"caMobile"];
    if (strCaMobile.length > 0) {
        if (strCaTel.length > 0) {
            y = lbCaTel.frame.origin.y + lbCaTel.frame.size.height + 5;
        }
        else {
            y = lbDept.frame.origin.y+lbDept.frame.size.height + 10;
        }
        //手机号
        labelSize = [CommonController CalculateFrame:strCaMobile fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(280, 500)];
        UILabel *lbCaMobileValue = [[UILabel alloc]initWithFrame: CGRectMake(76, y, labelSize.width, 15)];
        lbCaMobileValue.text = strCaMobile;
        lbCaMobileValue.font = [UIFont systemFontOfSize:12];
        [self.subView addSubview:lbCaMobileValue];
        [lbCaMobileValue release];
        
        //联系电话后的图片
        UIButton *btnMobile = [[UIButton alloc] initWithFrame:CGRectMake(lbCaMobileValue.frame.origin.x + lbCaMobileValue.frame.size.width+5, lbCaMobileValue.frame.origin.y, 15, 15)];
        [btnMobile setBackgroundImage:[UIImage imageNamed:@"ico_calltelphone.png"] forState:UIControlStateNormal];
        [btnMobile addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];
        strCaMobile = [strCaMobile substringToIndex:[strCaMobile rangeOfString:@" "].location];
        [btnMobile setTitle:strCaMobile forState:UIControlStateNormal];
        [btnMobile setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [self.subView addSubview:btnMobile];
        [btnMobile release];
    }
    
    //第四个分割线
    if (strCaMobile.length > 0 && strCaTel.length > 0) {
        y = lbCaTel.frame.origin.y + lbCaTel.frame.size.height + 30;
    }
    else {
        y = lbCaTel.frame.origin.y + lbCaTel.frame.size.height + 10;
    }
    UILabel *lbLine4 = [[UILabel alloc] initWithFrame:CGRectMake(0, y, 320, 1)];
    lbLine4.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.subView addSubview:lbLine4];
    [lbLine4 release];

    //浏览了该职位的还查看了
    NSString *strOther = @"浏览了该职位的还查看了以下职位：";
    labelSize = [CommonController CalculateFrame:strOther fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(280, 500)];
    UILabel *lbOther = [[UILabel alloc] initWithFrame:CGRectMake(20, lbLine4.frame.origin.y+lbLine4.frame.size.height + 10, labelSize.width, 15)];
    lbOther.textColor = [UIColor grayColor];
    lbOther.text = strOther;
    lbOther.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbOther];
    [lbOther release];
    
    //在线
    BOOL isOnline = [dicJob[@"IsOnline"] boolValue];
    if(isOnline){
        self.lbChat.text = @"交谈";
        self.imgChat.image = [UIImage imageNamed:@"ico_onlinechat_online.png"];
    }
    self.subView.frame = CGRectMake(0, 0, 320, HEIGHT - 50);
    self.jobMainScroll.frame = CGRectMake(0, 0, 320, HEIGHT - 50);
    //[self.jobMainScroll addSubview:self.subView];
    
    //===================其他职位----调用Webservice=======================
    tmpHeight = lbOther.frame.origin.y + lbOther.frame.size.height + 10;
    [self callOthers];
}

-(void) showMap:(UIButton *)sender
{
    MapViewController *mapC = [[UIStoryboard storyboardWithName:@"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"MapView"];
    mapC.lat = self.lat;
    mapC.lng = self.lng;
    UIViewController *superJobC = [CommonController getFatherController:self.view];
    [mapC.navigationItem setTitle:superJobC.navigationItem.title];
    [superJobC.navigationController pushViewController:mapC animated:true];
}

-(void)callOthers {
    [self.loading startAnimating];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.JobID forKey:@"JobID"];
    [dicParam setObject:self.JobID forKey:@"SearchFromID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetRecommendJobByJobID" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 9;
    self.runningRequest = request;
    [dicParam release];
}

- (void)call:(UIButton *)sender {
    NSString *strCallNumber = sender.titleLabel.text;
    NSLog(@"%@",strCallNumber);
    UIWebView*callWebview =[[UIWebView alloc] init];
    NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",strCallNumber]];
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    //记得添加到view上
    [self.view addSubview:callWebview];
    [callWebview release];
}

- (void)dealloc {
    [_loading release];
    [_recommentJobsData release];
    [_lbFereashTime release];
    [_cPopup release];
    [_jobMainScroll release];
    [_subView release];
    [_lbChat release];
    [_imgChat release];
    [_ViewBottom release];
    [_btnApply release];
    [super dealloc];
}
@end
