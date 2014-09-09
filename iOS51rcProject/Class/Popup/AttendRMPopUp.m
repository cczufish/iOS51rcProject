#import "AttendRMPopUp.h"
#import "CommonController.h"

@implementation AttendRMPopUp
@synthesize delegate = _delegate;

-(id) initPopup
{
    self.viewContent = [[[UIView alloc] init] autorelease];
    if (self = [super init]) {
        float contentHeight = 20;
        UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(75, 15, 160, 30)];
        NSString *strApplyResult = @"预约成功，请准时参会";
      
        [lbTitle setText:strApplyResult];
        [lbTitle setFont:[UIFont systemFontOfSize:12]];
        [lbTitle setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        CGSize labelSize = [CommonController CalculateFrame:strApplyResult fontDemond:[UIFont systemFontOfSize:12] sizeDemand:CGSizeMake(160, 5000)];
        CGRect titleRect = lbTitle.frame;
        titleRect.size = labelSize;
        lbTitle.frame = titleRect;
        lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
        lbTitle.numberOfLines = 0;
        [self.viewContent addSubview:lbTitle];
        [lbTitle release];
        
        //成功图片
        UIImageView *imgSuccess = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 40, 40)];
        if (labelSize.height > 25) {
            [imgSuccess setFrame:CGRectMake(20, 30, 40, 40)];
        }
        [imgSuccess setImage:[UIImage imageNamed:@"ico_jobright.png"]];
        [self.viewContent addSubview:imgSuccess];
        [imgSuccess release];
        
        //成功后的提醒
        UILabel *lbTips = [[UILabel alloc] initWithFrame:CGRectMake(75, 25+labelSize.height, 160, 30)];
        [lbTips setText:@"您现在可以邀请感兴趣的企业参会进行现场面谈"];
        [lbTips setFont:[UIFont systemFontOfSize:10]];
        [lbTips setTextColor:[UIColor lightGrayColor]];
        lbTips.lineBreakMode = NSLineBreakByCharWrapping;
        lbTips.numberOfLines = 0;
        [self.viewContent addSubview:lbTips];
        [lbTips release];
        
        UIButton *btnConfirm = [[UIButton alloc] initWithFrame:CGRectMake(10, lbTips.frame.origin.y+lbTips.frame.size.height + 20, 120, 30)];
        [btnConfirm setTitle:@"邀请企业参会" forState:UIControlStateNormal];
        [btnConfirm setBackgroundColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        btnConfirm.layer.cornerRadius = 5;
        [btnConfirm addTarget:self action:@selector(savePopup) forControlEvents:UIControlEventTouchUpInside];
        [self.viewContent addSubview:btnConfirm];
        [btnConfirm release];
        
        UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(145, lbTips.frame.origin.y+lbTips.frame.size.height + 20, 80, 30)];
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnCancel setBackgroundColor:[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1]];
        btnCancel.layer.cornerRadius = 5;
        [btnCancel addTarget:self action:@selector(closePopup) forControlEvents:UIControlEventTouchUpInside];
        [self.viewContent addSubview:btnCancel];
        [btnCancel release];
        
        contentHeight+=120;
      [self.viewContent setFrame:CGRectMake(0, 0, 240, contentHeight)];
    }
    return self;
}

-(void) showPopup:(UIView *)view
{
    self.viewSuper = view;
    [view popupView:self.viewContent];
}

-(void) savePopup
{
    [self closePopup];
    [self.delegate attendRM];
}

-(void) closePopup
{
    [self.viewSuper closePopup];
    if (self.delegate && [self.delegate respondsToSelector:@selector(closePopupNext)]) {
        [self.delegate closePopupNext];
    }
}

-(void) dealloc
{
    [_viewContent release];
    [_viewSuper release];
    [super dealloc];
}

@end
