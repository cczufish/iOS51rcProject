#import <UIKit/UIKit.h>
#import "ScrollPageViewDelegate.h"
#import "CommonSearchJobViewController.h"
#import "CommonFavorityViewController.h"
#import "CommonApplyJobViewController.h"
#import "GoJobSearchResultListFromScrollPageDelegate.h"//
#import "GoJobSearchResultListViewDelegate.h"//从搜索界面到scroll界面
#import "RMSearchJobListViewController.h"
#import "InviteJobsFromApplyViewDelegate.h"
#import "InviteJobsFromFavorityViewDelegate.h"

@interface RMScrollPageView : UIView<UIScrollViewDelegate, GoJobSearchResultListViewDelegate, InviteJobsFromApplyViewDelegate, InviteJobsFromFavorityViewDelegate>
{
    NSInteger mCurrentPage;
    BOOL mNeedUseDelegate;
    NSMutableArray *newsTypeArray;
    id<GoJobSearchResultListFromScrollPageDelegate> gotoSearchResultViewDelegate;
}
@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,retain) NSMutableArray *contentItems;//外部传入所包含的多个页面
@property (nonatomic,assign) id<ScrollPageViewDelegate> delegate;

@property (retain,nonatomic) id<GoJobSearchResultListFromScrollPageDelegate> gotoSearchResultViewDelegate;
#pragma mark 添加ScrollowViewd的ContentView
-(void)setContentOfTables:(NSInteger)aNumerOfTables;
#pragma mark 滑动到某个页面
-(void)moveScrollowViewAthIndex:(NSInteger)aIndex;
#pragma mark 刷新某个页面
-(void)freshContentTableAtIndex:(NSInteger)aIndex;
@end


