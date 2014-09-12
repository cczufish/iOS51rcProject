#import <UIKit/UIKit.h>
#import "ScrollPageViewDelegate.h"
//职位列表的滚动页面
@interface JobMainScrollViewController :  UIView<UIScrollViewDelegate>
{
    NSInteger mCurrentPage;
    BOOL mNeedUseDelegate;
    NSMutableArray *newsTypeArray;
    //id<GoJobSearchResultListFromScrollPageDelegate> gotoSearchResultViewDelegate;
}
@property (nonatomic,retain) UIScrollView *scrollView;
@property (nonatomic,retain) NSMutableArray *contentItems;//外部传入所包含的多个页面
@property (nonatomic,assign) id<ScrollPageViewDelegate> delegate;
@property (nonatomic, retain) NSString *JobID;
@property (nonatomic, retain) NSString *cpMainID;
//@property (retain,nonatomic) id<GoJobSearchResultListFromScrollPageDelegate> gotoSearchResultViewDelegate;
#pragma mark 添加ScrollowViewd的ContentView
-(void)setContentOfTables:(NSInteger)aNumerOfTables;
#pragma mark 滑动到某个页面
-(void)moveScrollowViewAthIndex:(NSInteger)aIndex;
#pragma mark 刷新某个页面
-(void)freshContentTableAtIndex:(NSInteger)aIndex;
@end
