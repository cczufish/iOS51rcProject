#import <UIKit/UIKit.h>

@interface JobInviteListViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITableView *tvJobList;
@property (retain, nonatomic) IBOutlet UIButton *btnApply;
@property (retain, nonatomic) IBOutlet UIButton *btnFavorite;
@property (retain, nonatomic) IBOutlet UIView *viewBottom;
@property (retain, nonatomic) IBOutlet UIButton *btnDelete;
@property (retain,nonatomic) NSMutableArray* arrCheckJobID;
@property (retain,nonatomic) NSMutableArray* arrWillBeDeletedID;

- (void)onSearch;
@end
