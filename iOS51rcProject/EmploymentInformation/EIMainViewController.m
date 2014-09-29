#import "EIMainViewController.h"
#import "SlideNavigationController.h"
#import "EIItemDetailsViewController.h"
#import "EiSearchViewController.h"
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
    [myRmBtn addTarget:self action:@selector(btnKeyWordSearchClick:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imgSearch =  [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    imgSearch.image = [UIImage imageNamed:@"ico_jobnews_search.png"];
    [myRmBtn addSubview:imgSearch];
    myRmBtn.layer.borderColor=[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
    //myRmBtn.layer.borderWidth = 1;
    UIBarButtonItem *btnMyRecruitment = [[UIBarButtonItem alloc] initWithCustomView:myRmBtn];
    self.navigationItem.rightBarButtonItem=btnMyRecruitment;
    [btnMyRecruitment release];
    [myRmBtn release];
    [imgSearch release];
     [self commInit];
}
//关键字搜索资讯
-(void) btnKeyWordSearchClick:(UIButton *)sender
{
    EiSearchViewController *searchCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"EiSearchView"];
    [self.navigationController pushViewController:searchCtrl animated:YES];
}

//点击到达详细页面
-(void) GoToEiItemDetailsViewFromScrollView:(NSString *)newsID{
    UIStoryboard *eiStoryboard = [UIStoryboard storyboardWithName:@"EmploymentInformation" bundle:nil];
    EIItemDetailsViewController *detailCtrl = (EIItemDetailsViewController*)[eiStoryboard
                                                                             instantiateViewControllerWithIdentifier: @"EIItemDetailsView"];
    detailCtrl.strNewsID = newsID;
    [self.navigationController pushViewController:detailCtrl animated:YES];
}
-(void) btnMyRecruitmentClick:(UIBarButtonItem *)sender
{
    //MyRecruitmentViewController *myRmCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"MyRecruitmentView"];
    //[self.navigationController pushViewController:myRmCtrl animated:YES];
}

//#pragma mark UI初始化
-(void)commInit{
    NSArray *vButtonItemArray = @[@{NOMALKEY: @"normal.png",
                                    HEIGHTKEY:@"ico_EI_Background.png",
                                    TITLEKEY:@"最新热点",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal.png",
                                    HEIGHTKEY:@"ico_EI_Background.png",
                                    TITLEKEY:@"才市速递",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"ico_EI_Background.png",
                                    TITLEKEY:@"招聘现场",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"ico_EI_Background.png",
                                    TITLEKEY:@"培训进修",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"ico_EI_Background.png",
                                    TITLEKEY:@"薪酬福利",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"ico_EI_Background.png",
                                    TITLEKEY:@"社会保险",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"ico_EI_Background.png",
                                    TITLEKEY:@"职场江湖",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"ico_EI_Background.png",
                                    TITLEKEY:@"简历指导",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"ico_EI_Background.png",
                                    TITLEKEY:@"面试宝典",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"ico_EI_Background.png",
                                    TITLEKEY:@"职业规划",
                                    TITLEWIDTH:[NSNumber numberWithFloat:80]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"ico_EI_Background.png",
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
        mScrollPageView = [[EiScrollPageView alloc] initWithFrame:CGRectMake(0, 60 + MENUHEIHT, self.view.frame.size.width, self.view.frame.size.height - MENUHEIHT)];
        mScrollPageView.delegate = self;
    }
    //初始化多个页面，添加入滚动的列表里
    [mScrollPageView setContentOfTables:vButtonItemArray.count];
    mScrollPageView.gotoDetailsView = self;
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
    //刷新当页数据
    [mScrollPageView freshContentTableAtIndex:aPage];
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
