#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"
#import "GoToRmViewDetailDelegate.h"
#import "GoToMyInvitedCpViewDelegate.h"

@interface MyRmReceivedInvitationViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger selectRowIndex;
    NSMutableArray *recruitmentCpData;
    //NSString *rmID;
    LoadingAnimationView *loadView;
    NSMutableArray *checkedCpArray;
    id<GoToRmViewDetailDelegate> gotoRmViewDelegate;
    id<GoToMyInvitedCpViewDelegate> gotoMyInvitedCpViewDelegate;
    NSInteger selectRowHeight;
}
@property (retain, nonatomic) id<GoToRmViewDetailDelegate> gotoRmViewDelegate;
@property (retain, nonatomic) id<GoToMyInvitedCpViewDelegate> gotoMyInvitedCpViewDelegate;
@property (retain, nonatomic) NSString *lng;
@property (retain, nonatomic) NSString *lat;
@property (retain, nonatomic) NSString *strMobile;
-(void) onSearch;
@end
