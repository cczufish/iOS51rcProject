
#import <UIKit/UIKit.h>
#import "MenuHrizontal.h"
//#import "ScrollPageView.h"
#import "EiScrollPageView.h"
#import "GoToEIItemDetailsViewDelegate.h"
#import "GoToEiItemDetailsViewFromScrollViewDelegate.h"
@interface EIMainViewController : UIViewController <MenuHrizontalDelegate,ScrollPageViewDelegate, GoToEiItemDetailsViewFromScrollViewDelegate>
{
    MenuHrizontal *mMenuHriZontal;
    EiScrollPageView *mScrollPageView;
}
@end
