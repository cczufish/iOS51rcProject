#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"
#import "NetWebServiceRequest.h"
#import "CommonController.h"
#import "MJRefresh.h"
#import "Toast+UIView.h"
#import "EIItemDetailsViewController.h"
#import "GoToEIItemDetailsViewDelegate.h"
@interface EIListView : UIView<UITableViewDataSource,UITableViewDelegate, NetWebServiceRequestDelegate>
{
    NSMutableArray *placeData;
    NSInteger page;
    NSString *regionid;
    //LoadingAnimationView *loadView;
    id<GoToEIItemDetailsViewDelegate> goToEIItemDetailsViewDelegate;
}

@property (nonatomic,retain) NSMutableArray *eiListData;//新闻列表
@property (nonatomic,retain) UITableView *newsTableView;//显示Table
@property (retain, nonatomic) NSString *newsType;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) id<GoToEIItemDetailsViewDelegate> goToEIItemDetailsViewDelegate;
//- (void)reloadTableViewDataSource;
#pragma mark 强制列表刷新
-(void)forceToFreshData:(NSString *) newsType;

@end

