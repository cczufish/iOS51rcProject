#import <UIKit/UIKit.h>
#import "MyRmReceivedInvitationViewController.h"
#import "MyRmSubscribeListViewController.h"
#import "GoToRmViewDetailDelegate.h"
#import "Delegate/GoToMyInvitedCpViewDelegate.h"

@interface MyRecruitmentViewController : UIViewController<GoToRmViewDetailDelegate, GoToMyInvitedCpViewDelegate>
{
    
}
@property (retain,nonatomic) MyRmSubscribeListViewController *myRmSubscribeListViewCtrl;
@property (retain,nonatomic) MyRmReceivedInvitationViewController *myRmReceiveInvitationListViewCtrl;
@end
