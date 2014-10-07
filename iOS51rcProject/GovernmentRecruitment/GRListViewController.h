#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"

@interface GRListViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSInteger page;    
    NSString *regionid;    
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NSMutableArray *gRListData;
@property (nonatomic, retain) NSMutableArray *placeData;
@end