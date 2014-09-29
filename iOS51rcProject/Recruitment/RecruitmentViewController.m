#import "RecruitmentViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "RmAttendPaListViewController.h"
#import "RmAttendCpListViewController.h"
#import "MyRecruitmentViewController.h"
#import "RmSearchJobForInviteViewController.h"
#import "LoginViewController.h"
#import "MapViewController.h"
#import "CustomPopup.h"


@interface RecruitmentViewController () <NetWebServiceRequestDelegate,UIScrollViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *lbRmTitle;
@property (retain, nonatomic) IBOutlet UILabel *lbRmCp;
@property (retain, nonatomic) IBOutlet UILabel *lbRmPa;
@property (retain, nonatomic) IBOutlet UIButton *btnRmPa;
@property (retain, nonatomic) IBOutlet UILabel *lbPlace;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollRecruitment;
@property (retain, nonatomic) IBOutlet UIButton *btnRmCp;
@property (retain, nonatomic) IBOutlet UILabel *lbAddress;
@property (retain, nonatomic) IBOutlet UILabel *lbRunDate;
@property (retain, nonatomic) IBOutlet UILabel *lbViewNumber;
@property (retain, nonatomic) IBOutlet UIButton *btnMapView;

@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) NetWebServiceRequest *runningRequestJoinRm;
@property (nonatomic, retain) LoadingAnimationView *loading;
@property (retain, nonatomic) NSString *attentCpCount;
@property (nonatomic, retain) AttendRMPopUp *cPopup;
@property (nonatomic, retain) CustomPopup *photoPopup;
@property (nonatomic, retain) UIPageControl *pagePhoto;

@end

@implementation RecruitmentViewController

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
    self.attentCpCount = @"0";
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
    
    NSLog(@"%@",self.recruitmentID);
    self.btnRmCp.layer.masksToBounds = YES;
    self.btnRmCp.layer.borderWidth = 1.0;
    self.btnRmCp.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    
    self.btnRmPa.layer.masksToBounds = YES;
    self.btnRmPa.layer.borderWidth = 1.0;
    self.btnRmPa.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.recruitmentID forKey:@"ID"];
    [dicParam setObject:@"0" forKey:@"paMainID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetOneRectuitment" Params:dicParam];
    [request setDelegate:self];
    request.tag = 1;
    [request startAsynchronous];
    self.runningRequest = request;
    
    self.loading = [[[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self] autorelease];
    [self.loading startAnimating];
    [dicParam release];
}

