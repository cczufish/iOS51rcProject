#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"

@interface RmAttendPaListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger page;
    NSInteger pageSize;
    
    LoadingAnimationView *loadView;
}
@property (retain, nonatomic) NSString *rmID;
@property (retain, nonatomic)  NSMutableArray *recruitmentPaData;
@end
