#import <UIKit/UIKit.h>
#import "AnimatedGif.h"

typedef enum _LoadingAnimationViewStyle {
	LoadingAnimationViewStyleNormal = 0,
	LoadingAnimationViewStyleSpot = 1,
	LoadingAnimationViewStyleFlow = 2,
	LoadingAnimationViewStyleCarton = 3
	
} LoadingAnimationViewStyle;

@interface LoadingAnimationView : UIImageView {
	
	NSMutableArray *_gifs;
}

@property(nonatomic, retain) NSMutableArray *gifs;
@property(nonatomic, retain) UIView *viewBack;
- (id)initWithFrame:(CGRect)frame loadingAnimationViewStyle:(LoadingAnimationViewStyle)style
             target:(UIViewController *)target;

@end
