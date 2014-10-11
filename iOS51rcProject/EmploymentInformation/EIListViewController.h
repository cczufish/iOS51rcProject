#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"

//关键字搜索结果
@interface EIListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{  
    NSInteger page;
    NSString *regionid;
    LoadingAnimationView *loadView;
}
@property (retain, nonatomic) NSString *strKeyWord;
@property (retain, nonatomic) NSMutableArray *eiListData;//新闻列表
@end
