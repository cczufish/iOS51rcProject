#import <UIKit/UIKit.h>
#import "RmCpMain.h"
#import "MJRefresh.h"
#import "SearchPickerView.h"
#import "Toast+UIView.h"
#import "InviteJobsFromApplyViewDelegate.h"
@interface CommonApplyJobViewController : UIViewController
{
    NSMutableArray *checkedCpArray;
    id<InviteJobsFromApplyViewDelegate> inviteFromApplyViewDelegate;
    NSString *selectCV;
}

@property (retain, nonatomic) IBOutlet UITableView *tvJobList;
@property (retain, nonatomic) IBOutlet UIButton *btnApply;
@property (retain, nonatomic) IBOutlet UIView *viewBottom;

@property (retain, nonatomic) id<InviteJobsFromApplyViewDelegate> inviteFromApplyViewDelegate;
//招聘会的信息
@property (retain,nonatomic) NSString* strBeginTime;
@property (retain,nonatomic) NSString* strAddress;
@property (retain,nonatomic) NSString* strPlace;
@property (retain,nonatomic) NSString* rmID;
-(void) onSearch:(NSString*) selectCv;
@end
