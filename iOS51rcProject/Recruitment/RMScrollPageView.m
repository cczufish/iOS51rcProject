#import "RmInviteCpListFromSearchViewController.h"
#import "RMScrollPageView.h"
#import "RmSearchJobForInviteViewController.h"
#import "RmInviteCpViewController.h"

@implementation RMScrollPageView
@synthesize gotoSearchResultViewDelegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        mNeedUseDelegate = YES;
        [self commInit];
    }
    return self;
}

-(void)initData{
    [self freshContentTableAtIndex:0];
}


-(void)commInit{
    if (_contentItems == nil) {
        _contentItems = [[NSMutableArray alloc] init];
    }
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        NSLog(@"ScrollViewFrame:(%f,%f)",self.frame.size.width,self.frame.size.height);
        _scrollView.pagingEnabled = YES;
        
        _scrollView.delegate = self;
    }
    [self addSubview:_scrollView];
}

-(void)dealloc{
    [_contentItems removeAllObjects],[_contentItems release],_contentItems= nil;
    [_scrollView release];
    [super dealloc];
}

#pragma mark - 其他辅助功能
#pragma mark 添加包含的子View,3个页面，搜索的职位页面，申请的职位页面，收藏的职位页面
-(void)setContentOfTables:(NSInteger)aNumerOfTables{
    RmSearchJobForInviteViewController *fatherCtrl = (RmSearchJobForInviteViewController*) [self getFatherController];
    
     UIStoryboard *rmStoryBoard = [UIStoryboard storyboardWithName:@"Recruitment" bundle:nil];
    CommonFavorityViewController *favorityCtrl = [rmStoryBoard instantiateViewControllerWithIdentifier:@"CommonFavorityView"];
    favorityCtrl.strBeginTime = fatherCtrl.strBeginTime;
    favorityCtrl.strAddress = fatherCtrl.strAddress;
    favorityCtrl.strPlace = fatherCtrl.strPlace;
    favorityCtrl.rmID = fatherCtrl.rmID;
    favorityCtrl.InviteJobsFromFavorityViewDelegate = self;
    int h = favorityCtrl.view.frame.size.height;
    favorityCtrl.view.frame = CGRectMake(640, 0, 320, h);
    [_scrollView addSubview:favorityCtrl.view];
    [_contentItems addObject:favorityCtrl.view];
    [favorityCtrl retain];
   
    CommonApplyJobViewController *applyCtrl = [rmStoryBoard instantiateViewControllerWithIdentifier:@"CommonApplyJobView"];
    applyCtrl.strBeginTime = fatherCtrl.strBeginTime;
    applyCtrl.strAddress = fatherCtrl.strAddress;
    applyCtrl.strPlace = fatherCtrl.strPlace;
    applyCtrl.rmID = fatherCtrl.rmID;
    applyCtrl.inviteFromApplyViewDelegate = self;
    applyCtrl.view.frame = CGRectMake(320, 0, 320, applyCtrl.view.frame.size.height) ;
    [_scrollView addSubview:applyCtrl.view];
    [_contentItems addObject:applyCtrl.view];
    [applyCtrl retain];
    
    CommonSearchJobViewController *searchCtrl = [rmStoryBoard instantiateViewControllerWithIdentifier:@"CommonSearchJobView"];
    searchCtrl.view.frame = CGRectMake(0, 0, 320, searchCtrl.view.frame.size.height) ;
    searchCtrl.searchDelegate = self;
    [_scrollView addSubview:searchCtrl.view];
    [_contentItems addObject:searchCtrl.view];
    [searchCtrl retain];
    //_scrollView.showsVerticalScrollIndicator = false;
    int frameHeight = self.frame.size.height;
    [_scrollView setContentSize:CGSizeMake(320 * 3, h)];
}

#pragma mark 移动ScrollView到某个页面
-(void)moveScrollowViewAthIndex:(NSInteger)aIndex{
    mNeedUseDelegate = NO;
    CGRect vMoveRect = CGRectMake(self.frame.size.width * aIndex, 0, self.frame.size.width, self.frame.size.width);
    [_scrollView scrollRectToVisible:vMoveRect animated:YES];
    mCurrentPage= aIndex;
    if ([_delegate respondsToSelector:@selector(didScrollPageViewChangedPage:)]) {
        [_delegate didScrollPageViewChangedPage:mCurrentPage];
    }
}

