
#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"
@interface MyRmInviteCpListViewController: UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *recruitmentCpData;
    //NSString *rmID;
    LoadingAnimationView *loadView;   
}
@property (retain, nonatomic) NSString *rmID;
@end
