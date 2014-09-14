#import <UIKit/UIKit.h>

@interface CpAttentionViewController : UIViewController

@property (retain, nonatomic) IBOutlet UITableView *tvJobList;
@property (retain,nonatomic) NSMutableArray* arrCheckJobID;
- (void)onSearch;
@end
