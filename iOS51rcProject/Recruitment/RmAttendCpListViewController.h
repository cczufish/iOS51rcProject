#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"
//招聘会参会企业列表
@interface RmAttendCpListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger page;
    NSInteger pageSize;
    LoadingAnimationView *loadView;
    
}
@property (retain, nonatomic) NSString *rmID;
@property (retain, nonatomic) NSString *strBeginTime;
@property (retain, nonatomic) NSString *strAddress;
@property (retain, nonatomic) NSString *strPlace;
@property (retain, nonatomic) NSString *strCity;//招聘会所在的城市
@property (retain, nonatomic) NSMutableArray *recruitmentCpData;
@property (retain, nonatomic) NSMutableArray *checkedCpArray;
@end
