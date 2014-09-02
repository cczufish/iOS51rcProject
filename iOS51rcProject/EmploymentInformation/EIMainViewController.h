
#import <UIKit/UIKit.h>
#import "MenuHrizontal.h"
#import "ScrollPageView.h"
//
@interface EIMainViewController : UIViewController <MenuHrizontalDelegate,ScrollPageViewDelegate>
{
    MenuHrizontal *mMenuHriZontal;
    ScrollPageView *mScrollPageView;
}
@end
