#import "RmSearchJobForInviteViewController.h"
#import "CommonSearchJobViewController.h"
#import "RmInviteCpListFromSearchViewController.h"
#import "RMSearchJobListViewController.h"
#define MENUHEIHT 40
@interface RmSearchJobForInviteViewController ()
@property (retain, nonatomic) CommonSearchJobViewController  *searchViewCtrl;
@end

@implementation RmSearchJobForInviteViewController

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
    [self commInit];
}

-(void)commInit{
    NSArray *vButtonItemArray = @[@{NOMALKEY: @"normal.png",
                                    HEIGHTKEY:@"ico_EI_Background_width107.png",
                                    TITLEKEY:@"搜索的职位",
                                    TITLEWIDTH:[NSNumber numberWithFloat:107]
                                    },
                                  @{NOMALKEY: @"normal.png",
                                    HEIGHTKEY:@"ico_EI_Background_width107.png",
                                    TITLEKEY:@"申请的职位",
                                    TITLEWIDTH:[NSNumber numberWithFloat:106]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"ico_EI_Background_width107.png",
                                    TITLEKEY:@"收藏的职位",
                                    TITLEWIDTH:[NSNumber numberWithFloat:107]
                                    },
                                  ];
    
    if (mMenuHriZontal == nil) {
        mMenuHriZontal = [[MenuHrizontal alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, MENUHEIHT) ButtonItems:vButtonItemArray];
        mMenuHriZontal.delegate = self;
    }
    //初始化滑动列表
    if (mScrollPageView == nil) {
        mScrollPageView = [[RMScrollPageView alloc] initWithFrame:CGRectMake(0, 60 + MENUHEIHT, self.view.frame.size.width, self.view.frame.size.height - MENUHEIHT)];
        mScrollPageView.delegate = self;
    }
    //初始化多个页面，添加入滚动的列表里
    [mScrollPageView setContentOfTables:vButtonItemArray.count];
    mScrollPageView.gotoSearchResultViewDelegate = self;
    //默认选中第一个button
    [mMenuHriZontal clickButtonAtIndex:0];
    //-------
    [self.view addSubview:mScrollPageView];
    [self.view addSubview:mMenuHriZontal];
}
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

//搜索职位的代理
-(void) GoJobSearchResultListFromScrollPage:(NSString *)strSearchRegion SearchJobType:(NSString *)strSearchJobType SearchIndustry:(NSString *)strSearchIndustry SearchKeyword:(NSString *)strSearchKeyword SearchRegionName:(NSString *)strSearchRegionName SearchJobTypeName:(NSString *)strSearchJobTypeName SearchCondition:(NSString *)strSearchCondition{
    RMSearchJobListViewController *jobList = [self.storyboard instantiateViewControllerWithIdentifier: @"RMSearchJobListView"];
    jobList.searchRegion = strSearchRegion;
    jobList.searchJobType = strSearchJobType;
    jobList.searchIndustry = strSearchIndustry;
    jobList.searchKeyword = strSearchKeyword;
    jobList.searchRegionName = strSearchRegionName;
    jobList.searchJobTypeName = strSearchJobTypeName;
    jobList.searchCondition = strSearchCondition;
    //招聘会的基本信息
    jobList.strPlace = self.strPlace;
    jobList.strAddress = self.strAddress;
    jobList.strBeginTime = self.strBeginTime;
    jobList.rmID = self.rmID;
    [self.navigationController pushViewController:jobList animated:true];
    
}

-(void) gotoJobSearchResultListView:(NSString*) strSearchRegion SearchJobType:(NSString*) strSearchJobType SearchIndustry:(NSString *) strSearchIndustry SearchKeyword:(NSString *) strSearchKeyword SearchRegionName:(NSString *) strSearchRegionName SearchJobTypeName:(NSString *) strSearchJobTypeName SearchCondition:(NSString *) strSearchCondition{
    RMSearchJobListViewController *jobList = [self.storyboard instantiateViewControllerWithIdentifier: @"RMSearchJobListView"];
      jobList.searchRegion = strSearchRegion;
      jobList.searchJobType = strSearchJobType;
      jobList.searchIndustry = strSearchIndustry;
      jobList.searchKeyword = strSearchKeyword;
      jobList.searchRegionName = strSearchRegionName;
      jobList.searchJobTypeName = strSearchJobTypeName;
      jobList.searchCondition = strSearchCondition;
      [self.navigationController pushViewController:jobList animated:true];
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

@end
