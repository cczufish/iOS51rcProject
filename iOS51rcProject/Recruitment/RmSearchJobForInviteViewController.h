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
@end
