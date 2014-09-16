#import <UIKit/UIKit.h>

@interface SalaryAnalysisViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIView *viewSearchSelect;
@property (retain, nonatomic) IBOutlet UIButton *btnSearch;
@property (retain, nonatomic) IBOutlet UIButton *btnRegionSelect;
@property (retain, nonatomic) IBOutlet UILabel *lbRegionSelect;
@property (retain, nonatomic) IBOutlet UIButton *btnJobTypeSelect;
@property (retain, nonatomic) IBOutlet UILabel *lbJobTypeSelect;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollSearch;
@property (retain, nonatomic) IBOutlet UIImageView *imgSearch;
@property (retain, nonatomic) IBOutlet UILabel *lbSearch;

@property (retain, nonatomic) UIView *viewHistory;
@end
