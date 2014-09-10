#import "JobViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "MJRefresh.h"
#import "CustomPopup.h"
#import "Toast+UIView.h"
#import "LoginViewController.h"

@interface JobViewController ()<NetWebServiceRequestDelegate,UIScrollViewDelegate,CustomPopupDelegate>
@property (retain, nonatomic) IBOutlet UIScrollView *jobMainScroll;
@property (retain, nonatomic) IBOutlet UILabel *lbJobName;
@property (retain, nonatomic) IBOutlet UILabel *lbFereashTime;
@property (retain, nonatomic) IBOutlet UILabel *lbCpName;
@property (retain, nonatomic) IBOutlet UILabel *lbCpNameValue;
@property (retain, nonatomic) IBOutlet UILabel *lbWorkPlace;
@property (retain, nonatomic) IBOutlet UILabel *lbWorkPlaceValue;
@property (retain, nonatomic) IBOutlet UILabel *lbJobRequest;
@property (retain, nonatomic) IBOutlet UILabel *lbJobRequestValue;
@property (retain, nonatomic) IBOutlet UILabel *lbSalary;
@property (retain, nonatomic) IBOutlet UILabel *lbSpitLine2;//招聘条件后面
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) LoadingAnimationView *loading;
@property (retain, nonatomic) IBOutlet UITableView *tvRecommentJobList;
@property (retain, nonatomic) IBOutlet UIView *subView;
@property (nonatomic, retain) CustomPopup *cPopup;

@property (retain, nonatomic) IBOutlet UIView *ViewBottom;
@property (retain, nonatomic) IBOutlet UILabel *lbChat;
@property (retain, nonatomic) IBOutlet UIImageView *imgChat;
@end

@implementation JobViewController
@synthesize runningRequest = _runningRequest;
@synthesize loading = _loading;
@synthesize JobID;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"scrollViewDidScroll......");
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
    self.jobMainScroll.delegate = self;
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.JobID forKey:@"JobID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetJobInfo" Params:dicParam];
    request.tag = 1;
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
    self.loading = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    
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
    if (request.tag == 1) { //职位搜索
        [self didReceiveJobMain:requestData];
    } else if (request.tag == 2) { //获取可投递的简历，默认投递第一份简历
    }else if (request.tag == 3) { //获取可投递的简历，默认投递第一份简历
        if (requestData.count == 0) {
            [self.view makeToast:@"您没有有效职位，请先完善您的简历"];
        }
        else {
            self.cPopup = [[[CustomPopup alloc] popupCvSelect:requestData] autorelease];
            [self.cPopup setDelegate:self];
            [self insertJobApply:requestData[0][@"ID"] isFirst:YES];
        }
    }else if (request.tag == 4) { //默认投递完之后，显示弹层
        [self.cPopup showJobApplyCvSelect:result view:self.view];
    }else if (request.tag == 5) { //重新申请职位成功
        [self.view makeToast:@"重新申请简历成功"];
    }else if (request.tag == 6) {
        [self.view makeToast:@"收藏职位成功"];
    }else if(request.tag == 9){//其他建议的职位
        [self didReceiveRecommendJob:requestData];
    }
    
    //结束等待动画
    [self.loading stopAnimating];
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
    //结束等待动画
    [self.loading stopAnimating];
    UIView *tmpView = [[[UIView alloc] initWithFrame:CGRectMake(30, tmpHeight - 20, 280, requestData.count*27)] autorelease];
    for (int i=0; i<requestData.count; i++) {
        NSDictionary *rowData = requestData[i];
        UIButton *btnOhter = [[[UIButton alloc] initWithFrame:CGRectMake(0, 27*i, 280, 20)] autorelease];
        [btnOhter addTarget:self action:@selector(btnOhterJobClick:) forControlEvents:UIControlEventTouchUpInside];
        btnOhter.tag = [rowData[@"ID"] integerValue];
        //职位名称
        UILabel *lbTitle = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 20)]autorelease];
        lbTitle.textColor = [UIColor blackColor];
        lbTitle.font = [UIFont systemFontOfSize:12];
        lbTitle.text = rowData[@"JobName"];
        //待遇
        UILabel *lbSalary = [[[UILabel alloc] initWithFrame:CGRectMake(180, 0, 80, 20)]autorelease];
        lbSalary.text = [CommonController getDictionaryDesc:rowData[@"dcSalaryID"] tableName:@"dcSalary"];
        lbSalary.textColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
        lbSalary.textAlignment = NSTextAlignmentRight;
        lbSalary.font = [UIFont systemFontOfSize:12];
        [btnOhter addSubview:lbTitle];
        [btnOhter addSubview:lbSalary];
        //分割线
        UILabel *lbLine = [[[UILabel alloc] initWithFrame:CGRectMake(0, 24 , 280, 1)] autorelease];
        lbLine.text = @"----------------------------------------------------------------------";
        lbLine.textColor = [UIColor lightGrayColor];
        [btnOhter addSubview:lbLine];
        
        [tmpView addSubview:btnOhter];
    }
    [self.subView addSubview:tmpView];
    self.subView.frame = CGRectMake(tmpView.frame.origin.x, tmpView.frame.origin.y, 320, 400);
    int originY = tmpView.frame.origin.y;
    int originHeight = tmpView.frame.size.height;
    scrolHeight = originHeight + originY;
    [self.jobMainScroll setContentSize:CGSizeMake(320, scrolHeight) ];
    self.ViewBottom.frame = CGRectMake(0, self.height - 80, 320, 50);
    self.jobMainScroll.frame = CGRectMake(0, 0, 320, self.height - 80);
}

