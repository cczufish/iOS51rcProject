#import <UIKit/UIKit.h>

@interface RMSearchJobListViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIButton *btnRegionFilter;
@property (retain, nonatomic) IBOutlet UILabel *lbRegionFilter;
@property (retain, nonatomic) IBOutlet UIButton *btnJobTypeFilter;
@property (retain, nonatomic) IBOutlet UILabel *lbJobTypeFilter;
@property (retain, nonatomic) IBOutlet UIButton *btnSalaryFilter;
@property (retain, nonatomic) IBOutlet UILabel *lbSalaryFilter;
@property (retain, nonatomic) IBOutlet UIButton *btnOtherFilter;
@property (retain, nonatomic) IBOutlet UITableView *tvJobList;
@property (retain, nonatomic) IBOutlet UIButton *btnApply;
@property (retain, nonatomic) IBOutlet UIView *viewBottom;

@property (retain,nonatomic) NSString* searchKeyword;
@property (retain,nonatomic) NSString* searchRegion;
@property (retain,nonatomic) NSString* searchJobType;
@property (retain,nonatomic) NSString* searchIndustry;
@property (retain,nonatomic) NSString* searchCondition;
@property (retain,nonatomic) NSString* searchRegionName;
@property (retain,nonatomic) NSString* searchJobTypeName;
@property (retain,nonatomic) NSString* selectOther;
@property (retain,nonatomic) NSString* selectOtherName;

@property (retain,nonatomic) NSMutableArray* arrCheckJobID;
@end
