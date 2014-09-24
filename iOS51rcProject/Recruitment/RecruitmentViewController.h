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

@property (retain,nonatomic) NSString *recruitmentMobile;
@property (retain,nonatomic) NSString *recruitmentTelephone;
@property (retain,nonatomic) NSString *recruitmentID;

@property (retain,nonatomic) NSString *strAddress;
@property (retain,nonatomic) NSString *strPlace;
@property (retain,nonatomic) NSDate *dtBeginTime;

@end
