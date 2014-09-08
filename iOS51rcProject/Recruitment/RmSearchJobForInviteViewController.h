#import <UIKit/UIKit.h>
#import "SearchViewController.h"
#import "GoJobSearchResultListViewDelegate.h"
#import "MenuHrizontal.h"
#import "RMScrollPageView.h"
#import "GoJobSearchResultListFromScrollPageDelegate.h"

@interface RmSearchJobForInviteViewController: UIViewController <MenuHrizontalDelegate,ScrollPageViewDelegate, GoJobSearchResultListFromScrollPageDelegate>
{
    MenuHrizontal *mMenuHriZontal;
    RMScrollPageView *mScrollPageView;    
}
//招聘会的信息
@property (retain,nonatomic) NSString* strBeginTime;
@property (retain,nonatomic) NSString* strAddress;
@property (retain,nonatomic) NSString* strPlace;
@property (retain,nonatomic) NSString* rmID;
@end
