#import "JobMainScrollViewController.h"
//#import "JobDetailsController.h"
#import "JobViewController.h"
#import "CpMainViewController.h"
#import "CpJobsViewController.h"

@implementation JobMainScrollViewController
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
    //self.autoresizesSubviews = true;
    //.automaticallyAdjustsScrollViewInsets = NO;
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
    //RmSearchJobForInviteViewController *fatherCtrl = (RmSearchJobForInviteViewController*) [self getFatherController];
    
    UIStoryboard *CpAndJobStoryBoard = [UIStoryboard storyboardWithName:@"CpAndJob" bundle:nil];
    CpJobsViewController *otherJobsCtrl = [CpAndJobStoryBoard instantiateViewControllerWithIdentifier:@"CpJobsView"];
    otherJobsCtrl.cpMainID = self.cpMainID;
    int h = otherJobsCtrl.view.frame.size.height;
    otherJobsCtrl.view.frame = CGRectMake(640, 0, 320, h);
    _scrollView.alwaysBounceVertical = NO;
    [_scrollView addSubview:otherJobsCtrl.view];
    [_contentItems addObject:otherJobsCtrl.view];
    [otherJobsCtrl retain];
    
    CpMainViewController *cpMainCtrl = [CpAndJobStoryBoard instantiateViewControllerWithIdentifier:@"CpMainView"];
    cpMainCtrl.cpMainID = self.cpMainID;
    cpMainCtrl.view.frame = CGRectMake(320, 0, 320, cpMainCtrl.view.frame.size.height) ;
    [_scrollView addSubview:cpMainCtrl.view];
    [_contentItems addObject:cpMainCtrl.view];
    [cpMainCtrl retain];
    
    JobViewController *jobCtrl = [CpAndJobStoryBoard instantiateViewControllerWithIdentifier:@"JobView"];    
    jobCtrl.JobID = self.JobID;
    jobCtrl.height = h;
    jobCtrl.view.frame = CGRectMake(0, 0, 320, jobCtrl.view.frame.size.height) ;
    [_scrollView addSubview:jobCtrl.view];
    [_contentItems addObject:jobCtrl.view];
    [jobCtrl retain];
    _scrollView.showsVerticalScrollIndicator = NO;
    //int frameHeight = self.frame.size.height;
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

