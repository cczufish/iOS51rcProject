#import "EIItemDetailsViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import <ShareSDK/ShareSDK.h>

@interface EIItemDetailsViewController ()<NetWebServiceRequestDelegate>
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) LoadingAnimationView *loading;
@property (retain, nonatomic) IBOutlet UIScrollView *newsScroll;
@end

@implementation EIItemDetailsViewController

@synthesize runningRequest = _runningRequest;
@synthesize loading = _loading;
@synthesize strNewsID;

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
    UIButton *button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [button setTitle: @"就业资讯详情" forState: UIControlStateNormal];
    [button sizeToFit];
    self.navigationItem.titleView = button;
    //分享按钮
    UIButton *btnRight = [[[UIButton alloc] initWithFrame:CGRectMake(260, 0, 30, self.navigationController.navigationBar.frame.size.height)] autorelease];
    //添加左侧竖线
    UIView *view1 = [[[UIView alloc] initWithFrame:CGRectMake(1, 5, 1, self.navigationController.navigationBar.frame.size.height-10)] autorelease];
    view1.layer.backgroundColor =  [UIColor colorWithRed:255.f/255.f green:255.f/255.f blue:255.f/255.f alpha:.5].CGColor;
    [btnRight addSubview:view1];
    UIView *view2 = [[[UIView alloc] initWithFrame:CGRectMake(0, 5, 1, self.navigationController.navigationBar.frame.size.height-10)] autorelease];
    view2.layer.backgroundColor = [UIColor colorWithRed:0/255.f green:0/255.f blue:0/255.f alpha:.3].CGColor;
    [btnRight addSubview:view2];
    //添加分享图片
    [btnRight addTarget:self action:@selector(btnShareClick:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(10, (self.navigationController.navigationBar.frame.size.height-20)/2, 20, 20)] autorelease];
    imageView.image = [UIImage imageNamed:@"btn_cpmain_share.png"];
    [btnRight addSubview:imageView];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem = backButton;
    
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.strNewsID forKey:@"strNewsID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetNewsContentByID" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
    self.loading = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    [self.loading startAnimating];
}

- (void) btnShareClick:(UIButton*) sender{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ShareSDK"  ofType:@"jpg"];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //构造分享内容
    NSString *subSiteUrl = [userDefault objectForKey:@"subSiteUrl"];
    subSiteUrl = [subSiteUrl stringByReplacingOccurrencesOfString:@"www" withString:@"m"];//替换为m站地址
    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"%@\n最新政府招考信息新鲜出炉，你准备好了吗？%@/personal/news/govnews?id=%@\n",self.strTitle, subSiteUrl,strNewsID]
                                       defaultContent:@"默认分享内容，没内容时显示"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"给您推荐一条政府招考信息"
                                                  url:[NSString stringWithFormat:@"%@/personal/news/govnews?id=%@\n", subSiteUrl,strNewsID]
                                          description:@""
                                            mediaType:SSPublishContentMediaTypeNews];
    
    [ShareSDK showShareActionSheet:nil
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"scrollViewDidScroll......");
}


- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    [self didReceiveNews:requestData];
}

