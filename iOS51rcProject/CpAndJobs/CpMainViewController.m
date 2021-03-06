#import "CpMainViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "MapViewController.h"

//企业页面
@interface CpMainViewController ()<NetWebServiceRequestDelegate, UIScrollViewDelegate>
@property (retain, nonatomic) IBOutlet UILabel *lbCpName;
@property (retain, nonatomic) IBOutlet UIImageView *imgCpType;
@property (retain, nonatomic) IBOutlet UILabel *lbIndustry;
@property (retain, nonatomic) IBOutlet UILabel *lbIndustryValue;
@property (retain, nonatomic) IBOutlet UILabel *lbCompanyKind;
@property (retain, nonatomic) IBOutlet UILabel *lbCompanyKindValue;
@property (retain, nonatomic) IBOutlet UILabel *lbCompanySize;
@property (retain, nonatomic) IBOutlet UILabel *lbCompanySizeValue;
@property (retain, nonatomic) IBOutlet UILabel *lbAddress;
@property (retain, nonatomic) IBOutlet UILabel *lbAddressValue;
@property (retain, nonatomic) IBOutlet UILabel *lbBrief;
@property (retain, nonatomic) IBOutlet UILabel *lbBriefValue;
@property (retain, nonatomic) IBOutlet UILabel *lbLine;

@property (retain, nonatomic) IBOutlet UIScrollView *cpMainScroll;
@property (retain, nonatomic) IBOutlet UIView *cpMainView;
@property (retain, nonatomic) IBOutlet UIImageView *imageCoordinate;

@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) LoadingAnimationView *loading;
@property (retain, nonatomic) NSString *wsName;//当前调用的webservice名称
@end

@implementation CpMainViewController
@synthesize runningRequest = _runningRequest;
@synthesize loading = _loading;

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
    [self.cpMainScroll setContentSize:CGSizeMake(320, self.cpMainScroll.frame.size.height)];
    self.cpMainScroll.delegate = self;
    UIButton *button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [button setTitle: @"企业信息" forState: UIControlStateNormal];
    [button sizeToFit];
    self.navigationItem.titleView = button;
    //[self onSearch];
}

-(void) onSearch{
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.cpMainID forKey:@"CpMainID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCpMainInfo" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
    self.wsName = @"GetCpMainInfo";//当前调用的函数名称
    self.loading = [[[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self] autorelease];
    [self.loading startAnimating];
    [dicParam release];

}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    if ([self.wsName isEqualToString:@"GetCpMainInfo"]) {
        [self didReceiveCpMain:requestData];
    }
}