#pragma mark 刷新某个页面
-(void)freshContentTableAtIndex:(NSInteger)aIndex{
    if (_contentItems.count < aIndex) {
        return;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    mNeedUseDelegate = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int page = (_scrollView.contentOffset.x+320/2.0) / 320;
    if (mCurrentPage == page) {
        return;
    }
    mCurrentPage= page;
    if ([_delegate respondsToSelector:@selector(didScrollPageViewChangedPage:)] && mNeedUseDelegate) {
        [_delegate didScrollPageViewChangedPage:mCurrentPage];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        
    }
}
//收藏职位页面的代理
-(void) InviteJobsFromFavorityView:(NSMutableArray *)checkedCps{
    //得到父View
    RmSearchJobForInviteViewController *fatherCtrl = (RmSearchJobForInviteViewController*)[self getFatherController];
    UIStoryboard *rmStoryboard = [UIStoryboard storyboardWithName:@"Recruitment" bundle:nil];
    RmInviteCpViewController *rmInviteCpViewCtrl = [rmStoryboard instantiateViewControllerWithIdentifier:@"RmInviteCpView"];
    rmInviteCpViewCtrl.strBeginTime = fatherCtrl.strBeginTime;
    rmInviteCpViewCtrl.strAddress = fatherCtrl.strAddress;
    rmInviteCpViewCtrl.strPlace = fatherCtrl.strPlace;
    rmInviteCpViewCtrl.strRmID = fatherCtrl.rmID;
    rmInviteCpViewCtrl.selectRmCps = checkedCps;
    
    [fatherCtrl.navigationController pushViewController:rmInviteCpViewCtrl animated:YES];
}

//搜索职位的代理(直接在本页面会报错，所以跳转到父View再Navagation)
-(void) gotoJobSearchResultListView:(NSString*) strSearchRegion SearchJobType:(NSString*) strSearchJobType SearchIndustry:(NSString *) strSearchIndustry SearchKeyword:(NSString *) strSearchKeyword SearchRegionName:(NSString *) strSearchRegionName SearchJobTypeName:(NSString *) strSearchJobTypeName SearchCondition:(NSString *) strSearchCondition{
    
    if (strSearchJobType == nil) {
        strSearchJobType = @"";
    }
    if (strSearchIndustry == nil) {
        strSearchIndustry = @"";
    }
    NSLog(@"%@，%@，%@，%@，%@，%@，%@", strSearchRegion, strSearchJobType, strSearchIndustry, strSearchKeyword, strSearchRegionName, strSearchJobTypeName, strSearchCondition);
    [self.gotoSearchResultViewDelegate GoJobSearchResultListFromScrollPage: strSearchRegion SearchJobType:strSearchJobType SearchIndustry:strSearchIndustry SearchKeyword:strSearchKeyword SearchRegionName:strSearchRegionName SearchJobTypeName:strSearchJobTypeName SearchCondition:strSearchCondition];
}

//申请职位页面的代理代理
-(void) InviteJobsFromApplyView:(NSMutableArray *)checkedCps{
    //得到父View
    RmSearchJobForInviteViewController *fatherCtrl = (RmSearchJobForInviteViewController*)[self getFatherController];
    UIStoryboard *rmStoryboard = [UIStoryboard storyboardWithName:@"Recruitment" bundle:nil];
    RmInviteCpViewController *rmInviteCpViewCtrl = [rmStoryboard instantiateViewControllerWithIdentifier:@"RmInviteCpView"];
    rmInviteCpViewCtrl.strBeginTime = fatherCtrl.strBeginTime;
    rmInviteCpViewCtrl.strAddress = fatherCtrl.strAddress;
    rmInviteCpViewCtrl.strPlace = fatherCtrl.strPlace;
    rmInviteCpViewCtrl.strRmID = fatherCtrl.rmID;
    rmInviteCpViewCtrl.selectRmCps = checkedCps;
    
    [fatherCtrl.navigationController pushViewController:rmInviteCpViewCtrl animated:YES];
}

//得到父View
- (UIViewController *)getFatherController
{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    
    return nil;
}
@end

