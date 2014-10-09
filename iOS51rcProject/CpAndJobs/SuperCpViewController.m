#import "SuperCpViewController.h"
#import <ShareSDK/ShareSDK.h>
//企业信息父页面
@interface SuperCpViewController ()<UIScrollViewDelegate>
@property (retain, nonatomic) CpJobsViewController *jobsCtrl;
@property (retain, nonatomic) CpMainViewController *cpInfoCtrl;
@property (retain, nonatomic) IBOutlet UIScrollView *svSuper;//滚动条
@property (retain, nonatomic) IBOutlet UILabel *lbCpTopTitle;
@property (retain, nonatomic) IBOutlet UILabel *lbJobListTopTitle;
@property (retain, nonatomic) IBOutlet UILabel *lbTopBg;//最上方的红色下划线
@end

@implementation SuperCpViewController

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
    UIBarButtonItem *btnBarRight = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem = btnBarRight;
    
    //设置滚动条的大小
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.svSuper.frame = CGRectMake(0, 117, 320, self.svSuper.frame.size.height);//必须重写位置，否则，子页面的x＝0.。。
    
    self.svSuper.delegate = self;
    [self.svSuper setScrollEnabled:YES];
   
    //加载子View
    self.cpInfoCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"CpMainView"];
    self.cpInfoCtrl.cpMainID = self.cpMainID;
    [self.cpInfoCtrl onSearch];
    self.jobsCtrl =  [self.storyboard instantiateViewControllerWithIdentifier:@"CpJobsView"];
    self.jobsCtrl.cpMainID = self.cpMainID;
   
    self.jobsCtrl.view.frame = CGRectMake(320, 0, 640, self.svSuper.frame.size.height);
    self.cpInfoCtrl.view.frame = CGRectMake(0, 0, 640, self.svSuper.frame.size.height);
    [self.svSuper addSubview:self.cpInfoCtrl.view];
    [self.svSuper addSubview:self.jobsCtrl.view];
    
    [self.svSuper setContentSize:CGSizeMake(640, self.svSuper.frame.size.height)];//这一行必须放到后面。。否则不滑动
}

- (void) btnShareClick:(UIButton*) sender{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ShareSDK"  ofType:@"jpg"];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    //构造分享内容
    NSString *subSiteUrl = [userDefault objectForKey:@"subSiteUrl"];
    subSiteUrl = [subSiteUrl stringByReplacingOccurrencesOfString:@"www" withString:@"m"];//替换为m站地址
    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"%@\n正在%@网上招聘，一定有适合你的职位，真心推荐哦？\n %@/personal/jv/companyDetail?cpmainID=%@\n",self.navigationItem.title,[userDefault objectForKey:@"subSiteName"], subSiteUrl,self.cpMainID]
                                       defaultContent:@"默认分享内容，没内容时显示"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"分享APP"
                                                  url:[NSString stringWithFormat:@"%@/personal/jv/companyDetail?cpmainID=%@\n", subSiteUrl,self.cpMainID]
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.svSuper.contentOffset.x > 160) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.lbCpTopTitle setTextColor:[UIColor blackColor]];
            [self.lbJobListTopTitle setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
            [self.lbTopBg setFrame:CGRectMake(160, self.lbTopBg.frame.origin.y, self.lbTopBg.frame.size.width, self.lbTopBg.frame.size.height)];
        } completion:^(BOOL finished) {
            if (isJobListLoadFinished == false) {
                [self.jobsCtrl onSearch];
                isJobListLoadFinished = !isJobListLoadFinished;
            }
        }];
    }
    else {
        [UIView animateWithDuration:0.2 animations:^{
            [self.lbJobListTopTitle setTextColor:[UIColor blackColor]];
            [self.lbCpTopTitle setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
            [self.lbTopBg setFrame:CGRectMake(0, self.lbTopBg.frame.origin.y, self.lbTopBg.frame.size.width, self.lbTopBg.frame.size.height)];
                  }];
    }
}
- (IBAction)swithToCpInfo:(id)sender {
    [self.svSuper setContentOffset:CGPointMake(0, 0) animated:true];
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbJobListTopTitle setTextColor:[UIColor blackColor]];
        [self.lbCpTopTitle setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbTopBg setFrame:CGRectMake(0, self.lbTopBg.frame.origin.y, self.lbTopBg.frame.size.width, self.lbTopBg.frame.size.height)];
    }];
}
- (IBAction)switchToJobList:(id)sender {
    [self.svSuper setContentOffset:CGPointMake(320, 0) animated:true];
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbCpTopTitle setTextColor:[UIColor blackColor]];
        [self.lbJobListTopTitle setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbTopBg setFrame:CGRectMake(160, self.lbTopBg.frame.origin.y, self.lbTopBg.frame.size.width, self.lbTopBg.frame.size.height)];      
    } completion:^(BOOL finished) {
        if (isJobListLoadFinished == false) {
            [self.jobsCtrl onSearch];
            isJobListLoadFinished = !isJobListLoadFinished;
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //
}
- (void)dealloc {
    [_cpMainID release];
    [_cpInfoCtrl release];
    [_jobsCtrl release];
    [_svSuper release];
    [_lbCpTopTitle release];
    [_lbJobListTopTitle release];
    [_lbTopBg release];
    [super dealloc];
}
@end
