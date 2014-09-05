#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"

@interface EIListViewController : UIViewController
{
    NSMutableArray *eiListData;//新闻列表
    NSMutableArray *placeData;
    NSInteger page;
    NSString *regionid;
    LoadingAnimationView *loadView;
}
@property (retain, nonatomic) NSString *newsType;
@end
