#import "WelcomeViewController.h"
#import "WelcomeUIImage.h"
#import "HomeViewController.h"

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController


#define HEIGHT [[UIScreen mainScreen] bounds].size.height
#define SAWTOOTH_COUNT 10
#define SAWTOOTH_WIDTH_FACTOR 20 

//@synthesize indexView;
@synthesize left = _left;
@synthesize right = _right;
@synthesize pageScroll;
@synthesize pageControl;
@synthesize gotoMainViewBtn;

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
	
    self.view.backgroundColor = [UIColor whiteColor];
    
    pageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, HEIGHT)];
    pageScroll.contentSize = CGSizeMake(4*320, HEIGHT);
    pageScroll.pagingEnabled = YES;
    pageScroll.delegate = self;
    [pageScroll setShowsHorizontalScrollIndicator:NO];
    
    //欢迎页（切换）
    UIImageView * imageView1 = [[UIImageView alloc]init];
    UIImageView * imageView2 = [[UIImageView alloc]init];
    UIImageView * imageView3 = [[UIImageView alloc]init];
    UIImageView * imageView4 = [[UIImageView alloc]init];
    //每一个图片的位置
    imageView1.frame = CGRectMake(0*320, 0, 320, HEIGHT);
    imageView2.frame = CGRectMake(1*320, 0, 320, HEIGHT);
    imageView3.frame = CGRectMake(2*320, 0, 320, HEIGHT);
    imageView4.frame = CGRectMake(3*320, 0, 320, HEIGHT);
    //添加图片
    if (HEIGHT == 568) {
        //self.indexView.image = [UIImage imageNamed:@"index640x1136.png"];
        imageView1.image = [UIImage imageNamed:@"welcom2-320x1136.png"];
        imageView2.image = [UIImage imageNamed:@"welcom3-320x1136.png"];
        imageView3.image = [UIImage imageNamed:@"welcom4-320x1136.png"];
        imageView4.image = [UIImage imageNamed:@"welcom5-320x1136.png"];
    }
    else{
        //self.indexView.image = [UIImage imageNamed:@"index640x960.png"];
        imageView1.image = [UIImage imageNamed:@"welcom2-320x960.png"];
        imageView2.image = [UIImage imageNamed:@"welcom3-320x960.png"];
        imageView3.image = [UIImage imageNamed:@"welcom4-320x960.png"];
        imageView4.image = [UIImage imageNamed:@"welcom5-320x960.png"];
    }
    //创建最后一个点击按钮
    self.gotoMainViewBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.gotoMainViewBtn.frame = CGRectMake(3*320+110, HEIGHT-100, 100, 80);//在第四个页面上
    [self.gotoMainViewBtn setTitle:@"" forState:UIControlStateNormal];
    [self.gotoMainViewBtn addTarget:self action:@selector(gotoMainView:) forControlEvents:UIControlEventTouchUpInside];
    
    for(int i = 0; i < 4; ++ i )
    {
        if( i == 0 )
        {
            [pageScroll addSubview:imageView1];
        }
        else if( i == 1 )
        {
            [pageScroll addSubview:imageView2];
        }
        else if( i == 2 )
        {
            [pageScroll addSubview:imageView3];
        }
        else if( i == 3 )
        {
            [pageScroll addSubview:imageView4];
            [pageScroll addSubview:self.gotoMainViewBtn];
        }
    }
    
    [self.view addSubview:pageScroll];
    
    pageControl = [[UIPageControl alloc] init];
    pageControl.frame = CGRectMake(141,364,50,50);
    [pageControl setNumberOfPages:4];
    pageControl.currentPage = 0;
    [pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:pageControl];
}


-(void)animationDidStop:(NSString *)animationID finished:(NSNumber*)finished context:(void*)context
{
    if( [animationID isEqualToString:@"split"] && finished )
    {
        [pageScroll removeFromSuperview];
    }
}

-(void)gotoMainView:(id)sender
{
    NSLog(@"登录");
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    HomeViewController *homeCtrl = (HomeViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"HomeView"];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    pageControl.currentPage = offset.x/320 ;
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    pageControl.currentPage = offset.x / 320;
}


-(void)pageTurn:(UIPageControl*)aPageControl
{
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end





