-(void) btnMyRecruitmentClick:(UIButton *)sender
{
    MyRecruitmentViewController *myRmCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MyRecruitmentView"];
    [self.navigationController pushViewController:myRmCtrl animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    if (request.tag == 1) {
        [self bindRm:requestData];
    }
    else if(request.tag == 2) {
        self.cPopup = [[[AttendRMPopUp alloc] initPopup] autorelease];
        //self.cPopup = [[[CustomPopup alloc] popupCvSelect:requestData] autorelease];
        [self.cPopup setDelegate:self];
        [self.cPopup showPopup:self.view];
    }
    else if (request.tag == 3) {
        [self fillPlacePhoto:requestData];
    }
    [self.loading stopAnimating];
}

//预约成功，打开搜索、申请、收藏界面
-(void) attendRM{
    RmSearchJobForInviteViewController *searchView = [self.storyboard instantiateViewControllerWithIdentifier:@"RmSearchJobForInviteView"];
    NSString *strTime = [NSString stringWithFormat:@"%@",[CommonController stringFromDate:self.dtBeginTime formatType:@"yyyy-MM-dd HH:mm"]];
    searchView.strBeginTime = strTime;
    searchView.strAddress = self.strAddress;
    searchView.strPlace = self.strPlace;
    searchView.rmID = self.recruitmentID;
    [self.navigationController pushViewController:searchView animated:YES];
}

//绑定招聘会的基本信息
-(void)bindRm:(NSArray* )requestData {
    NSDictionary *dicRecruitment = requestData[0];
    self.lng = dicRecruitment[@"Lng"];
    self.lat = dicRecruitment[@"Lat"];
    self.recruitmentName = dicRecruitment[@"RecruitmentName"];
    //招聘会名称
    NSString *recruitmentTitle = dicRecruitment[@"RecruitmentName"];
    CGSize labelSize = [CommonController CalculateFrame:recruitmentTitle fontDemond:[UIFont systemFontOfSize:16] sizeDemand:CGSizeMake(self.lbRmTitle.frame.size.width, 500)];
    self.lbRmTitle.frame = CGRectMake(self.lbRmTitle.frame.origin.x, self.lbRmTitle.frame.origin.y, labelSize.width, labelSize.height);
    self.lbRmTitle.lineBreakMode = NSLineBreakByCharWrapping;
    self.lbRmTitle.numberOfLines = 0;
    [self.lbRmTitle setText:recruitmentTitle];
    
    //浏览量
    [self.lbViewNumber setText:[NSString stringWithFormat:@"总浏览量：%@",dicRecruitment[@"ViewNumber"]]];
    
    //参与人数
    [self.lbRmPa setText:dicRecruitment[@"paAttentNum"]];
    [self.lbRmCp setText:dicRecruitment[@"cpAttentNum"]];
    self.attentCpCount = dicRecruitment[@"cpAttentNum"];
    
    //举办日期
    self.dtBeginTime = [CommonController dateFromString:dicRecruitment[@"BeginDate"]];
    NSDate *dtEndDate = [CommonController dateFromString:dicRecruitment[@"EndDate"]] ;
    NSString *strTime = [NSString stringWithFormat:@"%@-%@",[CommonController stringFromDate:self.dtBeginTime formatType:@"yyyy-MM-dd HH:mm"],[CommonController stringFromDate:dtEndDate formatType:@"HH:mm"]];
    [self.lbRunDate setText:strTime];
    
    //举办场馆
    CGSize placeSize = [CommonController CalculateFrame:dicRecruitment[@"PlaceName"] fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(2000, 20)];
    self.strPlace = dicRecruitment[@"PlaceName"];
    [self.lbPlace setText:self.strPlace];
    CGRect placeFrame = self.lbPlace.frame;
    if (placeSize.width < placeFrame.size.width) {
        placeFrame.size.width = placeSize.width;
        self.lbPlace.frame = placeFrame;
        
        CGRect mapFrame = self.btnMapView.frame;
        mapFrame.origin.x = placeFrame.origin.x + placeFrame.size.width + 5;
        self.btnMapView.frame = mapFrame;
    }
    
    
    UIFont *font = [UIFont systemFontOfSize:14];
    //举办地址
    self.strAddress = dicRecruitment[@"Address"];
    labelSize = [CommonController CalculateFrame:self.strAddress fontDemond:font sizeDemand:CGSizeMake(self.lbAddress.frame.size.width, 500)];
    self.lbAddress.frame = CGRectMake(self.lbAddress.frame.origin.x, self.lbAddress.frame.origin.y, labelSize.width, MAX(21, labelSize.height));
    self.lbAddress.lineBreakMode = NSLineBreakByCharWrapping;
    self.lbAddress.numberOfLines = 0;
    [self.lbAddress setText:self.strAddress];
    
    float fltHeight = 235;
    float fltLineHeight = 25;
    //联系人信息
    if ([dicRecruitment objectForKey:@"LinkMan"]) {
        UIView *viewLink = [[UIView alloc] initWithFrame:CGRectMake(0, fltHeight, 320, 500)];
        //viewLink.backgroundColor = [UIColor blueColor];
        
        //添加头部分割线
        float fltLinkHeight = 0;
        UILabel *lbLineTop = [[UILabel alloc] init];
        [lbLineTop setText:@"------------------------------------------"];
        [lbLineTop setFrame:CGRectMake(15, 0, 290, 2)];
        [viewLink addSubview:lbLineTop];
        [lbLineTop release];
        
        //添加联系人
        fltLinkHeight += 10;
        UILabel *lbLinkMan = [[UILabel alloc] initWithFrame:CGRectMake(30, fltLinkHeight, 280, 20)];
        [lbLinkMan setText:[NSString stringWithFormat:@"联系人：%@",dicRecruitment[@"LinkMan"]]];
        [lbLinkMan setFont:font];
        [viewLink addSubview:lbLinkMan];
        [lbLinkMan release];
        
        //添加手机号
        if ([dicRecruitment objectForKey:@"Mobile"]) {
            fltLinkHeight += fltLineHeight;
            self.recruitmentMobile = dicRecruitment[@"Mobile"];
            UILabel *lbMobile = [[UILabel alloc] initWithFrame:CGRectMake(30, fltLinkHeight, 280, 20)];
            NSString *recruitmentMobile = [NSString stringWithFormat:@"手机号：%@",dicRecruitment[@"Mobile"]];
            labelSize = [CommonController CalculateFrame:recruitmentMobile fontDemond:font sizeDemand:CGSizeMake(lbMobile.frame.size.width, 20)];
            [lbMobile setText:recruitmentMobile];
            [lbMobile setFrame:CGRectMake(lbMobile.frame.origin.x, lbMobile.frame.origin.y, labelSize.width, lbMobile.frame.size.height)];
            [lbMobile setFont:font];
            [viewLink addSubview:lbMobile];
            
            UIButton *btnCallMobile = [[UIButton alloc] initWithFrame:CGRectMake(lbMobile.frame.origin.x+lbMobile.frame.size.width+5, lbMobile.frame.origin.y+2, 15, 15)];
            btnCallMobile.tag = 1;
            [btnCallMobile setImage:[UIImage imageNamed:@"ico_calltelphone.png"] forState:UIControlStateNormal];
            [btnCallMobile addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];
            [viewLink addSubview:btnCallMobile];
            [btnCallMobile release];
            [lbMobile release];
        }
        
        //添加固定电话
        if ([dicRecruitment objectForKey:@"Telephone"]) {
            fltLinkHeight += fltLineHeight;
            self.recruitmentTelephone = dicRecruitment[@"Telephone"];
            UILabel *lbTelephone = [[UILabel alloc] initWithFrame:CGRectMake(15, fltLinkHeight, 280, 20)];
            [lbTelephone setText:[NSString stringWithFormat:@"固定电话：%@",dicRecruitment[@"Telephone"]]];
            
            NSString *recruitmentTelephone = [NSString stringWithFormat:@"固定电话：%@",dicRecruitment[@"Telephone"]];
            labelSize = [CommonController CalculateFrame:recruitmentTelephone fontDemond:font sizeDemand:CGSizeMake(lbTelephone.frame.size.width, 20)];
            [lbTelephone setText:recruitmentTelephone];
            [lbTelephone setFrame:CGRectMake(lbTelephone.frame.origin.x, lbTelephone.frame.origin.y, labelSize.width, lbTelephone.frame.size.height)];
            
            [lbTelephone setFont:font];
            [viewLink addSubview:lbTelephone];
            [lbTelephone release];
            
            UIButton *btnCallTelephone = [[UIButton alloc] initWithFrame:CGRectMake(lbTelephone.frame.origin.x+lbTelephone.frame.size.width+5, lbTelephone.frame.origin.y+2, 15, 15)];
            btnCallTelephone.tag = 2;
            [btnCallTelephone setImage:[UIImage imageNamed:@"ico_calltelphone.png"] forState:UIControlStateNormal];
            [btnCallTelephone addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];
            [viewLink addSubview:btnCallTelephone];
            [btnCallTelephone release];
        }
        
        //添加传真
        if ([dicRecruitment objectForKey:@"Fax"]) {
            fltLinkHeight += fltLineHeight;
            UILabel *lbFax = [[UILabel alloc] initWithFrame:CGRectMake(44, fltLinkHeight, 280, 20)];
            [lbFax setText:[NSString stringWithFormat:@"传真：%@",dicRecruitment[@"Fax"]]];
            [lbFax setFont:font];
            [viewLink addSubview:lbFax];
            [lbFax release];
        }
        
        //添加邮箱
        if ([dicRecruitment objectForKey:@"Email"]) {
            fltLinkHeight += fltLineHeight;
            UILabel *lbEmail = [[UILabel alloc] initWithFrame:CGRectMake(17, fltLinkHeight, 280, 20)];
            [lbEmail setText:[NSString stringWithFormat:@"联系邮箱：%@",dicRecruitment[@"Email"]]];
            [lbEmail setFont:font];
            [viewLink addSubview:lbEmail];
            [lbEmail release];
        }
        
        //添加QQ
        if ([dicRecruitment objectForKey:@"qq"]) {
            fltLinkHeight += fltLineHeight;
            UILabel *lbQQ = [[UILabel alloc] initWithFrame:CGRectMake(26, fltLinkHeight, 280, 20)];
            [lbQQ setText:[NSString stringWithFormat:@"联系QQ：%@",dicRecruitment[@"qq"]]];
            [lbQQ setFont:font];
            [viewLink addSubview:lbQQ];
            [lbQQ release];
        }
        
        //添加底部分割线
        fltLinkHeight += fltLineHeight+2;
        UILabel *lbLineBottom = [[UILabel alloc] init];
        [lbLineBottom setText:@"------------------------------------------"];
        [lbLineBottom setFrame:CGRectMake(15, fltLinkHeight, 290, 2)];
        [viewLink addSubview:lbLineBottom];
        [lbLineBottom release];
        
        //定高
        fltLinkHeight += 5;
        [viewLink setFrame:CGRectMake(viewLink.frame.origin.x, viewLink.frame.origin.y, viewLink.frame.size.width, fltLinkHeight)];
        [self.scrollRecruitment addSubview:viewLink];
        [viewLink release];
        fltHeight += fltLinkHeight;
    }
    
    //乘车线路
    if ([[dicRecruitment objectForKey:@"BusLine"] length] > 0) {
        fltHeight += 10;
        UILabel *lbBusLine = [[UILabel alloc] initWithFrame:CGRectMake(15, fltHeight, 280, 20)];
        //        lbBusLine.backgroundColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1];
        NSString *recruitmentBusLine = [NSString stringWithFormat:@"乘车线路：\n\n%@",dicRecruitment[@"BusLine"]];
        labelSize = [CommonController CalculateFrame:recruitmentBusLine fontDemond:font sizeDemand:CGSizeMake(lbBusLine.frame.size.width, 500)];
        [lbBusLine setFrame:CGRectMake(lbBusLine.frame.origin.x, lbBusLine.frame.origin.y, lbBusLine.frame.size.width, labelSize.height)];
        lbBusLine.lineBreakMode = NSLineBreakByCharWrapping;
        lbBusLine.numberOfLines = 0;
        [lbBusLine setText:recruitmentBusLine];
        [lbBusLine setFont:font];
        [self.scrollRecruitment addSubview:lbBusLine];
        [lbBusLine release];
        
        fltHeight += labelSize.height;
    }
    
    //场馆环境
    if ([[dicRecruitment objectForKey:@"hasPhoto"] isEqualToString:@"1"]) {
        self.recruitmentDeptId = [dicRecruitment objectForKey:@"RecruitmentDeptId"];
        self.recruitmentPlaceId = [dicRecruitment objectForKey:@"RecruitmentPlaceId"];
        fltHeight += 10;
        UIButton *btnPlaceScan = [[UIButton alloc] initWithFrame:CGRectMake(15, fltHeight, 280, 40)];
        [btnPlaceScan setBackgroundColor:[UIColor colorWithRed:40.f/255.f green:195.f/255.f blue:90.f/255.f alpha:1]];
        [btnPlaceScan.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [btnPlaceScan setTitle:@"查看场馆环境照片" forState:UIControlStateNormal];
        [btnPlaceScan addTarget:self action:@selector(showPlacePhoto:) forControlEvents:UIControlEventTouchUpInside];
        btnPlaceScan.layer.cornerRadius = 5;
        [self.scrollRecruitment addSubview:btnPlaceScan];
        fltHeight += 40;
    }
    
    //招聘会详情
    if ([dicRecruitment objectForKey:@"Brief"]) {
        fltHeight += 10;
        UILabel *lbBrief = [[UILabel alloc] initWithFrame:CGRectMake(15, fltHeight, 280, 20)];
        //        lbBrief.backgroundColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1];
        NSString *recruitmentBrief = [NSString stringWithFormat:@"招聘会详情：\n\n%@",dicRecruitment[@"Brief"]];
        labelSize = [CommonController CalculateFrame:recruitmentBrief fontDemond:font sizeDemand:CGSizeMake(lbBrief.frame.size.width, 5000)];
        [lbBrief setFrame:CGRectMake(lbBrief.frame.origin.x, lbBrief.frame.origin.y, lbBrief.frame.size.width, labelSize.height)];
        lbBrief.lineBreakMode = NSLineBreakByCharWrapping;
        lbBrief.numberOfLines = 0;
        [lbBrief setText:recruitmentBrief];
        [lbBrief setFont:font];
        [self.scrollRecruitment addSubview:lbBrief];
        [lbBrief release];
        
        fltHeight += labelSize.height;
    }
    
    if ([self.dtBeginTime laterDate:[NSDate date]] == self.dtBeginTime) {
        //加底部菜单
        UIView *viewBottom = [[[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, 320, 50)] autorelease];
        viewBottom.backgroundColor = [UIColor colorWithRed:255.f/255.f green:255.f/255.f blue:255.f/255.f alpha:1];
        
        //加我要参会按钮
        UIButton *btnJoin = [[[UIButton alloc] initWithFrame:CGRectMake(110, 10, 100, 30)] autorelease];
        [btnJoin addTarget:self action:@selector(btnJoinClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnJoin setBackgroundColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [btnJoin setTitle:@"我要参会" forState:UIControlStateNormal];
        [btnJoin.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [btnJoin.layer setMasksToBounds:YES];
        [btnJoin.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
        [viewBottom addSubview:btnJoin];
        [self.view addSubview:viewBottom];
        self.scrollRecruitment.frame = CGRectMake(self.scrollRecruitment.frame.origin.x, self.scrollRecruitment.frame.origin.y, self.scrollRecruitment.frame.size.width, self.scrollRecruitment.frame.size.height-50);
    }
    
    [self.scrollRecruitment setContentSize:CGSizeMake(320, fltHeight+20)];
}

//读取场馆照片
-(void)showPlacePhoto:(id)sender
{
    [self.loading startAnimating];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.recruitmentPlaceId forKey:@"placeid"];
    [dicParam setObject:self.recruitmentDeptId forKey:@"deptid"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetRmPlacePhoto" Params:dicParam];
    [request setDelegate:self];
    request.tag = 3;
    [request startAsynchronous];
    self.runningRequest = request;
}

//显示场馆照片
-(void)fillPlacePhoto:(NSArray *)photoList
{
    UIView *viewPhoto = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 200)];
    UIScrollView *scrollPhoto = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 280, 180)];
    [scrollPhoto setDelegate:self];
    [scrollPhoto setContentSize:CGSizeMake(280*photoList.count, 180)];
    scrollPhoto.pagingEnabled = true;
    for (int i=0;i<photoList.count;i++) {
        UIImageView *imgPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(280*i, 0, 280, 180)];
        [imgPhoto setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://down.51rc.com/imagefolder/Recruitment/RmPlacePhoto/%@",photoList[i][@"FileName"]]]]]];
        [scrollPhoto addSubview:imgPhoto];
        [imgPhoto release];
    }
    [viewPhoto addSubview:scrollPhoto];
    self.pagePhoto = [[[UIPageControl alloc] initWithFrame:CGRectMake(0, 195, 100, 5)] autorelease];
    [self.pagePhoto setCurrentPageIndicatorTintColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
    [self.pagePhoto setPageIndicatorTintColor:[UIColor colorWithRed:190.f/255.f green:190.f/255.f blue:190.f/255.f alpha:1]];
    self.pagePhoto.center = CGPointMake(viewPhoto.center.x, 195);
    self.pagePhoto.numberOfPages = photoList.count;
    self.pagePhoto.currentPage = 0;
    [viewPhoto addSubview:self.pagePhoto];
    self.photoPopup = [[CustomPopup alloc] popupCommon:viewPhoto buttonType:PopupButtonTypeNone];
    [self.photoPopup showPopup:self.view];
    [viewPhoto release];
    [scrollPhoto release];
}

//点击我要参会
-(void)btnJoinClick:(id)sender{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"UserID"]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *code = [userDefaults objectForKey:@"code"];
        NSString *userID = [userDefaults objectForKey:@"UserID"];
        
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setObject:self.recruitmentID forKey:@"RmID"];
        [dicParam setObject:userID forKey:@"paMainID"];
        [dicParam setObject:code forKey:@"code"];
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"AddPaRmAppointment" Params:dicParam];
        [request setDelegate:self];
        [request startAsynchronous];
        request.tag = 2;
        self.runningRequestJoinRm = request;
        
        self.loading = [[[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self] autorelease];
        [self.loading startAnimating];
        [dicParam release];

    }
    else {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        LoginViewController *loginC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginView"];
        [self.navigationController pushViewController:loginC animated:true];
    }
}

