#import <UIKit/UIKit.h>
#import "AttendRMPopUp.h"
#import "CustomPopup.h"
#import "AttendRMPopUp.h"
@interface RecruitmentViewController : UIViewController<AttendRMPopupDelegate>
{
//    NSString *strAddress;
//    NSString *strPlace;
//    NSDate *dtBeginTime;
}

@property (assign,nonatomic) NSString *recruitmentMobile;
@property (assign,nonatomic) NSString *recruitmentTelephone;
@property (retain,nonatomic) NSString *recruitmentID;

@property (assign,nonatomic) NSString *strAddress;
@property (assign,nonatomic) NSString *strPlace;
@property (assign,nonatomic) NSDate *dtBeginTime;

@end
