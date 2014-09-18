#import "SuperJobMainViewController.h"
#import "JobViewController.h"
#import "CpMainViewController.h"
#import "CpJobsViewController.h"

#define MENUHEIHT 40
@interface SuperJobMainViewController ()<UIScrollViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *lbUnderline;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UILabel *lbFirst;
@property (retain, nonatomic) IBOutlet UILabel *lbSecond;
@property (retain, nonatomic) IBOutlet UILabel *lbThird;


//三个子页面
@property (retain, nonatomic) JobViewController *firstCtrl;
@property (retain, nonatomic) CpMainViewController *sccondCtrl;
@property (retain, nonatomic) CpJobsViewController *thirdCtrl;

@property (retain, nonatomic) NSString *employId;
@property (retain, nonatomic) NSString *companyId;

@end

@implementation SuperJobMainViewController
#define HEIGHT [[UIScreen mainScreen] bounds].size.height
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
    firstPageLoad = false;
    secondPageLoad = false;
    thriePageLoad = false;
    
    //初始化三个子View
    self.firstCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"JobView"];
    self.firstCtrl.view.frame = CGRectMake(0, 0, 320, HEIGHT);
    self.sccondCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"CpMainView"];
    self.sccondCtrl.view.frame = CGRectMake(320, 0, 320, HEIGHT);    
    self.thirdCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"CpJobsView"];
    self.thirdCtrl.view.frame = CGRectMake(640, 0, 320, HEIGHT);
    //把三个子View加到Scrollview中
    [self.scrollView addSubview:self.firstCtrl.view];
    [self.scrollView addSubview:self.sccondCtrl.view];
    [self.scrollView addSubview:self.thirdCtrl.view];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    //self.scrollView.frame =  CGRectMake(0, 0, 320, HEIGHT);
    [self.scrollView setContentSize:CGSizeMake(960, self.scrollView.frame.size.height)];
    
    //默认加载第一个
    [self switchToFirstView:nil];
}

- (IBAction)switchToFirstView:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:true];
    
    if (!firstPageLoad) {
        self.firstCtrl.JobID = self.JobID;
        [self.JobID retain];
        [self.firstCtrl onSearch];
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbThird setTextColor:[UIColor blackColor]];
        [self.lbSecond setTextColor:[UIColor blackColor]];
        [self.lbFirst setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbUnderline setFrame:CGRectMake(0, self.lbUnderline.frame.origin.y, 100, self.lbUnderline.frame.size.height)];
    } completion:^(BOOL finished) {
        firstPageLoad = true;
    }];
}

- (IBAction)switchToSecondView:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(320, 0) animated:true];
    if (!secondPageLoad) {
        self.sccondCtrl.cpMainID = self.cpMainID;
        [self.cpMainID retain];
        [self.sccondCtrl onSearch];
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbThird setTextColor:[UIColor blackColor]];
        [self.lbFirst setTextColor:[UIColor blackColor]];
        [self.lbSecond setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbUnderline setFrame:CGRectMake(100, self.lbUnderline.frame.origin.y, 100, self.lbUnderline.frame.size.height)];
    } completion:^(BOOL finished) {
        secondPageLoad = true;
    }];
}

- (IBAction)switchToThirdView:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(640, 0) animated:true];
    if (!thriePageLoad) {
        self.thirdCtrl.cpMainID = self.cpMainID;
        [self.cpMainID retain];
        [self.thirdCtrl onSearch];
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbFirst setTextColor:[UIColor blackColor]];
        [self.lbSecond setTextColor:[UIColor blackColor]];
        [self.lbThird setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbUnderline setFrame:CGRectMake(200, self.lbUnderline.frame.origin.y, 120, self.lbUnderline.frame.size.height)];
    } completion:^(BOOL finished) {
        thriePageLoad = true;
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollView.contentOffset.x > 480) {
        [self switchToThirdView:nil];
    }
    else if (self.scrollView.contentOffset.x > 160) {
        [self switchToSecondView:nil];
    }
    else {
        [self switchToFirstView:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_firstCtrl release];
    [_sccondCtrl release];
    [_thirdCtrl release];
    [_lbUnderline release];
    [_scrollView release];
    [_employId release];
    [_companyId release];
    [_lbFirst release];
    [_lbSecond release];
    [_lbThird release];
    [_JobID release];
    [_cpMainID release];
    [super dealloc];
}
@end
