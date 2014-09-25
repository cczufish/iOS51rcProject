
#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"
#import "GoToRmViewDetailDelegate.h"
#import "GoToMyInvitedCpViewDelegate.h"

@interface InterviewNoticeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger selectRowIndex;
    
    LoadingAnimationView *loadView;
    NSMutableArray *checkedCpArray;
    id<GoToRmViewDetailDelegate> gotoRmViewDelegate;
    id<GoToMyInvitedCpViewDelegate> gotoMyInvitedCpViewDelegate;
    NSInteger selectRowHeight;
}
@property (retain, nonatomic) id<GoToRmViewDetailDelegate> gotoRmViewDelegate;
@property (retain, nonatomic) id<GoToMyInvitedCpViewDelegate> gotoMyInvitedCpViewDelegate;
@property (retain, nonatomic) NSMutableArray *recruitmentCpData;
@property (retain, nonatomic) NSString *strPhone;
-(void) onSearch;
@end
