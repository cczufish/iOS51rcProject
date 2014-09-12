#import <UIKit/UIKit.h>
#import "MenuHrizontal.h"
#import "JobMainScrollViewController.h"

@interface SuperJobMainViewController : UIViewController <MenuHrizontalDelegate,ScrollPageViewDelegate>
{
    MenuHrizontal *mMenuHriZontal;
    JobMainScrollViewController *mScrollPageView;
}

@property (retain, nonatomic) NSString *JobID;
@property (retain, nonatomic) NSString *cpMainID;
@end
