#import <UIKit/UIKit.h>

@interface CpAttentionViewController : UIViewController
{
    NSString *cvMainID;
}
@property (retain, nonatomic) IBOutlet UITableView *tvJobList;
@property (retain,nonatomic) NSMutableArray* arrCheckJobID;
- (void)onSearch;
@end
