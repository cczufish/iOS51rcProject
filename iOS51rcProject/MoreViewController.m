#import "MoreViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "AboutUsViewController.h"
#import "SlideNavigationController.h"

@interface MoreViewController () <UITableViewDataSource,UITableViewDelegate,SlideNavigationControllerDelegate>

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
    [self.tvMore setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strTitle, *strIcon;
    float iconWidth,iconLeft;
    switch (indexPath.row) {
        case 0:
            strTitle = @"推送设置";
            strIcon = @"ico_mainmore_setting.png";
            iconWidth = 30;
            iconLeft = 30;
            break;
        case 1:
            strTitle = @"应用分享";
            strIcon = @"ico_mainmore_share.png";
            iconWidth = 30;
            iconLeft = 30;
            break;
        case 2:
            strTitle = @"新手帮助";
            strIcon = @"ico_mainmore_help.png";
            iconWidth = 25;
            iconLeft = 30;
            break;
        case 3:
            strTitle = @"意见反馈";
            strIcon = @"ico_mainmore_opinion.png";
            iconWidth = 30;
            iconLeft = 30;
            break;
        case 4:
            strTitle = @"关于我们";
            strIcon = @"ico_mainmore_about.png";
            iconWidth = 30;
            iconLeft = 30;
            break;
        case 5:
            strTitle = @"退出账号";
            strIcon = @"ico_mainmore_logout.png";
            iconWidth = 30;
            iconLeft = 30;
            break;
        default:
            break;
    }
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"more"] autorelease];
    UIImageView *imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(iconLeft, 15, iconWidth, 30)];
    [imgIcon setImage:[UIImage imageNamed:strIcon]];
    [cell.contentView addSubview:imgIcon];
    [imgIcon release];
    
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(70, 15, 200, 30)];
    [lbTitle setText:strTitle];
    [cell.contentView addSubview:lbTitle];
    [lbTitle release];
    
    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(280, 21, 10, 18)];
    [imgArrow setImage:[UIImage imageNamed:@"ico_select_right.png"]];
    [cell.contentView addSubview:imgArrow];
    [imgArrow release];
    
    UILabel *lbSeparate = [[UILabel alloc] initWithFrame:CGRectMake(0, 59, 320, 0.5)];
    [lbSeparate setBackgroundColor:[UIColor lightGrayColor]];
    [cell.contentView addSubview:lbSeparate];
    [lbSeparate release];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 1:
        {
            NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ShareSDK"  ofType:@"jpg"];
            //构造分享内容
            id<ISSContent> publishContent = [ShareSDK content:@"我正在使用齐鲁人才网手机客户端找工作，随时随地，方便实用！你也来试试...http://m.qlrc.com\n来自：齐鲁人才网"
                                               defaultContent:@"默认分享内容，没内容时显示"
                                                        image:[ShareSDK imageWithPath:imagePath]
                                                        title:@"分享APP"
                                                          url:@"http://www.51rc.com"
                                                  description:@""
                                                    mediaType:SSPublishContentMediaTypeNews];
            
            [ShareSDK showShareActionSheet:nil
                                 shareList:nil
                                   content:publishContent
                             statusBarTips:YES
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
        case 4:
        {
            AboutUsViewController *aboutUsC = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutUsView"];
            aboutUsC.navigationItem.title = @"关于我们";
            [self.navigationController pushViewController:aboutUsC animated:true];
            break;
        }
        default:
            break;
    }
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
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_tvMore release];
    [super dealloc];
}
@end
