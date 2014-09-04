#import <UIKit/UIKit.h>

@interface MapSearchListViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIButton *btnJobTypeFilter;
@property (retain, nonatomic) IBOutlet UILabel *lbJobTypeFilter;
@property (retain, nonatomic) IBOutlet UIButton *btnSalaryFilter;
@property (retain, nonatomic) IBOutlet UILabel *lbSalaryFilter;
@property (retain, nonatomic) IBOutlet UIButton *btnWelfareFilter;
@property (retain, nonatomic) IBOutlet UIButton *btnOtherFilter;
@property (retain, nonatomic) IBOutlet UITableView *tvJobList;
@property (retain, nonatomic) IBOutlet UIButton *btnApply;
@property (retain, nonatomic) IBOutlet UIButton *btnFavorite;
@property (retain, nonatomic) IBOutlet UIView *viewBottom;

@property float searchLat;
@property float searchLng;
@property float searchDistance;
@property (retain,nonatomic) NSString* searchCondition;
@property (retain,nonatomic) NSString* selectOther;
@property (retain,nonatomic) NSString* selectOtherName;

@property (retain,nonatomic) NSMutableArray* arrCheckJobID;
@end
