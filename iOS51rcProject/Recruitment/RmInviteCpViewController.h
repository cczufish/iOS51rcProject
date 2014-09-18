
#import <UIKit/UIKit.h>
#import "DatePickerView.h"
#import "LoadingAnimationView.h"
#import "RmCpMain.h"
#import "Delegate/SelectJobDelegate.h"
//点击邀请后，进入的职位确认页面（把邀请的公司都列出来）
@interface RmInviteCpViewController : UIViewController<SelectJobDelegate>
{
    NSMutableArray *placeData;//场馆
    
    NSString *regionID;
    NSString *beginDate;
    NSString *placeID;
    LoadingAnimationView *loadView;
    
    //如果是从职位页面设置返回
    NSString *settedCpID;
    NSString *settedJobID;
    NSString *settedJobName;
}
@property (retain, nonatomic) NSString *strRmID;//招聘会ID
@property (retain, nonatomic) NSString *strBeginTime;//举办时间
@property (retain, nonatomic) NSString *strAddress;//地址
@property (retain, nonatomic) NSString *strPlace;//场馆
@property (retain, nonatomic) NSArray  *arrJobs;//邀请的职位
//@property (retain, nonatomic) NSArray *cpIDs;//预约面试的企业
@property (retain, nonatomic) NSMutableArray *selectRmCps;
//@property (retain, nonatomic) s
@end