//点击参会企业
- (IBAction)btnRmCpClick:(id)sender {
    //判断登录
    if ([CommonController isLogin]) {
        if ([self.attentCpCount intValue]>0) {
            RmAttendCpListViewController *cpListCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"RmCpListView"];
            cpListCtrl.rmID = self.recruitmentID;
            NSString *strTime = [NSString stringWithFormat:@"%@",[CommonController stringFromDate:self.dtBeginTime formatType:@"yyyy-MM-dd HH:mm"]];
            cpListCtrl.strBeginTime = strTime;
            cpListCtrl.strAddress = self.strAddress;
            cpListCtrl.strPlace = self.strPlace;
            [self.navigationController pushViewController:cpListCtrl animated:YES];
        }
    }else{
        UIStoryboard *login = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        LoginViewController *loginCtrl = [login instantiateViewControllerWithIdentifier:@"LoginView"];
        [self.navigationController pushViewController:loginCtrl animated:YES];       
    }
}

//点击参会个人
- (IBAction)btnRmPaClick:(id)sender {
    RmAttendPaListViewController *paListCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"RmPaListView"];
    paListCtrl.rmID = self.recruitmentID;
    [self.navigationController pushViewController:paListCtrl animated:YES];
}

- (IBAction)goToMapView:(id)sender {
    MapViewController *mapViewC = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"MapView"];
    mapViewC.lat = [self.lat floatValue];
    mapViewC.lng = [self.lng floatValue];
    [mapViewC.navigationItem setTitle:self.recruitmentName];
    [self.navigationController pushViewController:mapViewC animated:true];
}

