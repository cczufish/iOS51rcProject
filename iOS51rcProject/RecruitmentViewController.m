#import "RecruitmentViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"

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
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) LoadingAnimationView *loading;
@end

@implementation RecruitmentViewController

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"123");
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
    NSLog(@"%@",self.recruitmentID);
    self.btnRmCp.layer.masksToBounds = YES;
    self.btnRmCp.layer.borderWidth = 1.0;
    self.btnRmCp.layer.borderColor = [[UIColor grayColor] CGColor];
    
    self.btnRmPa.layer.masksToBounds = YES;
    self.btnRmPa.layer.borderWidth = 1.0;
    self.btnRmPa.layer.borderColor = [[UIColor grayColor] CGColor];
    
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.recruitmentID forKey:@"ID"];
    [dicParam setObject:@"0" forKey:@"paMainID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetOneRectuitment" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
    
    self.loading = [[[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self] autorelease];
    [self.loading startAnimating];
    [dicParam release];
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
    NSDictionary *dicRecruitment = requestData[0];
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
    
    //举办日期
    NSDate *dtBeginDate = [CommonController dateFromString:dicRecruitment[@"BeginDate"]];
    NSDate *dtEndDate = [CommonController dateFromString:dicRecruitment[@"EndDate"]];
    
    [self.lbRunDate setText:[NSString stringWithFormat:@"%@-%@",[CommonController stringFromDate:dtBeginDate formatType:@"yyyy-MM-dd HH:mm"],[CommonController stringFromDate:dtEndDate formatType:@"HH:mm"]]];
    
    //举办场馆
    [self.lbPlace setText:dicRecruitment[@"PlaceName"]];
    
    UIFont *font = [UIFont systemFontOfSize:12];
    //举办地址
    NSString *recruitmentAddress = dicRecruitment[@"Address"];
    labelSize = [CommonController CalculateFrame:recruitmentAddress fontDemond:font sizeDemand:CGSizeMake(self.lbAddress.frame.size.width, 500)];
    self.lbAddress.frame = CGRectMake(self.lbAddress.frame.origin.x, self.lbAddress.frame.origin.y, labelSize.width, MAX(21, labelSize.height));
    self.lbAddress.lineBreakMode = NSLineBreakByCharWrapping;
    self.lbAddress.numberOfLines = 0;
    [self.lbAddress setText:recruitmentAddress];
    
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
        [lbLineTop setFrame:CGRectMake(20, 0, 290, 2)];
        [viewLink addSubview:lbLineTop];
        [lbLineTop release];
        
        //添加联系人
        fltLinkHeight += 10;
        UILabel *lbLinkMan = [[UILabel alloc] initWithFrame:CGRectMake(32, fltLinkHeight, 280, 20)];
        [lbLinkMan setText:[NSString stringWithFormat:@"联系人：%@",dicRecruitment[@"LinkMan"]]];
        [lbLinkMan setFont:font];
        [viewLink addSubview:lbLinkMan];
        [lbLinkMan release];
        
        //添加手机号
        if ([dicRecruitment objectForKey:@"Mobile"]) {
            fltLinkHeight += fltLineHeight;
            self.recruitmentMobile = dicRecruitment[@"Mobile"];
            UILabel *lbMobile = [[UILabel alloc] initWithFrame:CGRectMake(32, fltLinkHeight, 280, 20)];
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
            UILabel *lbTelephone = [[UILabel alloc] initWithFrame:CGRectMake(20, fltLinkHeight, 280, 20)];
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
            UILabel *lbEmail = [[UILabel alloc] initWithFrame:CGRectMake(20, fltLinkHeight, 280, 20)];
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
        [lbLineBottom setFrame:CGRectMake(20, fltLinkHeight, 290, 2)];
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
    if ([dicRecruitment objectForKey:@"BusLine"]) {
        fltHeight += 10;
        UILabel *lbBusLine = [[UILabel alloc] initWithFrame:CGRectMake(20, fltHeight, 280, 20)];
//        lbBusLine.backgroundColor = [UIColor grayColor];
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
    
    //招聘会详情
    if ([dicRecruitment objectForKey:@"Brief"]) {
        fltHeight += 10;
        UILabel *lbBrief = [[UILabel alloc] initWithFrame:CGRectMake(20, fltHeight, 280, 20)];
//        lbBrief.backgroundColor = [UIColor grayColor];
        NSString *recruitmentBrief = [NSString stringWithFormat:@"招聘会详情：\n\n%@",dicRecruitment[@"Brief"]];
        labelSize = [CommonController CalculateFrame:recruitmentBrief fontDemond:font sizeDemand:CGSizeMake(lbBrief.frame.size.width, 500)];
        [lbBrief setFrame:CGRectMake(lbBrief.frame.origin.x, lbBrief.frame.origin.y, lbBrief.frame.size.width, labelSize.height)];
        lbBrief.lineBreakMode = NSLineBreakByCharWrapping;
        lbBrief.numberOfLines = 0;
        [lbBrief setText:recruitmentBrief];
        [lbBrief setFont:font];
        [self.scrollRecruitment addSubview:lbBrief];
        [lbBrief release];
        
        fltHeight += labelSize.height;
    }
    
    if ([dtBeginDate laterDate:[NSDate date]] == dtBeginDate) {
        //加底部菜单
        UIView *viewBottom = [[[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, 320, 50)] autorelease];
        viewBottom.backgroundColor = [UIColor colorWithRed:255.f/255.f green:255.f/255.f blue:255.f/255.f alpha:1];
        
        //加我要参会按钮
        UIButton *btnJoin = [[[UIButton alloc] initWithFrame:CGRectMake(110, 10, 100, 30)] autorelease];
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
    [self.loading stopAnimating];
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

- (void)dealloc {
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
    [super dealloc];
}
@end
