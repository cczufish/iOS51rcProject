#import "JmJobApplyViewController.h"
#import "JmFavouriteViewController.h"
#import "JmJobScanViewController.h"
#import "JmMainViewController.h"
#import "NetWebServiceRequest.h"

@interface JmMainViewController ()<UIScrollViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *lbUnderline;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UILabel *lbJobApply;
@property (retain, nonatomic) IBOutlet UILabel *lbJobFavourite;
@property (retain, nonatomic) IBOutlet UILabel *lbJobScan;


//三个子页面
@property (retain, nonatomic) JmJobApplyViewController *jobApplyCtrl;
@property (retain, nonatomic) JmFavouriteViewController *jobFavoriteCtrl;
@property (retain, nonatomic) JmJobScanViewController *jobScanCtrl;

@property (retain, nonatomic) NSString *employId;
@property (retain, nonatomic) NSString *companyId;
@property int tabIndex;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@end

@implementation JmMainViewController
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
    self.jobApplyCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"JmJobApplyView"];
    self.jobApplyCtrl.view.frame = CGRectMake(0, 0, 320, HEIGHT);
    self.jobFavoriteCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"JmFavouriteView"];
    self.jobFavoriteCtrl.view.frame = CGRectMake(320, 0, 320, HEIGHT);
    self.jobScanCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"JmJobScanView"];
    self.jobScanCtrl.view.frame = CGRectMake(640, 0, 320, HEIGHT);
    //把三个子View加到Scrollview中
    [self.scrollView addSubview:self.jobApplyCtrl.view];
    [self.scrollView addSubview:self.jobFavoriteCtrl.view];
    [self.scrollView addSubview:self.jobScanCtrl.view];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    //self.scrollView.frame =  CGRectMake(0, 0, 320, HEIGHT);
    [self.scrollView setContentSize:CGSizeMake(960, self.scrollView.frame.size.height)];
    switch (self.tabIndex) {
        case 1:
            [self switchToFirstView:nil];
            break;
        case 2:
            [self switchToSecondView:nil];
            break;
        case 3:
            [self switchToThirdView:nil];
            break;
        default:
            //默认在第一个页面
            [self switchToFirstView:nil];
            break;
    }
}

- (IBAction)switchToFirstView:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:true];
    
    if (!firstPageLoad) {
        [self.jobApplyCtrl onSearch];
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbJobScan setTextColor:[UIColor blackColor]];
        [self.lbJobFavourite setTextColor:[UIColor blackColor]];
        [self.lbJobApply setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbUnderline setFrame:CGRectMake(0, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
    } completion:^(BOOL finished) {
        firstPageLoad = true;
    }];
}

- (IBAction)switchToSecondView:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(320, 0) animated:true];
    if (!secondPageLoad) {
        [self.jobFavoriteCtrl onSearch];
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbJobScan setTextColor:[UIColor blackColor]];
        [self.lbJobApply setTextColor:[UIColor blackColor]];
        [self.lbJobFavourite setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbUnderline setFrame:CGRectMake(106, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
    } completion:^(BOOL finished) {
        secondPageLoad = true;
    }];
}

- (IBAction)switchToThirdView:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(640, 0) animated:true];
    if (!thriePageLoad) {
        [self.jobScanCtrl onSearch];
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbJobApply setTextColor:[UIColor blackColor]];
        [self.lbJobFavourite setTextColor:[UIColor blackColor]];
        [self.lbJobScan setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbUnderline setFrame:CGRectMake(214, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
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
    [_jobApplyCtrl release];
    [_jobFavoriteCtrl release];
    [_jobScanCtrl release];
    [_lbUnderline release];
    [_scrollView release];
    [_runningRequest release];
    [_employId release];
    [_companyId release];
    [_lbJobApply release];
    [_lbJobFavourite release];
    [_lbJobScan release];
    [super dealloc];
}
@end
