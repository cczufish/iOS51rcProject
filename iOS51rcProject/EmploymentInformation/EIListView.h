#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"
#import "NetWebServiceRequest.h"
#import "CommonController.h"
#import "MJRefresh.h"
#import "Toast+UIView.h"
#import "EIItemDetailsViewController.h"
@interface EIListView : UIView<UITableViewDataSource,UITableViewDelegate, NetWebServiceRequestDelegate>
{
    NSMutableArray *eiListData;//新闻列表
    NSMutableArray *placeData;
    NSInteger page;
    NSString *regionid;
    //LoadingAnimationView *loadView;
}

@property (nonatomic,retain) UITableView *newsTableView;//显示Table
@property (retain, nonatomic) NSString *newsType;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
//- (void)reloadTableViewDataSource;
#pragma mark 强制列表刷新
-(void)forceToFreshData:(NSString *) newsType;

@end

