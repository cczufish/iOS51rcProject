
#import <UIKit/UIKit.h>
#import "MenuHrizontal.h"
//#import "ScrollPageView.h"
#import "EiScrollPageView.h"
@interface EIMainViewController : UIViewController <MenuHrizontalDelegate,ScrollPageViewDelegate>
{
    MenuHrizontal *mMenuHriZontal;
    EiScrollPageView *mScrollPageView;
}
@end
