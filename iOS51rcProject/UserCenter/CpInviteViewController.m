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
@property (nonatomic, retain) NSMutableArray *campusListData;
@property (nonatomic, retain) NSMutableArray *employData;
@property (nonatomic, retain) NSMutableArray *employListData;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@end

@implementation CpInviteViewController

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
    self.automaticallyAdjustsScrollViewInsets = NO;
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
            break;
    }
}

- (IBAction)switchToFirstView:(id)sender {
//    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:true];
//    [UIView animateWithDuration:0.2 animations:^{
//        [self.lbEmploy setTextColor:[UIColor blackColor]];
//        [self.lbCampus setTextColor:[UIColor blackColor]];
//        [self.lbBrief setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
//        [self.lbUnderline setFrame:CGRectMake(0, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
//    } completion:^(BOOL finished) {
//        if (self.employData.count == 0) {
//            [self onEmploySearchByCpID];
//        }
//    }];
}

- (IBAction)switchToSecondView:(id)sender {
//    [self.scrollView setContentOffset:CGPointMake(320, 0) animated:true];
//    [UIView animateWithDuration:0.2 animations:^{
//        [self.lbEmploy setTextColor:[UIColor blackColor]];
//        [self.lbBrief setTextColor:[UIColor blackColor]];
//        [self.lbCampus setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
//        [self.lbUnderline setFrame:CGRectMake(106, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
//    } completion:^(BOOL finished) {
//        if (self.campusListData.count == 0) {
//            [self onCampusSearch];
//        }
//    }];
}

- (IBAction)switchToThirdView:(id)sender {
//    [self.scrollView setContentOffset:CGPointMake(640, 0) animated:true];
//    [UIView animateWithDuration:0.2 animations:^{
//        [self.lbCampus setTextColor:[UIColor blackColor]];
//        [self.lbBrief setTextColor:[UIColor blackColor]];
//        [self.lbEmploy setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
//        [self.lbUnderline setFrame:CGRectMake(214, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
//    } completion:^(BOOL finished) {
//        if (self.employData.count == 0) {
//            if (self.companyId.length == 0) {
//                [self onEmploySearch];
//            }
//            else {
//                [self onEmploySearchByCpID];
//            }
//        }
//    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.campusListData.count;
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
    [_campusListData release];
    [_employListData release];
    [_employData release];
    [_runningRequest release];
    [_employId release];
    [_companyId release];
    [_lbInterviewNotice release];
    [_lbJobInvite release];
    [_lbCpAttention release];
    [super dealloc];
}
@end

