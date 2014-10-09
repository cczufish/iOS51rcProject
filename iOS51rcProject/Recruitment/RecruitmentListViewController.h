#import <UIKit/UIKit.h>
#import "DatePickerView.h"
#import "LoadingAnimationView.h"
#import "AttendRMPopUp.h"
#import "RM.h"

@interface RecruitmentListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, AttendRMPopupDelegate>
{
    LoadingAnimationView *loadView;
}
@property int page;
@property (nonatomic, retain) NSMutableArray *recruitmentData;
@property (nonatomic, retain) NSMutableArray *placeData;
@property (nonatomic, retain) NSString *begindate;
@property (nonatomic, retain) NSString *placeid;
@property (nonatomic, retain) NSString *regionid;
@property (nonatomic, retain) RM *selectedRM;
@end
