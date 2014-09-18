#import <UIKit/UIKit.h>
#import "ScrollPageViewDelegate.h"

@interface JobViewController : UIViewController<UIScrollViewDelegate>
{
    NSMutableArray *recommentJobsData;
    int tmpHeight;
    int scrolHeight;
}
@property (retain, nonatomic) NSString *JobID;
-(void) onSearch;
@end
