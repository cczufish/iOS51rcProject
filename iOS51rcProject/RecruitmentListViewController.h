#import <UIKit/UIKit.h>
#import "DatePicker.h"
#import "LoadingAnimationView.h"

@interface RecruitmentListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    LoadingAnimationView *loadView;
}
@property int page;
@property (nonatomic, retain) NSMutableArray *recruitmentData;
@property (nonatomic, retain) NSMutableArray *placeData;
@property (nonatomic, retain) NSString *begindate;
@property (nonatomic, retain) NSString *placeid;
@property (nonatomic, retain) NSString *regionid;
@property (nonatomic, retain) DatePicker *pickDate;
@end
