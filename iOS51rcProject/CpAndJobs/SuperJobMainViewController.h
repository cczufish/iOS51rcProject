#import <UIKit/UIKit.h>
#import "MenuHrizontal.h"

@interface SuperJobMainViewController :UIViewController
{
    //是否是第一次加载
    BOOL firstPageLoad;
    BOOL secondPageLoad;
    BOOL thriePageLoad;
}
@property (retain, nonatomic) NSString *JobID;
@property (retain, nonatomic) NSString *cpMainID;
@end
