#import "CpJobsViewController.h"
#import "CpMainViewController.h"
#import <UIKit/UIKit.h>
//企业信息父页面
@interface SuperCpViewController : UIViewController
{
    BOOL isJobListLoadFinished;
}
@property (retain, nonatomic) NSString *cpMainID;
@end
