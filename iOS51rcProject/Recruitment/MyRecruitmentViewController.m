#import "MyRecruitmentViewController.h"
#import "RecruitmentViewController.h"
#import "MyRmInviteCpListViewController.h"
#import "RmInviteCpViewController.h"

@interface MyRecruitmentViewController ()<UIScrollViewDelegate>
{
    BOOL firstPageLoad;
    BOOL secondPageLoad;
}
@property (retain, nonatomic) IBOutlet UILabel *lbBgLeft;
@property (retain, nonatomic) IBOutlet UIButton *btnInvitation;//右
@property (retain, nonatomic) IBOutlet UIButton *btnMyRm;//左
@property (retain, nonatomic) IBOutlet UILabel *lbBackLine;//横线
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;//滑动

@end

@implementation MyRecruitmentViewController
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
    //上方横线
    self.lbBgLeft.layer.backgroundColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1].CGColor;
    self.lbBackLine.frame = CGRectMake(self.lbBackLine.frame.origin.x, self.lbBackLine.frame.origin.y, 320, 0.5);
    self.lbBackLine.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    self.btnInvitation.titleLabel.textColor = [UIColor blackColor];
   
    //获得子View
    self.myRmSubscribeListViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MyRmSubscribeListView"];
    self.myRmReceiveInvitationListViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MyRmReceivedInvitationView"];
    self.myRmSubscribeListViewCtrl.view.frame = CGRectMake(0, 0, 320, self.scrollView.frame.size.height);
    self.myRmReceiveInvitationListViewCtrl.view.frame = CGRectMake(320, 0, 320, self.scrollView.frame.size.height);
    
    //代理
    self.scrollView.delegate = self;
    self.myRmSubscribeListViewCtrl.gotoRmViewDelegate = self;
    self.myRmSubscribeListViewCtrl.gotoMyInvitedCpViewDelegate = self;
    //把三个子View加到Scrollview中
    [self.scrollView addSubview:self.myRmSubscribeListViewCtrl.view];
    [self.scrollView addSubview:self.myRmReceiveInvitationListViewCtrl.view];
    [self.myRmSubscribeListViewCtrl onSearch];//先加载第一个页面
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.scrollView setContentSize:CGSizeMake(640, self.scrollView.frame.size.height)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollView.contentOffset.x > 160) {
        [self switchToSecondView:nil];
    }
    else {
        [self switchToFirstView:nil];
    }
}


- (IBAction)switchToFirstView:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:true];
    if (!firstPageLoad) {
        [self.myRmSubscribeListViewCtrl onSearch];
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.lbBgLeft.frame = CGRectMake(0, self.lbBgLeft.frame.origin.y, 160, self.lbBgLeft.frame.size.height);
        self.lbBgLeft.backgroundColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
        self.btnMyRm.titleLabel.textColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
        self.btnInvitation.titleLabel.textColor = [UIColor blackColor];
    } completion:^(BOOL finished) {
        firstPageLoad = true;
    }];
}

- (IBAction)switchToSecondView:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(320, 0) animated:true];
    if (!secondPageLoad) {
        [self.myRmReceiveInvitationListViewCtrl onSearch];
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.lbBgLeft.frame = CGRectMake(160, self.lbBgLeft.frame.origin.y, 160, self.lbBgLeft.frame.size.height);
        self.lbBgLeft.backgroundColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
        self.btnMyRm.titleLabel.textColor = [UIColor blackColor];
        self.btnInvitation.titleLabel.textColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
    } completion:^(BOOL finished) {
        secondPageLoad = true;
    }];
}

//从我的预约页面到招聘会详情页面
-(void) gotoRmView:(NSString *) rmID
{
    RecruitmentViewController *rmViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"RecruitmentView"];
    rmViewCtrl.recruitmentID = rmID;
    [self.navigationController pushViewController:rmViewCtrl animated:true];
}

//从我的预约页面到我邀请的企业页面
-(void) GoToMyInvitedCpView:(NSString *) paMainID
{
    MyRmInviteCpListViewController *rmViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MyRmInviteCpListView"];
    [self.navigationController pushViewController:rmViewCtrl animated:true];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_lbBgLeft release];
    [_btnInvitation release];
    [_btnMyRm release];
    [_lbBackLine release];
    [_scrollView release];
    [super dealloc];
}
@end
