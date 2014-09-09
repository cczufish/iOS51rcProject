#import <UIKit/UIKit.h>
#import "ScrollPageViewDelegate.h"
#import "SearchViewByTypeDelegate.h"
#import "GoToEIItemDetailsViewDelegate.h"
#import "GoToEiItemDetailsViewFromScrollViewDelegate.h"
@interface EiScrollPageView : UIView<UIScrollViewDelegate, GoToEIItemDetailsViewDelegate>
{
    NSInteger mCurrentPage;
    BOOL mNeedUseDelegate;
    NSMutableArray *newsTypeArray;
    id<GoToEiItemDetailsViewFromScrollViewDelegate> gotoDetailsView;
}
@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,retain) NSMutableArray *contentItems;//外部传入所包含的多个页面
@property (nonatomic,assign) id<ScrollPageViewDelegate> delegate;
@property (retain,nonatomic) id<GoToEiItemDetailsViewFromScrollViewDelegate> gotoDetailsView;
#pragma mark 添加ScrollowViewd的ContentView
-(void)setContentOfTables:(NSInteger)aNumerOfTables;
#pragma mark 滑动到某个页面
-(void)moveScrollowViewAthIndex:(NSInteger)aIndex;
#pragma mark 刷新某个页面
-(void)freshContentTableAtIndex:(NSInteger)aIndex;
@end

