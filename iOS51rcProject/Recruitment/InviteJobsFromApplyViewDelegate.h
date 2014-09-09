#import <Foundation/Foundation.h>
#import "RmCpMain.h"
//从已经邀请的界面选择职位进行申请
@protocol InviteJobsFromApplyViewDelegate <NSObject>
-(void) InviteJobsFromApplyView:(NSMutableArray*) checkedCps;
@end
