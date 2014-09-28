#import "AccountManagementViewController.h"

@interface AccountManagementViewController ()<UIScrollViewDelegate>
@property (retain, nonatomic) IBOutlet UILabel *lbTopBg;//最上方的红色下划线
@property (retain, nonatomic) IBOutlet UIButton *btnLogin;
@property (retain, nonatomic) IBOutlet UIButton *btnRegister;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UILabel *lbFirst;
@property (retain, nonatomic) IBOutlet UILabel *lbSecond;
@end

@implementation AccountManagementViewController
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
    //获得子View
    self.firstView = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangePsdView"];
    self.secondView = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangeNameView"];
    self.firstView.view.frame = CGRectMake(0, 0, 320, HEIGHT);
    self.secondView.view.frame = CGRectMake(320, 0, 320, HEIGHT);
    
    //把两个个子View加到Scrollview中
    [self.scrollView addSubview:self.firstView.view];
    [self.scrollView addSubview:self.secondView.view];
    [self.scrollView setContentSize:CGSizeMake(640, self.scrollView.frame.size.height)];//这一行必须放到后面。。否则不滑动
    [self btnFirstClick:nil];
}

- (IBAction)btnFirstClick:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:true];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbSecond setTextColor:[UIColor blackColor]];
        [self.lbFirst setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbTopBg setFrame:CGRectMake(0, self.lbTopBg.frame.origin.y, self.lbTopBg.frame.size.width, self.lbTopBg.frame.size.height)];
    } completion:^(BOOL finished) {
    }];
}

- (IBAction)btnSecondClick:(id)sender {
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
        [self btnFirstClick:nil];
    }
    else {
        [self btnSecondClick:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_firstView release];
    [_secondView release];
    [_scrollView release];
    [_btnLogin release];
    [_btnRegister release];
    [_lbFirst release];
    [_lbSecond release];
    [super dealloc];
}
@end

