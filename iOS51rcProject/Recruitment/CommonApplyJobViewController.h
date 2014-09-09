#import <UIKit/UIKit.h>
#import "RmCpMain.h"
#import "MJRefresh.h"
#import "SearchPickerView.h"
#import "Toast+UIView.h"
@interface CommonApplyJobViewController : UIViewController
{
     NSMutableArray *checkedCpArray;
}

@property (retain, nonatomic) IBOutlet UITableView *tvJobList;
@property (retain, nonatomic) IBOutlet UIButton *btnApply;
@property (retain, nonatomic) IBOutlet UIView *viewBottom;

//招聘会的信息
@property (retain,nonatomic) NSString* strBeginTime;
@property (retain,nonatomic) NSString* strAddress;
@property (retain,nonatomic) NSString* strPlace;
@property (retain,nonatomic) NSString* rmID;
@end
