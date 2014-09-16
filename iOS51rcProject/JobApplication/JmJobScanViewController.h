#import <UIKit/UIKit.h>

@interface JmJobScanViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITableView *tvJobList;
@property (retain, nonatomic) IBOutlet UIButton *btnApply;
@property (retain, nonatomic) IBOutlet UIView *viewBottom;
@property (retain, nonatomic) IBOutlet UIButton *btnFavourity;
@property (retain,nonatomic) NSMutableArray* arrCheckJobID;
-(void) onSearch;
@end
