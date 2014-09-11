#import "SuperCpViewController.h"
//企业信息父页面
@interface SuperCpViewController ()
@property (retain, nonatomic) CpJobsViewController *jobsCtrl;
@property (retain, nonatomic) CpMainViewController *cpInfoCtrl;
@property (retain, nonatomic) IBOutlet UIScrollView *svSuper;//滚动条
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
    self.svSuper.frame = CGRectMake(0, 115, 640, self.svSuper.frame.size.height);//必须重写位置，否则，子页面的x＝0.。。
    //[self.svSuper setContentSize:CGSizeMake(640, self.svSuper.frame.size.height)];
    //加载子View
    self.cpInfoCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"CpMainView"];
    self.cpInfoCtrl.cpMainID = self.cpMainID;
    self.jobsCtrl =  [self.storyboard instantiateViewControllerWithIdentifier:@"CpJobsView"];
    self.jobsCtrl.cpMainID = self.cpMainID;
    
    //self.cpInfoCtrl.view.frame = CGRectMake(0, 0, 320, self.svSuper.frame.size.height);
    //self.jobsCtrl.view.frame = CGRectMake(320, 0, 320, self.svSuper.frame.size.height);
   
    [self.svSuper addSubview:self.cpInfoCtrl.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    [_cpMainID release];
    [_cpInfoCtrl release];
    [_jobsCtrl release];
    [_svSuper release];
    [super dealloc];
}
@end
