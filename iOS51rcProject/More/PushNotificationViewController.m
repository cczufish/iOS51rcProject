#import "PushNotificationViewController.h"

@interface PushNotificationViewController ()
@property (retain, nonatomic) IBOutlet UIView *view1;
@property (retain, nonatomic) IBOutlet UIView *view2;

@property (retain, nonatomic) IBOutlet UISwitch *switchReplyForApply;
@property (retain, nonatomic) IBOutlet UISwitch *switchNiticeForInterView;
@property (retain, nonatomic) IBOutlet UISwitch *switchInvitation;
@end

@implementation PushNotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view1.layer.cornerRadius = 5;
    self.view1.layer.borderWidth = 1;
    self.view1.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
   
    self.view2.layer.cornerRadius = 5;
    self.view2.layer.borderWidth = 1;
    self.view2.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_switchReplyForApply release];
    [_switchNiticeForInterView release];
    [_switchInvitation release];
    [_view1 release];
    [_view2 release];
    [super dealloc];
}
@end
