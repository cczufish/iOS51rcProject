#import "SuperCpViewController.h"
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
    //设置滚动条的大小
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.svSuper.frame = CGRectMake(0, 115, 320, self.svSuper.frame.size.height);//必须重写位置，否则，子页面的x＝0.。。
    
    self.svSuper.delegate = self;
    [self.svSuper setScrollEnabled:YES];
   
    //加载子View
    self.cpInfoCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"CpMainView"];
    self.cpInfoCtrl.cpMainID = self.cpMainID;
    self.jobsCtrl =  [self.storyboard instantiateViewControllerWithIdentifier:@"CpJobsView"];
    self.jobsCtrl.cpMainID = self.cpMainID;
   
    self.jobsCtrl.view.frame = CGRectMake(320, 0, 640, self.svSuper.frame.size.height);
    self.cpInfoCtrl.view.frame = CGRectMake(0, 0, 640, self.svSuper.frame.size.height);
    [self.svSuper addSubview:self.cpInfoCtrl.view];
    [self.svSuper addSubview:self.jobsCtrl.view];
    
    [self.svSuper setContentSize:CGSizeMake(640, self.svSuper.frame.size.height)];//这一行必须放到后面。。否则不滑动
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
            //[self.view addSubview:self.lbTopBg];
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
            //[self.view addSubview:self.lbTopBg];
        }];
    }
}
- (IBAction)swithToCpInfo:(id)sender {
    [self.svSuper setContentOffset:CGPointMake(0, 0) animated:true];
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbJobListTopTitle setTextColor:[UIColor blackColor]];
        [self.lbCpTopTitle setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbTopBg setFrame:CGRectMake(0, self.lbTopBg.frame.origin.y, self.lbTopBg.frame.size.width, self.lbTopBg.frame.size.height)];
        //[self.view addSubview:self.lbTopBg];
    }];
}
- (IBAction)switchToJobList:(id)sender {
    [self.svSuper setContentOffset:CGPointMake(320, 0) animated:true];
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbCpTopTitle setTextColor:[UIColor blackColor]];
        [self.lbJobListTopTitle setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbTopBg setFrame:CGRectMake(160, self.lbTopBg.frame.origin.y, self.lbTopBg.frame.size.width, self.lbTopBg.frame.size.height)];
        //[self.view addSubview:self.lbTopBg];
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
