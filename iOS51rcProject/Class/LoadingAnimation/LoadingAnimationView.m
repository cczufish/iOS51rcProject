#import "LoadingAnimationView.h"
#import "CommonController.h"


@implementation LoadingAnimationView
@synthesize gifs = _gifs;
@synthesize viewBack = _viewBack;

- (id)initWithFrame:(CGRect)frame loadingAnimationViewStyle:(LoadingAnimationViewStyle)style
               target:(UIViewController *)target
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
		AnimatedGif *aniGif = [[AnimatedGif alloc] init];
		NSString *gifName = @"loading";
		NSString *path = [[NSBundle mainBundle] pathForResource:gifName ofType:@"gif"];
		[aniGif decodeGIF:[NSData dataWithContentsOfFile:path]];
	
		_gifs = [[aniGif frames] mutableCopy];
		self.animationImages = _gifs;
		self.animationDuration = 0.05f*[_gifs count];
		self.animationRepeatCount = 9999;
		[aniGif release];
        _viewBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 640)];
        _viewBack.backgroundColor = [UIColor colorWithRed:255.f/255.f green:255.f/255.f blue:255.f/255.f alpha:1];
        self.center = CGPointMake(_viewBack.center.x, _viewBack.center.y);
        if ([CommonController getFatherController:target.view]) {
            self.center = CGPointMake(_viewBack.center.x, _viewBack.center.y-100);
        }
        [_viewBack addSubview:self];
        [target.view addSubview:_viewBack];
        [_viewBack setHidden:true];
    }
    return self;
}


-(void)startAnimating
{
    if (_viewBack.hidden) {
        _viewBack.hidden = NO;
    }
	[super startAnimating];
}

-(void)stopAnimating
{
	[super stopAnimating];
    _viewBack.hidden = YES;
}

- (void)dealloc {
	[_gifs release];
    [_viewBack release];
    [super dealloc];
}


@end