-(void) didReceiveNews:(NSArray *) requestData
{
    NSDictionary *dicCpMain = requestData[0];
    UIView *tmpView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 300)];
    //标题
    self.strTitle  = dicCpMain[@"title"];
    self.strTitle = [self.strTitle stringByReplacingOccurrencesOfString:@"（图）" withString:@""];
    CGSize labelSize = [CommonController CalculateFrame:self.strTitle fontDemond:[UIFont systemFontOfSize:16] sizeDemand:CGSizeMake(310, 200)];
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, labelSize.width, 70)];
    lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
    lbTitle.numberOfLines = 0;
    [lbTitle setText:self.strTitle];
    [tmpView addSubview:lbTitle];
    
    //标签
    NSString *strTag = [NSString stringWithFormat:@"标     签：[%@]",dicCpMain[@"tag"]];
    int y = lbTitle.frame.origin.y + lbTitle.frame.size.height + 5;
    UILabel *lbTag = [[UILabel alloc] initWithFrame:CGRectMake(10, y, 300, 15)];
    lbTag.text = strTag;
    lbTag.font = [UIFont systemFontOfSize:14];
    [tmpView addSubview:lbTag];
    
    //发布日期
    NSString *strDate = dicCpMain[@"refreshdate"];
    NSDate *dtDate = [CommonController dateFromString:strDate];
    strDate = [CommonController stringFromDate:dtDate formatType:@"MM-dd HH:mm"];
    strDate = [NSString stringWithFormat:@"发布日期：%@",strDate];
    y = lbTag.frame.origin.y + lbTag.frame.size.height + 5;
    UILabel *lbDate = [[UILabel alloc] initWithFrame:CGRectMake(10, y, 300, 15)];
    lbDate.text = strDate;
    lbDate.font = [UIFont systemFontOfSize:14];
    [tmpView addSubview:lbDate];
    
    //阅读数
    NSString *strViewCount = [NSString stringWithFormat:@"阅 读 数：%@",dicCpMain[@"ViewNumber"]];
    y = lbDate.frame.origin.y + lbDate.frame.size.height + 5;
    UILabel *lbViewCount = [[UILabel alloc] initWithFrame:CGRectMake(10, y, 300, 15)];
    lbViewCount.text = strViewCount;
    lbViewCount.font = [UIFont systemFontOfSize:14];
    [tmpView addSubview:lbViewCount];
    
    //横线
    y = lbViewCount.frame.origin.y+lbViewCount.frame.size.height + 2;
    UILabel *lbLine = [[UILabel alloc] initWithFrame:CGRectMake(10, y, 310, 0.5)];
    lbLine.layer.backgroundColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
    lbLine.layer.borderWidth = 0;
    [tmpView addSubview:lbLine];
    
    //正文
    NSString *strContent =[CommonController FilterHtml: dicCpMain[@"Content"]];
    labelSize = [CommonController CalculateFrame:strContent fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(300, 5000)];
    y = lbLine.frame.origin.y + lbLine.frame.size.height + 5;
    UILabel *lbContent = [[UILabel alloc] initWithFrame:CGRectMake(10, y, labelSize.width, labelSize.height)];
    lbContent.lineBreakMode = NSLineBreakByCharWrapping;
    lbContent.numberOfLines = 0;
    lbContent.text = strContent;
    lbContent.font = [UIFont systemFontOfSize:14];
    [tmpView addSubview:lbContent];
    
    //来源
    y = (lbContent.frame.origin.y + lbContent.frame.size.height);
    UILabel *lbAuthor = [[UILabel alloc] initWithFrame:CGRectMake(100, y, 200, 15)];
    lbAuthor.text = [NSString stringWithFormat:@"来源：%@", dicCpMain[@"author"]];
    lbAuthor.textAlignment = NSTextAlignmentRight;
    lbAuthor.font = [UIFont systemFontOfSize:13];
    lbAuthor.textColor = [UIColor grayColor];
    [tmpView addSubview:lbAuthor];
    
    //加到滚动窗口上
    y = lbAuthor.frame.origin.y+lbAuthor.frame.size.height;
    tmpView.frame = CGRectMake(0, 0, 320, y);
    [self.newsScroll addSubview:tmpView];
    
    //屏幕滚动
    //self.newsScroll.frame = CGRectMake(self.newsScroll.frame.origin.x, self.newsScroll.frame.origin.y, self.newsScroll.frame.size.width, self.newsScroll.frame.size.height-5);
    [self.newsScroll setContentSize:CGSizeMake(320, y + 10)];
    [self.loading stopAnimating];
    [lbTitle release];
    [lbTag release];
    [lbViewCount release];
    [lbDate release];
    [lbLine release];
    [lbContent release];
    [lbAuthor release];
    [tmpView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [strNewsID release];
    [_strTitle release];
    [_newsScroll release];
    [super dealloc];
}
@end
