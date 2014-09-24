#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"

@interface GRListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSInteger page;    
    NSString *regionid;    
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NSMutableArray *gRListData;
@property (nonatomic, retain) NSMutableArray *placeData;
@end