//点击其他企业
-(void) btnOhterJobClick:(UIButton *) sender{
    JobViewController *jobCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@""];
    jobCtrl.JobID = [NSString stringWithFormat:@"%d", sender.tag];
    [self.navigationController pushViewController:jobCtrl animated:YES];
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
    self.lbJobName.frame = CGRectMake(20, 15, labelSize.width, labelSize.height);
    self.lbJobName.lineBreakMode = NSLineBreakByCharWrapping;
    self.lbJobName.numberOfLines = 0;
    [self.lbJobName setText:jobName];
    //刷新时间
    self.lbFereashTime.textColor = [UIColor grayColor];
    NSDate *refreshDate = [CommonController dateFromString:dicJob[@"RefreshDate"]];
    NSString *strRefreshDate = [CommonController stringFromDate:refreshDate formatType:@"MM-dd HH:mm"];
    [self.lbFereashTime setText:[NSString stringWithFormat:@"刷新时间：%@", strRefreshDate]];
    //待遇
    NSString *strSalary = dicJob[@"Salary"];
    self.lbSalary.text = strSalary;
    
    //公司名称
    self.lbCpName.textColor = [UIColor grayColor];
    [self.lbCpNameValue setText:dicJob[@"cpName"]];
    //工作地点
    NSString *strJobRegion = dicJob[@"JobRegion"];
    labelSize = [CommonController CalculateFrame:strJobRegion fontDemond:[UIFont systemFontOfSize:16] sizeDemand:CGSizeMake(self.lbJobName.frame.size.width, 500)];
    self.lbWorkPlace.textColor = [UIColor grayColor];
    self.lbWorkPlaceValue.frame = CGRectMake(76, 122, labelSize.width, 15);
    [self.lbWorkPlaceValue setText:strJobRegion];
    //坐标
    UIButton *btnLngLat = [[UIButton alloc] initWithFrame:CGRectMake(labelSize.width + 76 + 5, self.lbWorkPlaceValue.frame.origin.y + self.lbWorkPlaceValue.frame.size.height - 15, 15, 15)];
    //NSString *lng = rowData[@"lng"];
    //NSString *lat = rowData[@"lat"];
    UIImageView *imgLngLat = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    imgLngLat.image = [UIImage imageNamed:@"ico_coordinate_red.png"];
    [btnLngLat addSubview:imgLngLat];
    btnLngLat.tag = (NSInteger)dicJob[@"ID"];
    //[btnLngLat addTarget:self action:@selector(btnLngLatClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.subView addSubview:btnLngLat];
    [btnLngLat release];
    [imgLngLat release];
    
    //招聘人数
    NSString *num = dicJob[@"NeedNumber"];
    //学历
    NSString *education = dicJob[@"Education"];
    //年龄
    NSString *minAge = dicJob[@"MinAge"];
    NSString *maxAge = dicJob[@"MaxAge"];
    //经验
    NSString *experience = dicJob[@"Experience"];
    //全职与否
    NSString *employType = dicJob[@"EmployType"];
    //招聘条件
    self.lbJobRequest.textColor = [UIColor grayColor];
    self.lbJobRequestValue.text = [NSString stringWithFormat:@"%@|%@|%@-%@|%@|%@", num, education, minAge, maxAge, experience, employType];
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
    //NSArray tmpArray = [NSArray alloc] initwith
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 300, 15)];
    //四个一组
    int y = self.lbJobRequestValue.frame.origin.y + self.lbJobRequestValue.frame.size.height + 5;
    int count = fuliArray.count;
    if (count<=4) {
        mainView = [[UIView alloc] initWithFrame:CGRectMake(20, y, 300, 15)];
    }else if(count>4&&count<=8){
        mainView = [[UIView alloc] initWithFrame:CGRectMake(20, y, 300, 30)];
    }else if(count>8&&count<=12){
        mainView = [[UIView alloc] initWithFrame:CGRectMake(20, y, 300, 45)];
    }else{
        mainView = [[UIView alloc] initWithFrame:CGRectMake(20, y, 300, 60)];
    }
    for (int i=0; i<fuliArray.count; i++) {
        UIView *tmpView = fuliArray[i];
        if (i == 0 || i==4 || i==8 || i==12) {
            tmpView.frame = CGRectMake(0, (i/3)*15 + 2, tmpView.frame.size.width, 15);
        }else{
            UIView *beforeView = fuliArray[i-1];
            tmpView.frame = CGRectMake(beforeView.frame.origin.x + beforeView.frame.size.width, beforeView.frame.origin.y, tmpView.frame.size.width, 15) ;
        }
        
        [mainView addSubview: tmpView];
        //UIView *view1 = [UIView alloc] initWithFrame:;
    }
    [self.subView addSubview:mainView];
    [mainView release];
    
    //第二个分割线
    y = mainView.frame.origin.y + mainView.frame.size.height + 5;
    UILabel *lbLine2 = [[UILabel alloc] initWithFrame:CGRectMake(8, y,304, 1)];
    lbLine2.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.subView addSubview:lbLine2];
    [lbLine2 release];
    
    //岗位职责------hight = 166
    UILabel *lbResponsibility = [[UILabel alloc] initWithFrame:CGRectMake(20, lbLine2.frame.origin.y + lbLine2.frame.size.height + 5, 200, 15)];
    lbResponsibility.textColor = [UIColor grayColor];
    lbResponsibility.text = @"岗位职责";
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
    UILabel *lbDemand = [[UILabel alloc] initWithFrame:CGRectMake(20, lbResponsibilityInput.frame.origin.y+lbResponsibilityInput.frame.size.height + 5, 200, 15)];
    lbDemand.textColor = [UIColor grayColor];
    lbDemand.text = @"岗位要求";
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
    y = lbDemandInput.frame.origin.y + lbDemandInput.frame.size.height + 5;
    UILabel *lbLine3 = [[UILabel alloc] initWithFrame:CGRectMake(8, y, 304, 1)];
    lbLine3.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.subView addSubview:lbLine3];
    [lbLine3 release];
    
    //联系人
    NSString *strCaName = dicJob[@"caName"];
    UILabel *lbCaName = [[UILabel alloc] initWithFrame:CGRectMake(20, lbLine3.frame.origin.y + lbLine3.frame.size.height + 5, 64, 15)];
    lbCaName.textColor = [UIColor grayColor];
    lbCaName.text = @"联 系人：";
    lbCaName.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbCaName];
    [lbCaName release];
    
    UILabel *lbCaNameValue = [[UILabel alloc]initWithFrame:CGRectMake(76, lbLine3.frame.origin.y + lbLine3.frame.size.height + 5, 200, 15)];
    lbCaNameValue.text = strCaName;
    lbCaNameValue.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbCaNameValue];
    [lbCaNameValue release];
    
    //职务
    NSString *strCaTitle = dicJob[@"caTitle"];
    UILabel *lbCaTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, lbCaNameValue.frame.origin.y+lbCaNameValue.frame.size.height + 5, 64, 15)];
    lbCaTitle.textColor = [UIColor grayColor];
    lbCaTitle.text = @"职  务：";
    lbCaTitle.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbCaTitle];
    [lbCaTitle release];
    
    UILabel *lbCaTitleValue = [[UILabel alloc] initWithFrame:CGRectMake(76, lbCaNameValue.frame.origin.y+lbCaNameValue.frame.size.height + 5, 200, 15)];
    lbCaTitleValue.text = strCaTitle;
    lbCaTitleValue.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbCaTitleValue];
    [lbCaTitleValue release];
    
    //所在部门
    NSString *strCaDept = dicJob[@"caDept"];
    UILabel *lbDept = [[UILabel alloc]initWithFrame:CGRectMake(20, lbCaTitle.frame.origin.y+lbCaTitle.frame.size.height + 5, 64, 15)];
    lbDept.textColor = [UIColor grayColor];
    lbDept.text = @"所在部门：";
    lbDept.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbDept];
    [lbDept release];
    
    UILabel *lbDeptValue = [[UILabel alloc] initWithFrame:CGRectMake(76, lbCaTitleValue.frame.origin.y+lbCaTitleValue.frame.size.height + 5 , 200, 15)];
    lbDeptValue.text = strCaDept;
    lbDeptValue.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbDeptValue];
    [lbDeptValue release];
    
    //联系电话
    NSString *strCaTel = dicJob[@"caTel"];
    UILabel *lbCaTel = [[UILabel alloc] initWithFrame:CGRectMake(20, lbDept.frame.origin.y+lbDept.frame.size.height  + 5, 64, 15)];
    lbCaTel.textColor = [UIColor grayColor];
    lbCaTel.text = @"联系电话：";
    lbCaTel.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbCaTel];
    [lbCaTel release];
    
    labelSize = [CommonController CalculateFrame:strCaTel fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(280, 500)];
    UILabel *lbCaTelValue = [[UILabel alloc]initWithFrame: CGRectMake(76, lbDept.frame.origin.y+lbDept.frame.size.height + 5, labelSize.width, 15)];
    lbCaTelValue.text = strCaTel;
    lbCaTelValue.font = [UIFont systemFontOfSize:12];
    [self.subView addSubview:lbCaTelValue];
    [lbCaTelValue release];
    
    //联系电话后的图片
    UIImageView *imgMobile = [[UIImageView alloc] initWithFrame:CGRectMake(lbCaTelValue.frame.origin.x + lbCaTelValue.frame.size.width, lbCaTelValue.frame.origin.y, 15, 15)];
    imgMobile.image = [UIImage imageNamed:@"ico_calltelphone.png"];
    //imgMobile.tag = (NSInteger)rowData[@"ID"];
    [self.subView addSubview:imgMobile];
    [imgMobile release];
    
    //第四个分割线
    y = lbCaTel.frame.origin.y + lbCaTel.frame.size.height + 3;
    UILabel *lbLine4 = [[UILabel alloc] initWithFrame:CGRectMake(8, y, 304, 1)];
    lbLine4.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.subView addSubview:lbLine4];
    [lbLine4 release];

    //浏览了该职位的还查看了
    NSString *strOther = @"浏览了该职位的还查看了以下职位：";
    //[self.loading stopAnimating];
    labelSize = [CommonController CalculateFrame:strOther fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(280, 500)];
    UILabel *lbOther = [[UILabel alloc] initWithFrame:CGRectMake(20, lbLine4.frame.origin.y+lbLine4.frame.size.height  + 5, labelSize.width, 15)];
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
    self.subView.frame = CGRectMake(self.jobMainScroll.frame.origin.x, self.jobMainScroll.frame.origin.y, 320, self.height - 50);
    
    //===================其他职位----调用Webservice=======================
    tmpHeight = lbOther.frame.origin.y + lbOther.frame.size.height + 20;
    [self callOhters];
    
}

