#import "EiScrollPageView.h"
#import "EIListViewController.h"
#import "EIListView.h"

@implementation EiScrollPageView
@synthesize gotoDetailsView;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
    if (newsTypeArray == nil) {
        newsTypeArray = [[NSMutableArray alloc] init];
        [CommonController getNewsType:newsTypeArray];
    }
    [self addSubview:_scrollView];
}

-(void) GoToEIItemDetailsView:(NSString *)newsID{
    [gotoDetailsView GoToEiItemDetailsViewFromScrollView:newsID];
}

-(void)dealloc{
    [_contentItems removeAllObjects],[_contentItems release],_contentItems= nil;
    [_scrollView release];
    [super dealloc];
}

#pragma mark - 其他辅助功能
#pragma mark 添加包含的子View
-(void)setContentOfTables:(NSInteger)aNumerOfTables{
    for (int i = 0; i < aNumerOfTables; i++) {
        EIListView *eiListView = [[EIListView alloc] initWithFrame:CGRectMake(320 * i, 0, 320, self.frame.size.height - 60)];
        eiListView.goToEIItemDetailsViewDelegate = self;
        [_scrollView addSubview:eiListView];
        [_contentItems addObject:eiListView];
        [eiListView release];
    }
    [_scrollView setContentSize:CGSizeMake(320 * aNumerOfTables, self.frame.size.height)];
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
    EIListView *eiListView = (EIListView*)[_contentItems objectAtIndex:aIndex];
    NSString *typeID = newsTypeArray[aIndex];
    [eiListView forceToFreshData:typeID];
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


@end
