
#import "RMScrollPageView.h"

@implementation RMScrollPageView

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
     UIStoryboard *rmStoryBoard = [UIStoryboard storyboardWithName:@"Recruitment" bundle:nil];
    CommonFavorityViewController *favorityCtrl = [rmStoryBoard instantiateViewControllerWithIdentifier:@"CommonFavorityView"];
    favorityCtrl.view.frame = CGRectMake(640, 0, 320, favorityCtrl.view.frame.size.height);
    [_scrollView addSubview:favorityCtrl.view];
    [_contentItems addObject:favorityCtrl.view];
    [favorityCtrl retain];
    
    CommonApplyJobViewController *applyCtrl = [rmStoryBoard instantiateViewControllerWithIdentifier:@"CommonApplyJobView"];
    applyCtrl.view.frame = CGRectMake(320, 0, 320, applyCtrl.view.frame.size.height) ;
    [_scrollView addSubview:applyCtrl.view];
    [_contentItems addObject:applyCtrl.view];
    [applyCtrl retain];
    
    CommonSearchJobViewController *searchCtrl = [rmStoryBoard instantiateViewControllerWithIdentifier:@"CommonSearchJobView"];
    [_scrollView addSubview:searchCtrl.view];
    [_contentItems addObject:searchCtrl.view];
    [searchCtrl retain];
    
    [_scrollView setContentSize:CGSizeMake(320 * 3, self.frame.size.height)];
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
    if (aIndex == 0) {
        //CommonSearchJobViewController *searchCtrl = (CommonSearchJobViewController*)[_contentItems objectAtIndex:aIndex];
    }else if(aIndex == 1){
         //CommonApplyJobViewController *applyCtrl = (CommonApplyJobViewController*)[_contentItems objectAtIndex:aIndex];
    }else if(aIndex == 2){
         //CommonFavorityViewController *favorityCtrl = (CommonFavorityViewController*)[_contentItems objectAtIndex:aIndex];
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


@end

