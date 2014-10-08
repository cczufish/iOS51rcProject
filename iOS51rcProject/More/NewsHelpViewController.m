#import "NewsHelpViewController.h"

@interface NewsHelpViewController ()<UIScrollViewDelegate>
@property (retain, nonatomic) IBOutlet UIScrollView *pageScroll;
@property (retain, nonatomic) IBOutlet UIPageControl *pager;
@end

@implementation NewsHelpViewController
#define HEIGHT [[UIScreen mainScreen] bounds].size.height
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
	[self.navigationController setNavigationBarHidden:YES animated:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.pageScroll.delegate = self;
    self.pageScroll.directionalLockEnabled = YES;
    [self.pageScroll setShowsHorizontalScrollIndicator:NO];
     [self.pageScroll setShowsVerticalScrollIndicator:NO];
    
    //欢迎页（切换）
    UIImageView * imageView1 = [[[UIImageView alloc]init] autorelease];
    UIImageView * imageView2 = [[[UIImageView alloc]init] autorelease];
    UIImageView * imageView3 = [[[UIImageView alloc]init] autorelease];
    UIImageView * imageView4 = [[[UIImageView alloc]init] autorelease];
    //图片的位置
    imageView1.frame = CGRectMake(0*320, 0, 320, HEIGHT);
    imageView2.frame = CGRectMake(1*320, 0, 320, HEIGHT);
    imageView3.frame = CGRectMake(2*320, 0, 320, HEIGHT);
    imageView4.frame = CGRectMake(3*320, 0, 320, HEIGHT);
    //添加图片
    if (HEIGHT == 568) {
        imageView1.image = [UIImage imageNamed:@"welcome2_large.png"];
        imageView2.image = [UIImage imageNamed:@"welcome3_large.png"];
        imageView3.image = [UIImage imageNamed:@"welcome4_large.png"];
        imageView4.image = [UIImage imageNamed:@"welcome5_large.png"];
    }
    else{
        imageView1.image = [UIImage imageNamed:@"welcome2_small.png"];
        imageView2.image = [UIImage imageNamed:@"welcome3_small.png"];
        imageView3.image = [UIImage imageNamed:@"welcome4_small.png"];
        imageView4.image = [UIImage imageNamed:@"welcome5_small.png"];
    }
    
    //创建最后一个点击按钮
    UIButton *gotoMainViewBtn = [[[UIButton alloc] initWithFrame:CGRectMake(3*320+110, HEIGHT-100, 100, 80)] autorelease];//在第四个页面上
    //gotoMainViewBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [gotoMainViewBtn addTarget:self action:@selector(gotoMainView:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.pageScroll addSubview:imageView1];
    [self.pageScroll addSubview:imageView2];
    [self.pageScroll addSubview:imageView3];
    [self.pageScroll addSubview:imageView4];
    [self.pageScroll addSubview:gotoMainViewBtn];
    
    self.pageScroll.frame =CGRectMake(0, 0, 320, HEIGHT);
    self.pageScroll.contentSize = CGSizeMake(4*320, HEIGHT);
    
    //切换页面的小点
    self.pager = [[UIPageControl alloc] init];
    self.pager.frame = CGRectMake(110,474,100,50);
    [self.pager setNumberOfPages:4];
    self.pager.currentPage = 0;
    self.pager.currentPageIndicatorTintColor = [UIColor blackColor];
    self.pager.pageIndicatorTintColor   = [UIColor grayColor];
    [self.pager addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.pager];
}

-(void)pageTurn:(UIPageControl*)aPageControl
{
    CGRect frame = self.pageScroll.frame;
    frame.origin.x = frame.size.width * aPageControl.currentPage;
    frame.origin.y = 0;
    [self.pageScroll scrollRectToVisible:frame animated:YES];
}

//返回上一页面
-(void)gotoMainView:(id)sender
{
    NSLog(@"返回");
    [self.navigationController popViewControllerAnimated:true];
    [self.navigationController setNavigationBarHidden:false];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    self.pager.currentPage = offset.x/320 ;
    //pageControl.currentPage = offset.x/320 ;
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    self.pager.currentPage = offset.x / 320;
    //pageControl.currentPage = offset.x/320 ;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [_pager release];
    [super dealloc];
}
@end

