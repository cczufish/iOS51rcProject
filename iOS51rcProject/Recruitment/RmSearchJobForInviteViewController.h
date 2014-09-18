#import <UIKit/UIKit.h>
#import "GoJobSearchResultListViewDelegate.h"
#import "InviteJobsFromApplyViewDelegate.h"
#import "InviteJobsFromFavorityViewDelegate.h"
@interface RmSearchJobForInviteViewController: UIViewController<GoJobSearchResultListViewDelegate,InviteJobsFromApplyViewDelegate, InviteJobsFromFavorityViewDelegate>
{
    //是否是第一次加载
    BOOL firstPageLoad;
    BOOL secondPageLoad;
    BOOL thriePageLoad;
}
//招聘会的信息
@property (retain,nonatomic) NSString* strBeginTime;
@property (retain,nonatomic) NSString* strAddress;
@property (retain,nonatomic) NSString* strPlace;
@property (retain,nonatomic) NSString* rmID;
@end
