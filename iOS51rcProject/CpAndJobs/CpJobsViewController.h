
#import <UIKit/UIKit.h>
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
//公司职位列表
@interface CpJobsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSInteger page;
   
}
@property int frameHeight;
@property (nonatomic,retain) NSMutableArray *jobListData;
@property (nonatomic,retain) NSString *cpMainID;//企业的ID
@property (retain, nonatomic) NSString *newsType;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (retain,nonatomic) NSMutableArray* arrCheckJobID;
@property (retain, nonatomic) LoadingAnimationView *loadView;
- (void)onSearch;
@end
