
#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"

//我邀请的企业列表页面
@interface MyRmInviteCpListViewController: UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *recruitmentCpData;
    //NSString *rmID;
    LoadingAnimationView *loadView;   
}
@property (retain, nonatomic) NSString *rmID;
@end
