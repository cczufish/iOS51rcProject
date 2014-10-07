#import "LoginViewController.h"
#import "NetWebServiceRequest.h"
#import "GDataXMLNode.h"
#import "CommonController.h"
#import "FindPsdStep1ViewController.h"
#import "FindPsdStep3ViewController.h"
#import "HomeViewController.h"
#import "SlideNavigationController.h"


@interface LoginViewController ()<UIScrollViewDelegate>
@property (retain, nonatomic) IBOutlet UILabel *lbTopBg;//最上方的红色下划线
@property (retain, nonatomic) IBOutlet UIButton *btnLogin;
@property (retain, nonatomic) IBOutlet UIButton *btnRegister;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UILabel *lbFirst;
@property (retain, nonatomic) IBOutlet UILabel *lbSecond;
@end

@implementation LoginViewController
#define HEIGHT [[UIScreen mainScreen] bounds].size.height
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;//不加这一行，滚动条会飘
    self.scrollView.delegate = self;
    self.navigationItem.title = @"登录";   
    //获得子View
    self.loginDetailsView = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginDetailsView"];
    self.registerView = [self.storyboard instantiateViewControllerWithIdentifier:@"RegisterView"];
    self.loginDetailsView.view.frame = CGRectMake(0, 0, 320, HEIGHT);
    self.registerView.view.frame = CGRectMake(320, 0, 320, HEIGHT);

    self.loginDetailsView.delegate = self;
    self.loginDetailsView.gotoHomeDelegate = self;;
    self.registerView.gotoHomeDelegate = self;
    
    //把两个个子View加到Scrollview中
    [self.scrollView addSubview:self.loginDetailsView.view];
    [self.scrollView addSubview:self.registerView.view];
    [self.scrollView setContentSize:CGSizeMake(640, self.scrollView.frame.size.height)];//这一行必须放到后面。。否则不滑动
    [self btnLoginClick:nil];
}

- (IBAction)btnLoginClick:(id)sender {
    self.navigationItem.title = @"登录";
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:true];
   
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbSecond setTextColor:[UIColor blackColor]];
        [self.lbFirst setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbTopBg setFrame:CGRectMake(0, self.lbTopBg.frame.origin.y, self.lbTopBg.frame.size.width, self.lbTopBg.frame.size.height)];
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)btnRegisterClick:(id)sender {
    self.navigationItem.title = @"注册";
    [self.scrollView setContentOffset:CGPointMake(320, 0) animated:true];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbFirst setTextColor:[UIColor blackColor]];
        [self.lbSecond setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbTopBg setFrame:CGRectMake(160, self.lbTopBg.frame.origin.y, self.lbTopBg.frame.size.width, self.lbTopBg.frame.size.height)];
    } completion:^(BOOL finished) {
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollView.contentOffset.x > 160) {
        [self btnRegisterClick:nil];
    }
    else {
        [self btnLoginClick:nil];
    }
}

//找回密码
- (void) pushParentsFromLoginDetails
{
    FindPsdStep1ViewController *findPsd1View =[self.storyboard instantiateViewControllerWithIdentifier: @"findPsd1View"];
    [self.navigationController pushViewController:findPsd1View animated:YES];
    findPsd1View.navigationItem.title = @"重置密码";   
}

//返回到登录之前的页面
- (void) gotoHome
{
    UIView *viewC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    if ([viewC isKindOfClass:[HomeViewController class]] || [viewC isKindOfClass:[FindPsdStep3ViewController class]]) {
        HomeViewController *homeViewC = [[UIStoryboard storyboardWithName:@"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"HomeView"];
        homeViewC.toastType = 2;
        [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:homeViewC withCompletion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_loginDetailsView release];
    [_registerView release];
    [_scrollView release];
    [_btnLogin release];
    [_btnRegister release];
    [_lbFirst release];
    [_lbSecond release];
    [super dealloc];
}
@end
