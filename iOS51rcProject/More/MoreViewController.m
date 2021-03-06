#import "MoreViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "AboutUsViewController.h"
#import "SlideNavigationController.h"
#import "FeedbackViewController.h"
#import "CustomPopup.h"
#import "NewsHelpViewController.h"
#import "PushNotificationViewController.h"
#import "MenuViewController.h"
#import "HomeViewController.h"

@interface MoreViewController () <UITableViewDataSource,UITableViewDelegate,SlideNavigationControllerDelegate, CustomPopupDelegate>
@property (retain, nonatomic) CustomPopup *cPopup;
@end

@implementation MoreViewController

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
    self.navigationItem.title = @"更多";
    [self.tvMore setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registerCompletion:)
                                                 name:@"More"
                                               object:nil];
}

-(void)registerCompletion:(NSNotification*)notification {
    NSDictionary *theData = [notification userInfo];
    NSString *value = [theData objectForKey:@"operation"];
    
    //从反馈页面返回
    if([value isEqualToString:@"FeedbackFinished"]){
        [self.view makeToast:@"反馈成功"];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strTitle, *strIcon;
    float iconWidth,iconLeft;
    switch (indexPath.row) {
        case 0:
            strTitle = @"应用分享";
            strIcon = @"ico_mainmore_share.png";
            iconWidth = 20;
            iconLeft = 28;
            break;
        case 1:
            strTitle = @"新手帮助";
            strIcon = @"ico_mainmore_help.png";
            iconWidth = 17;
            iconLeft = 30;
            break;
        case 2:
            strTitle = @"意见反馈";
            strIcon = @"ico_mainmore_opinion.png";
            iconWidth = 20;
            iconLeft = 30;
            break;
        case 3:
            strTitle = @"关于我们";
            strIcon = @"ico_mainmore_about.png";
            iconWidth = 20;
            iconLeft = 30;
            break;
        case 4:
            strTitle = @"退出账号";
            strIcon = @"ico_mainmore_logout.png";
            iconWidth = 20;
            iconLeft = 30;
            break;
        default:
            strTitle = @"";
            strIcon = @"";
            iconWidth = 20;
            iconLeft = 30;
            break;
    }
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"more"] autorelease];
    CGRect iconFrame = CGRectMake(iconLeft, 20, iconWidth, 20);
    if (indexPath.row == 1) {
        iconFrame.size.height = 22;
    }
    UIImageView *imgIcon = [[UIImageView alloc] initWithFrame:iconFrame];
    [imgIcon setImage:[UIImage imageNamed:strIcon]];
    [cell.contentView addSubview:imgIcon];
    [imgIcon release];
    
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(65, 15, 200, 30)];
    [lbTitle setText:strTitle];
    [cell.contentView addSubview:lbTitle];
    [lbTitle release];
    
    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(280, 21, 10, 18)];
    [imgArrow setImage:[UIImage imageNamed:@"ico_select_right.png"]];
    [cell.contentView addSubview:imgArrow];
    [imgArrow release];
    
    UILabel *lbSeparate = [[UILabel alloc] initWithFrame:CGRectMake(0, 59, 320, 0.5)];
    [lbSeparate setBackgroundColor:[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1]];
    [cell.contentView addSubview:lbSeparate];
    [lbSeparate release];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ShareSDK"  ofType:@"jpg"];
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            //构造分享内容
            NSString *strMobileUrl = [userDefault objectForKey:@"subSiteUrl"];
            strMobileUrl = [strMobileUrl stringByReplacingOccurrencesOfString:@"www" withString:@"m"];
            id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"我正在使用%@手机客户端找工作，随时随地，方便实用！你也来试试...%@\n来自：%@",[userDefault objectForKey:@"subSiteName"],strMobileUrl,[userDefault objectForKey:@"subSiteName"]]
                                               defaultContent:@"默认分享内容，没内容时显示"
                                                        image:[ShareSDK imageWithPath:imagePath]
                                                        title:@"分享APP"
                                                          url:@"http://m.qlrc.com"
                                                  description:@""
                                                    mediaType:SSPublishContentMediaTypeNews];
            
            [ShareSDK showShareActionSheet:nil
                                 shareList:nil
                                   content:publishContent
                             statusBarTips:NO
                               authOptions:nil
                              shareOptions: nil
                                    result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                        if (state == SSResponseStateSuccess)
                                        {
                                            NSLog(@"分享成功");
                                        }
                                        else if (state == SSResponseStateFail)
                                        {
                                            NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                        }
                                    }];
            break;
        }
        case 1:
        {
            NewsHelpViewController * helpview = [self.storyboard instantiateViewControllerWithIdentifier:@"NewsHelpView"];
            [self.navigationController pushViewController:helpview animated:true];
            //[self.navigationController setNavigationBarHidden:YES animated:YES];
            break;
        }
        case 2:
        {
            //意见反馈
            FeedbackViewController *feedBackCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"FeedbackView"];
            [self.navigationController pushViewController:feedBackCtrl animated:YES];
            feedBackCtrl.navigationItem.title = @"意见反馈";
            break;
        }
        case 3:
        {
            AboutUsViewController *aboutUsC = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutUsView"];
            aboutUsC.navigationItem.title = @"关于我们";
            [self.navigationController pushViewController:aboutUsC animated:true];
            break;
        }
        case 4:
        {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            if ([userDefaults objectForKey:@"UserID"]) {                
                //弹出对话框，询问是否退出
                CGSize labelSize = CGSizeMake(240, 30);
                //添加view
                UIView *viewPopup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelSize.width+20, labelSize.height+50)];
                //添加标题“提示”
                UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width+10, 20)];
                [lbTitle setText:@"提示"];
                [lbTitle setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
                [lbTitle setTextAlignment:NSTextAlignmentCenter];
                //添加分割线
                UILabel *lbSeperate = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, labelSize.width, 1)];
                [lbSeperate setBackgroundColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
                //消息内容
                NSString *strMsg = @"确定退出当前登录用户？";
                UILabel *lbMsg = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, labelSize.width, labelSize.height)];
                [lbMsg setText: strMsg];
                [lbMsg setFont:[UIFont systemFontOfSize:14]];
                lbMsg.numberOfLines = 0;
                lbMsg.lineBreakMode = NSLineBreakByCharWrapping;
                [viewPopup addSubview:lbMsg];
                [viewPopup addSubview:lbTitle];
                [viewPopup addSubview:lbSeperate];
                //显示
                self.cPopup = [[[CustomPopup alloc] popupCommon:viewPopup buttonType:PopupButtonTypeConfirmAndCancel] autorelease];
                self.cPopup.delegate = self;
                [self.cPopup showPopup:self.view];
                [lbMsg release];
                [lbTitle release];
                [lbSeperate release];
                [viewPopup release];

            }
            else {
                [self.view makeToast:@"您当前没有登录，无需退出"];
            }
            
            break;
        }
        default:
            break;
    }
}

//点击退出帐号，清除UserDefault里边的数据，返回到首页
- (void) confirmAndCancelPopupNext
{
    [CommonController logout];
    HomeViewController *homeViewC = [[UIStoryboard storyboardWithName:@"Home" bundle: nil] instantiateViewControllerWithIdentifier: @"HomeView"];
    homeViewC.toastType = 1;
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:homeViewC withCompletion:nil];
}

- (int)slideMenuItem
{
    return 9;
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [_cPopup release];
    [_tvMore release];
    [super dealloc];
}
@end
