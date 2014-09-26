#import <UIKit/UIKit.h>

@interface CpMainViewController : UIViewController
@property (retain, nonatomic) NSString *cpMainID;
@property float lng;
@property float lat;
-(void) onSearch;
@end
