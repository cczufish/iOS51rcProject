#import "SuperJobMainViewController.h"

#define MENUHEIHT 40
@interface SuperJobMainViewController ()
//@property (retain, nonatomic) CommonSearchJobViewController  *searchViewCtrl;
@end

@implementation SuperJobMainViewController

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
                                    TITLEKEY:@"职位详情",
                                    TITLEWIDTH:[NSNumber numberWithFloat:107]
                                    },
                                  @{NOMALKEY: @"normal.png",
                                    HEIGHTKEY:@"ico_EI_Background_width107.png",
                                    TITLEKEY:@"公司信息",
                                    TITLEWIDTH:[NSNumber numberWithFloat:106]
                                    },
                                  @{NOMALKEY: @"normal",
                                    HEIGHTKEY:@"ico_EI_Background_width107.png",
                                    TITLEKEY:@"其他职位",
                                    TITLEWIDTH:[NSNumber numberWithFloat:107]
                                    },
                                  ];
    
    if (mMenuHriZontal == nil) {
        mMenuHriZontal = [[MenuHrizontal alloc] initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, MENUHEIHT) ButtonItems:vButtonItemArray];
        mMenuHriZontal.delegate = self;
    }
    //初始化滑动列表
    if (mScrollPageView == nil) {
        mScrollPageView = [[JobMainScrollViewController alloc] initWithFrame:CGRectMake(0, 60 + MENUHEIHT, self.view.frame.size.width, self.view.frame.size.height - MENUHEIHT)];
        //向子页面传参
        mScrollPageView.JobID = self.JobID;
        mScrollPageView.cpMainID = self.cpMainID;
        mScrollPageView.delegate = self;
    }
    //初始化多个页面，添加入滚动的列表里
    [mScrollPageView setContentOfTables:vButtonItemArray.count];
    //mScrollPageView.gotoSearchResultViewDelegate = self;
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
