#import <UIKit/UIKit.h>
#import "ScrollPageViewDelegate.h"

@interface JobViewController : UIViewController<UIScrollViewDelegate>
{
    NSMutableArray *recommentJobsData;
    int tmpHeight;
    int scrolHeight;
}
@property (retain, nonatomic) IBOutlet UIButton *btnApply;

@property (retain, nonatomic) NSString *JobID;
@property float lng;
@property float lat;
-(void) onSearch;
@end
