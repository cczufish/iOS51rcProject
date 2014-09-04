#import <UIKit/UIKit.h>
#import "Popup+UIView.h"

typedef enum {
    PopupButtonTypeOK,
    PopupButtonTypeConfirmAndCancel,
    PopupButtonTypeNone
} PopupButtonType;

@protocol CustomPopupDelegate <NSObject>
@optional
- (void) closePopupNext;
- (void) confirmAndCancelPopupNext;
- (void) getPopupValue:(NSString *)value;
@end

@interface CustomPopup : UIView
@property (assign, nonatomic) id <CustomPopupDelegate> delegate;
@property (nonatomic, retain) UIView* viewContent;
@property (nonatomic, retain) UIView* viewSuper;
@property (nonatomic) PopupButtonType buttonType;
@property (nonatomic, retain) NSMutableArray* arrCvButton;
@property (nonatomic, retain) NSString* selectCvID;
-(id) popupCvSelect:(NSMutableArray *)arrayCv;
-(id) popupCommon:(UIView *)contentView
       buttonType:(PopupButtonType)buttonType;

-(void) showPopup:(UIView *)view;
-(void) showJobApplyCvSelect:(NSString *)applyResult
                        view:(UIView *)view;
-(void) closePopup;
@end
