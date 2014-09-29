#import <UIKit/UIKit.h>
#import "RmCpMain.h"

//搜索职位的结果
@interface RMSearchJobListViewController : UIViewController
{
    NSMutableArray *checkedCpArray;
}
@property int toastType;
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

//招聘会的信息
@property (retain,nonatomic) NSString* strBeginTime;
@property (retain,nonatomic) NSString* strAddress;
@property (retain,nonatomic) NSString* strPlace;
@property (retain,nonatomic) NSString* rmID;
@end
