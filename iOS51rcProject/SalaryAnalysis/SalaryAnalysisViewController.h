#import <UIKit/UIKit.h>
#import "EColumnChart.h"
@interface SalaryAnalysisViewController : UIViewController <EColumnChartDelegate, EColumnChartDataSource>
@property (retain, nonatomic) IBOutlet UIView *viewSearchSelect;
@property (retain, nonatomic) IBOutlet UIButton *btnSearch;
@property (retain, nonatomic) IBOutlet UIButton *btnRegionSelect;
@property (retain, nonatomic) IBOutlet UILabel *lbRegionSelect;
@property (retain, nonatomic) IBOutlet UIButton *btnJobTypeSelect;
@property (retain, nonatomic) IBOutlet UILabel *lbJobTypeSelect;
@property (retain, nonatomic) IBOutlet UILabel *lbQueryResult;
@property (retain, nonatomic) IBOutlet UIScrollView *svMain;
@property (retain, nonatomic) IBOutlet UIView *viewTop;
@end
