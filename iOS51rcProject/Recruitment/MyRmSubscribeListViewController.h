
#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"
#import "GoToRmViewDetailDelegate.h"
#import "GoToMyInvitedCpViewDelegate.h"
//我的预约
@interface MyRmSubscribeListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{   
    NSMutableArray *recruitmentCpData;   
    LoadingAnimationView *loadView;
    NSMutableArray *checkedCpArray;
    id<GoToRmViewDetailDelegate> gotoRmViewDelegate;
    id<GoToMyInvitedCpViewDelegate> gotoMyInvitedCpViewDelegate;
}
@property (retain, nonatomic) id<GoToRmViewDetailDelegate> gotoRmViewDelegate;
@property (retain, nonatomic) id<GoToMyInvitedCpViewDelegate> gotoMyInvitedCpViewDelegate;
-(void) onSearch;
@end

