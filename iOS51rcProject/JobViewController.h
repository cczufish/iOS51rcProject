#import <UIKit/UIKit.h>

@interface JobViewController : UIViewController<UIScrollViewDelegate>
{
    NSMutableArray *recommentJobsData;
}
@property (retain, nonatomic) NSString *JobID;
@end
