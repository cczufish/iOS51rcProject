#import <UIKit/UIKit.h>
#import "Popup+UIView.h"

@protocol AttendRMPopupDelegate <NSObject>
@optional
- (void) closePopupNext;
- (void) confirmAndCancelPopupNext;
- (void) getPopupValue:(NSString *)value;
- (void) attendRM;
@end

@interface AttendRMPopUp : UIView
@property (assign, nonatomic) id <AttendRMPopupDelegate> delegate;
@property (nonatomic, retain) UIView* viewContent;
@property (nonatomic, retain) UIView* viewSuper;

-(id) initPopup;

-(void) showPopup:(UIView *)view;
-(void) closePopup;
@end