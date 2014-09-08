
#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"
#import "Delegate/SelectJobDelegate.h"

//上一个页面，点击多个企业后，这个页面显示职位，并可以选择企业的职位。
//某一个公司的职位列表页面
@interface RmCpJobListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *JobListData;
    LoadingAnimationView *loadView;
    id<SelectJobDelegate> delegate;
}
@property (retain, nonatomic) NSString *cpMainID;
@property (retain, nonatomic) id<SelectJobDelegate> delegate;
@end
