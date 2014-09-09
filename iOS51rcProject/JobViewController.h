#import <UIKit/UIKit.h>
#import "ScrollPageViewDelegate.h"

@interface JobViewController : UIViewController<UIScrollViewDelegate>
{
    NSMutableArray *recommentJobsData;
}
@property (retain, nonatomic) NSString *JobID;
@property int height;
@end
