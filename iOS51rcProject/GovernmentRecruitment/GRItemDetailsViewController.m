#import "GRItemDetailsViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import <ShareSDK/ShareSDK.h>

@interface GRItemDetailsViewController ()<NetWebServiceRequestDelegate, UIScrollViewAccessibilityDelegate>
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) LoadingAnimationView *loading;
@property (retain, nonatomic) IBOutlet UIScrollView *newsScroll;
@end

@implementation GRItemDetailsViewController
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
    self.newsScroll.delegate = self;
    
    UIButton *button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [button setTitle: @"政府招考详情" forState: UIControlStateNormal];
    [button sizeToFit];
    self.navigationItem.titleView = button;
    
    //分享按钮
    UIButton *btnRight = [[[UIButton alloc] initWithFrame:CGRectMake(260, 0, 30, self.navigationController.navigationBar.frame.size.height)] autorelease];
    //添加左侧竖线
    UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5, self.navigationController.navigationBar.frame.size.height)] autorelease];
    view.layer.backgroundColor = [UIColor whiteColor].CGColor;
    [btnRight addSubview:view];
    //添加分享图片
    [btnRight addTarget:self action:@selector(btnShareClick:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(10, (self.navigationController.navigationBar.frame.size.height-20)/2, 20, 20)] autorelease];
    UIImage *imgShared = [[UIImage imageNamed:@"btn_cpmain_share.png"] autorelease];
    imageView.image = imgShared;
    [btnRight addSubview:imageView];
    UIBarButtonItem *btnBarRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem=btnBarRight;
    
    //获取数据
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
    //NSString *subSiteUrl =
    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"%@\n最新政府招考信息新鲜出炉，你准备好了吗？http://%@/personal/news/govnews?id=%@&type=2\n",self.strTitle, subSiteUrl, strNewsID]
                                       defaultContent:@"默认分享内容，没内容时显示"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"分享APP"
                                                  url:@"http://www.51rc.com"
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
}


- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result responseData:(NSArray *)requestData
{
    [self didReceiveNews:requestData];
}

-(void) didReceiveNews:(NSArray *) requestData
{
    NSDictionary *dicCpMain = requestData[0];
    UIView *tmpView = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 300)] autorelease];
    //标题
    self.strTitle = dicCpMain[@"title"];
    CGSize labelSize = [CommonController CalculateFrame:self.strTitle fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(310, 200)];
    UILabel *lbTitle = [[[UILabel alloc] initWithFrame:CGRectMake(10, 5, labelSize.width, 40)] autorelease];
    lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
    lbTitle.numberOfLines = 0;
    [lbTitle setText:self.strTitle];
    [tmpView addSubview:lbTitle];
    
    //标签
    NSString *strTag = [NSString stringWithFormat:@"标     签：[%@]",dicCpMain[@"tag"]];
    int y = lbTitle.frame.origin.y + lbTitle.frame.size.height + 5;
    UILabel *lbTag = [[[UILabel alloc] initWithFrame:CGRectMake(10, y, 300, 15)] autorelease];
    lbTag.text = strTag;
    lbTag.font = [UIFont systemFontOfSize:12];
    [tmpView addSubview:lbTag];
    
    //发布日期
    NSString *strDate = dicCpMain[@"refreshdate"];
    NSDate *dtDate = [CommonController dateFromString:strDate];
    strDate = [CommonController stringFromDate:dtDate formatType:@"MM-dd HH:mm"];
    strDate = [NSString stringWithFormat:@"发布日期：%@",strDate];
    y = lbTag.frame.origin.y + lbTag.frame.size.height + 5;
    UILabel *lbDate = [[[UILabel alloc] initWithFrame:CGRectMake(10, y, 300, 15)] autorelease];
    lbDate.text = strDate;
    lbDate.font = [UIFont systemFontOfSize:12];
    [tmpView addSubview:lbDate];
    
    //阅读数
    NSString *strViewCount = [NSString stringWithFormat:@"阅 读 数：%@",dicCpMain[@"ViewNumber"]];
    y = lbDate.frame.origin.y + lbDate.frame.size.height + 5;
    UILabel *lbViewCount = [[[UILabel alloc] initWithFrame:CGRectMake(10, y, 300, 15)] autorelease];
    lbViewCount.text = strViewCount;
    lbViewCount.font = [UIFont systemFontOfSize:12];
    [tmpView addSubview:lbViewCount];
    
    //横线
    y = lbViewCount.frame.origin.y+lbViewCount.frame.size.height + 2;
    UILabel *lbLine = [[[UILabel alloc] initWithFrame:CGRectMake(10, y, 310, 0.5)] autorelease];
    lbLine.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    lbLine.layer.borderWidth = 0;
    [tmpView addSubview:lbLine];
    
    //正文
    NSString *strContent =[CommonController FilterHtml: dicCpMain[@"Content"]];
    labelSize = [CommonController CalculateFrame:strContent fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(300, 5000)];
    y = lbLine.frame.origin.y + lbLine.frame.size.height + 5;
    UILabel *lbContent = [[[UILabel alloc] initWithFrame:CGRectMake(10, y, labelSize.width, labelSize.height)] autorelease];
    lbContent.lineBreakMode = NSLineBreakByCharWrapping;
    lbContent.numberOfLines = 0;
    lbContent.text = strContent;
    lbContent.font = [UIFont systemFontOfSize:12];
    [tmpView addSubview:lbContent];

    //来源
    y = (lbContent.frame.origin.y + lbContent.frame.size.height);
    UILabel *lbAuthor = [[[UILabel alloc] initWithFrame:CGRectMake(100, y, 200, 15)] autorelease];
    lbAuthor.text = [NSString stringWithFormat:@"来源：%@", dicCpMain[@"author"]];
    lbAuthor.textAlignment = NSTextAlignmentRight;
    lbAuthor.font = [UIFont systemFontOfSize:11];
    lbAuthor.textColor = [UIColor grayColor];
    [tmpView addSubview:lbAuthor];
    
    //加到滚动窗口上
    y = lbAuthor.frame.origin.y+lbAuthor.frame.size.height;
    tmpView.frame = CGRectMake(0, 0, 320, y);
    [self.newsScroll addSubview:tmpView];
    
    //屏幕滚动大小
    [self.newsScroll setContentSize:CGSizeMake(320, y + 10)];
    [self.loading stopAnimating];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [strNewsID release];
    //修复错误添加：scrollViewDidScroll:]: message sent to deallocated instance；原因是scrollView释放时，scrollView滑动的动画还未结束，会调用scrollViewDidScroll:(UIScrollView *)sender方法，这时sender也就是UIScrollView已被释放，所以会报错
    _newsScroll.delegate = nil;
    [_strTitle release];
    [_newsScroll release];
    [_loading release];
    [_runningRequest release];
    [super dealloc];
}
@end