-(void) callOhters{
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.JobID forKey:@"JobID"];
    [dicParam setObject:@"8500" forKey:@"SearchFromID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetRecommendJobByJobID" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 9;
    self.runningRequest = request;
}

- (void)call:(UIButton *)sender {
    NSString *strCallNumber;
    if (sender.tag == 1) {
        //strCallNumber = self.recruitmentMobile;
    }
    else {
        //strCallNumber = self.recruitmentTelephone;
    }
    UIWebView*callWebview =[[UIWebView alloc] init];
    NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",strCallNumber]];
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    //记得添加到view上
    [self.view addSubview:callWebview];
}

//生成福利视图
-(void) CreatFuliMainView:(NSMutableDictionary *) dicJob FuLiView:(UIView *) mainView{
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
    //NSArray tmpArray = [NSArray alloc] initwith
    //四个一组
    int count = fuliArray.count;
    if (count<=4) {
        mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 15)];
    }else if(count>4&&count<=8){
        mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 45)];
    }else if(count>8&&count<=12){
        mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 65)];
    }else{
        mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 85)];
    }
    for (int i=0; i<fuliArray.count; i++) {
        UIView *tmpView = fuliArray[i];
        if (i == 0 || i==4 || i==8 || i==12) {
            tmpView.frame = CGRectMake(0, (i/3)*15 + 2, tmpView.frame.size.width, 15);
        }else{
            UIView *beforeView = fuliArray[i-1];
            tmpView.frame = CGRectMake(beforeView.frame.origin.x + beforeView.frame.size.width, beforeView.frame.origin.y, tmpView.frame.size.width, 15) ;
        }
        
        [mainView addSubview: tmpView];
        //UIView *view1 = [UIView alloc] initWithFrame:;
    }
}

- (void)dealloc {
    [_lbFereashTime release];
    [_cPopup release];
    [_lbWorkPlaceValue release];
    [_lbJobRequestValue release];
    [_lbSalary release];
    [_lbSpitLine2 release];
    [_jobMainScroll release];
    [_lbCpName release];
    [_lbWorkPlace release];
    [_lbJobRequest release];
    [_contentView release];
    [_tvRecommentJobList release];
    [_subView release];
    [_lbChat release];
    [_imgChat release];
    [_ViewBottom release];
    [super dealloc];
}
@end
