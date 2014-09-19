
#import <UIKit/UIKit.h>
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
//公司职位列表
@interface CpJobsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *jobListData;
    NSInteger page;
    LoadingAnimationView *loadView;
}
@property int frameHeight;
@property (nonatomic,retain) NSString *cpMainID;//企业的ID
@property (retain, nonatomic) NSString *newsType;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (retain,nonatomic) NSMutableArray* arrCheckJobID;
- (void)onSearch;
@end