- (void)call:(UIButton *)sender {
    NSString *strCallNumber;
    if (sender.tag == 1) {
        strCallNumber = self.recruitmentMobile;
    }
    else {
        strCallNumber = self.recruitmentTelephone;
    }
    UIWebView*callWebview =[[[UIWebView alloc] init] autorelease];
    NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",strCallNumber]];
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    //记得添加到view上
    [self.view addSubview:callWebview];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = fabs(scrollView.contentOffset.x)/280;
    self.pagePhoto.currentPage = index;
}

- (void)dealloc {
    [_recruitmentMobile release];
    [_recruitmentTelephone release];
    [_recruitmentID release];
    [_attentCpCount release];
    [_lbViewNumber release];
    [_lbRmPa release];
    [_lbRmCp release];
    [_lbRunDate release];
    [_lbPlace release];
    [_lbAddress release];
    [_lbRmTitle release];
    [_btnRmCp release];
    [_btnRmPa release];
    [_loading release];
    [_scrollRecruitment release];
    [_dtBeginTime release];
    [_strAddress release];
    [_strPlace release];
    [_btnMapView release];
    [_lng release];
    [_lat release];
    [_recruitmentName release];
    [_recruitmentDeptId release];
    [_recruitmentPlaceId release];
    [_photoPopup release];
    [_pagePhoto release];
    [super dealloc];
}
@end
