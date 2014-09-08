#import <UIKit/UIKit.h>
#import "SearchViewController.h"
#import "GoJobSearchResultListViewDelegate.h"
#import "MenuHrizontal.h"
#import "RMScrollPageView.h"

@interface RmSearchJobForInviteViewController: UIViewController <MenuHrizontalDelegate,ScrollPageViewDelegate,GoJobSearchResultListViewDelegate>
{
    MenuHrizontal *mMenuHriZontal;
    RMScrollPageView *mScrollPageView;
}
@end
