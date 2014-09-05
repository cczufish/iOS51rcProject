#import "EIMainViewController.h"
#import "SlideNavigationController.h"
#define MENUHEIHT 40

@interface EIMainViewController ()<SlideNavigationControllerDelegate>

@end

@implementation EIMainViewController

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
    self.navigationItem.title = @"就业资讯";
    //右侧搜索按钮
    UIButton *myRmBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [myRmBtn addTarget:self action:@selector(btnMyRecruitmentClick:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imgSearch =  [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    imgSearch.image = [UIImage imageNamed:@"ico_jobnews_search.png"];
    [myRmBtn addSubview:imgSearch];
    myRmBtn.layer.borderColor=[UIColor lightGrayColor].CGColor;
    //myRmBtn.layer.borderWidth = 1;
    UIBarButtonItem *btnMyRecruitment = [[UIBarButtonItem alloc] initWithCustomView:myRmBtn];
    self.navigationItem.rightBarButtonItem=btnMyRecruitment;
    [btnMyRecruitment release];
    [myRmBtn release];
    [imgSearch release];
     [self commInit];
}

-(void) btnMyRecruitmentClick:(UIBarButtonItem *)sender
{
    //MyRecruitmentViewController *myRmCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MyRecruitmentView"];
    //[self.navigationController pushViewController:myRmCtrl animated:YES];
}

//#pragma mark UI初始化
-(void)commInit{
    NSArray *vButtonItemArray = @[@{NOMALKEY: @"normal.png",
                                    HEIGHTKEY:@"helight.png",
                                    TITLEKEY:@"最新热点",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal.png",
                                    HEIGHTKEY:@"helight.png",
                                    TITLEKEY:@"才市速递",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"helight",
                                    TITLEKEY:@"招聘现场",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"helight",
                                    TITLEKEY:@"培训进修",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"helight",
                                    TITLEKEY:@"薪酬福利",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"helight",
                                    TITLEKEY:@"社会保险",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"helight",
                                    TITLEKEY:@"职场江湖",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"helight",
                                    TITLEKEY:@"简历指导",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"helight",
                                    TITLEKEY:@"面试宝典",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"helight",
                                    TITLEKEY:@"职业规划",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"helight",
                                    TITLEKEY:@"求职攻略",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  ];
    
    if (mMenuHriZontal == nil) {
        mMenuHriZontal = [[MenuHrizontal alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, MENUHEIHT) ButtonItems:vButtonItemArray];
        mMenuHriZontal.delegate = self;
    }
    //初始化滑动列表
    if (mScrollPageView == nil) {
        mScrollPageView = [[ScrollPageView alloc] initWithFrame:CGRectMake(0, 60 + MENUHEIHT, self.view.frame.size.width, self.view.frame.size.height - MENUHEIHT)];
        mScrollPageView.delegate = self;
    }
    [mScrollPageView setContentOfTables:vButtonItemArray.count];
    //默认选中第一个button
    [mMenuHriZontal clickButtonAtIndex:0];
    //-------
    [self.view addSubview:mScrollPageView];
    [self.view addSubview:mMenuHriZontal];
}

//#pragma mark 内存相关
-(void)dealloc{
    [mMenuHriZontal release],mMenuHriZontal = nil;
    [mScrollPageView release],mScrollPageView = nil;
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 其他辅助功能
#pragma mark MenuHrizontalDelegate
-(void)didMenuHrizontalClickedButtonAtIndex:(NSInteger)aIndex{
    NSLog(@"第%d个Button点击了",aIndex);
    [mScrollPageView moveScrollowViewAthIndex:aIndex];
}

#pragma mark ScrollPageViewDelegate
-(void)didScrollPageViewChangedPage:(NSInteger)aPage{
    NSLog(@"CurrentPage:%d",aPage);
    [mMenuHriZontal changeButtonStateAtIndex:aPage];
    //    if (aPage == 3) {
    //刷新当页数据
    [mScrollPageView freshContentTableAtIndex:aPage];
    //    }
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
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (int)slideMenuItem
{
    return 8;
}
@end