-(void) didReceiveCpMain:(NSArray *) requestData
{
    NSDictionary *dicCpMain = requestData[0];
    //公司名称
    NSString *cpName = dicCpMain[@"Name"];
    CGSize labelSize = [CommonController CalculateFrame:cpName fontDemond:[UIFont systemFontOfSize:16] sizeDemand:CGSizeMake(self.lbCpName.frame.size.width, 500)];
    self.lbCpName.frame = CGRectMake(self.lbCpName.frame.origin.x, self.lbCpName.frame.origin.y, labelSize.width, labelSize.height);
    self.lbCpName.lineBreakMode = NSLineBreakByCharWrapping;
    self.lbCpName.numberOfLines = 0;
    [self.lbCpName setText:cpName];
    //公司名称后边的图标
    self.imgCpType.frame = CGRectMake(self.lbCpName.frame.origin.x + self.lbCpName.frame.size.width + 1, self.lbCpName.frame.origin.y+1, 18, 15);
    //所属行业
    self.lbIndustry.textColor = [UIColor grayColor];
    NSString *strIndustry = dicCpMain[@"Industry"];
    labelSize = [CommonController CalculateFrame:strIndustry fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(200, 500)];
    self.lbIndustryValue.text = strIndustry;
    self.lbIndustryValue.numberOfLines = 0;
    self.lbIndustryValue.lineBreakMode = NSLineBreakByCharWrapping;
    self.lbIndustryValue.frame = CGRectMake(self.lbIndustryValue.frame.origin.x, self.lbIndustryValue.frame.origin.y, labelSize.width, labelSize.height);
    
    //公司性质
    self.lbCompanyKind.textColor = [UIColor grayColor];
    self.lbCompanyKind.frame = CGRectMake(self.lbCompanyKind.frame.origin.x, self.lbIndustryValue.frame.origin.y  + self.lbIndustryValue.frame.size.height + 5, self.lbCompanyKind.frame.size.width, self.lbCompanyKind.frame.size.height);
    self.lbCompanyKindValue.text = dicCpMain[@"CompanyKind"];
    self.lbCompanyKindValue.frame = CGRectMake(self.lbCompanyKindValue.frame.origin.x, self.lbIndustryValue.frame.origin.y + self.lbIndustryValue.frame.size.height+ 5, self.lbCompanyKindValue.frame.size.width, self.lbCompanyKindValue.frame.size.height);
    //公司规模
    self.lbCompanySize.textColor = [UIColor grayColor];
    self.lbCompanySize.frame = CGRectMake(self.lbCompanySize.frame.origin.x, self.lbCompanyKindValue.frame.origin.y + self.lbCompanyKindValue.frame.size.height+ 5, self.lbCompanySize.frame.size.width, self.lbCompanySize.frame.size.height);
    [self.lbCompanySizeValue setText:dicCpMain[@"CompanySize"]];
    self.lbCompanySizeValue.frame = CGRectMake(self.lbCompanySizeValue.frame.origin.x, self.lbCompanyKindValue.frame.origin.y+ self.lbCompanyKindValue.frame.size.height+ 5, self.lbCompanySizeValue.frame.size.width, self.lbCompanySizeValue.frame.size.height);
    //详细地址
    self.lbAddress.textColor = [UIColor grayColor];
    self.lbAddress.frame = CGRectMake(self.lbAddress.frame.origin.x, self.lbCompanySizeValue.frame.origin.y+ self.lbCompanySizeValue.frame.size.height+ 5, self.lbAddress.frame.size.width, self.lbAddress.frame.size.height);
    
    NSString *strRegion = dicCpMain[@"RegionName"];
    NSString *strAddressDetails = [NSString stringWithFormat:@"%@%@", strRegion, dicCpMain[@"Address"]];
    labelSize = [CommonController CalculateFrame:strAddressDetails fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(200, 500)];
    //地址按钮可点击
    UIButton *btnLngLat = [[[UIButton alloc] initWithFrame:CGRectMake(90, self.lbAddress.frame.origin.y, labelSize.width + 20, labelSize.height)]autorelease];
    btnLngLat.tag = (NSInteger)dicCpMain[@"ID"];
    [btnLngLat addTarget:self action:@selector(showMap:) forControlEvents:UIControlEventTouchUpInside];
    [self.cpMainScroll addSubview:btnLngLat];
    //地址文字
    self.lbAddressValue.frame = CGRectMake(90, self.lbAddress.frame.origin.y + 5, labelSize.width, labelSize.height);
    self.lbAddressValue.lineBreakMode = NSLineBreakByCharWrapping;
    self.lbAddressValue.numberOfLines = 0;
    self.lbAddressValue.text = strAddressDetails;
    //坐标
    if (dicCpMain[@"Lng"] != nil) {
        UIImageView *imgLngLat = [[[UIImageView alloc] initWithFrame:CGRectMake(self.lbAddressValue.frame.origin.x + self.lbAddressValue.frame.size.width, self.lbAddress.frame.origin.y, 13, 15)]autorelease];
        imgLngLat.image = [UIImage imageNamed:@"ico_cpinfo_cpaddress.png"];
        [self.cpMainScroll addSubview:imgLngLat];
        self.lng = [dicCpMain[@"Lng"] floatValue];
        self.lat = [dicCpMain[@"Lat"] floatValue];
    }

    //分割线
    CGFloat y = self.lbAddressValue.frame.origin.y + self.lbAddressValue.frame.size.height - 23;
    self.lbLine.frame = CGRectMake(8, y + 34, 304, 0.5);
    //公司介绍------hight = 166
    self.lbBrief.textColor = [UIColor grayColor];
    self.lbBrief.frame = CGRectMake(20, self.lbLine.frame.origin.y + self.lbLine.frame.size.height, 200, 40);
    NSString *strResponsibility = [CommonController FilterHtml: dicCpMain[@"Brief"]];
    labelSize = [CommonController CalculateFrame:strResponsibility fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(280, 500)];
    self.lbBriefValue.frame = CGRectMake(20, self.lbBrief.frame.origin.y + self.lbBrief.frame.size.height - 5, labelSize.width, labelSize.height);
    self.lbBriefValue.lineBreakMode = NSLineBreakByCharWrapping;
    self.lbBriefValue.numberOfLines = 0;
    self.lbBriefValue.text = strResponsibility;
    //屏幕滚动
    self.cpMainScroll.frame = CGRectMake(0, 0, self.cpMainScroll.frame.size.width, self.cpMainScroll.frame.size.height-5);
    [self.cpMainScroll setContentSize:CGSizeMake(320, self.lbBriefValue.frame.size.height + 310)];
    [self.loading stopAnimating];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)dealloc {
    [_lbCpName release];
    [_imgCpType release];
    [_lbIndustry release];
    [_lbIndustryValue release];
    [_lbCompanyKind release];
    [_lbCompanyKindValue release];
    [_lbCompanySize release];
    [_lbCompanySizeValue release];
    [_lbAddress release];
    [_lbAddressValue release];
    [_lbBrief release];
    [_lbBriefValue release];
    [_lbLine release];
    [_cpMainScroll release];
    [_cpMainView release];
    [_imageCoordinate release];
    [_loading release];
    [super dealloc];
}
@end
