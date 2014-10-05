#import <UIKit/UIKit.h>

@interface WelcomeViewController : UIViewController<UIScrollViewDelegate>
{
    
}

@property(retain,nonatomic) UIScrollView * pageScroll;
@property(retain,nonatomic) UIPageControl * pageControl;

@property(retain,nonatomic) UIButton * gotoMainViewBtn;
-(void)gotoMainView:(id)sender;

@end
