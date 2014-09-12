#import "CpInviteViewController.h"
#import "NetWebServiceRequest.h"
#import "CommonController.h"
#import "LoginViewController.h"
#import "InterviewNoticeViewController.h"
#import "JobInviteListViewController.h"
#import "CpAttentionViewController.h"

@interface CpInviteViewController ()<UIScrollViewDelegate>

@property (retain, nonatomic) IBOutlet UILabel *lbUnderline;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UILabel *lbInterviewNotice;
@property (retain, nonatomic) IBOutlet UILabel *lbJobInvite;
@property (retain, nonatomic) IBOutlet UILabel *lbCpAttention;


//三个子页面
@property (retain, nonatomic) InterviewNoticeViewController *interviewNoticeCtrl;
@property (retain, nonatomic) JobInviteListViewController *jobInviteListCtrl;
@property (retain, nonatomic) CpAttentionViewController *cpAttentionCtrl;

@property (retain, nonatomic) NSString *employId;
@property (retain, nonatomic) NSString *companyId;
@property int tabIndex;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@end

@implementation CpInviteViewController
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
    self.interviewNoticeCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"InterviewNoticeView"];
    self.interviewNoticeCtrl.view.frame = CGRectMake(0, 0, 320, HEIGHT);
    self.jobInviteListCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"JobInviteListView"];
    self.jobInviteListCtrl.view.frame = CGRectMake(320, 0, 320, HEIGHT);
    self.cpAttentionCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"CpAttentionView"];
    self.cpAttentionCtrl.view.frame = CGRectMake(640, 0, 320, HEIGHT);
    //把三个子View加到Scrollview中
    [self.scrollView addSubview:self.interviewNoticeCtrl.view];
    [self.scrollView addSubview:self.jobInviteListCtrl.view];
    [self.scrollView addSubview:self.cpAttentionCtrl.view];

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
        [self.interviewNoticeCtrl onSearch];
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbCpAttention setTextColor:[UIColor blackColor]];
        [self.lbJobInvite setTextColor:[UIColor blackColor]];
        [self.lbInterviewNotice setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbUnderline setFrame:CGRectMake(0, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
    } completion:^(BOOL finished) {
        firstPageLoad = true;
    }];
}

- (IBAction)switchToSecondView:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(320, 0) animated:true];
   
    if (!secondPageLoad) {
        //
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbCpAttention setTextColor:[UIColor blackColor]];
        [self.lbInterviewNotice setTextColor:[UIColor blackColor]];
        [self.lbJobInvite setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbUnderline setFrame:CGRectMake(106, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
    } completion:^(BOOL finished) {
        secondPageLoad = true;
    }];
}

- (IBAction)switchToThirdView:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(640, 0) animated:true];
   
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbInterviewNotice setTextColor:[UIColor blackColor]];
        [self.lbJobInvite setTextColor:[UIColor blackColor]];
        [self.lbCpAttention setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)dealloc {
    [_interviewNoticeCtrl release];
    [_jobInviteListCtrl release];
    [_cpAttentionCtrl release];
    [_lbUnderline release];
    [_scrollView release];
    [_runningRequest release];
    [_employId release];
    [_companyId release];
    [_lbInterviewNotice release];
    [_lbJobInvite release];
    [_lbCpAttention release];
    [super dealloc];
}
@end

