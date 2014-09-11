#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITableView *tvMenu;

-(void)changeMenuItem:(int)item;
@end