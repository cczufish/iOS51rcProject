//
//  IndexViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-11.
//

#import "IndexViewController.h"
#import "SlideNavigationController.h"

@interface IndexViewController ()<UITableViewDataSource,UITableViewDelegate,SlideNavigationControllerDelegate>

@end

@implementation IndexViewController

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
    
}

- (IBAction)changePhoto:(UIButton *)sender {
    
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
            strTitle = @"我的简历";
            strIcon = @"ico_member_mycv.png";
            iconWidth = 30;
            iconLeft = 30;
            break;
        case 1:
            strTitle = @"推荐职位";
            strIcon = @"ico_member_jobrecommend.png";
            iconWidth = 30;
            iconLeft = 30;
            break;
        case 2:
            strTitle = @"职位申请";
            strIcon = @"ico_member_jobapply.png";
            iconWidth = 30;
            iconLeft = 30;
            break;
        case 3:
            strTitle = @"企业邀约";
            strIcon = @"ico_member_cpinvite.png";
            iconWidth = 30;
            iconLeft = 30;
            break;
        case 4:
            strTitle = @"在线沟通";
            strIcon = @"ico_member_connect.png";
            iconWidth = 30;
            iconLeft = 30;
            break;
        default:
            break;
    }
    UITableViewCell *cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"index"] autorelease];
    UIImageView *imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(iconLeft, 13, iconWidth, 30)];
    [imgIcon setImage:[UIImage imageNamed:strIcon]];
    [cell.contentView addSubview:imgIcon];
    [imgIcon release];
    
    UILabel *lbTitle = [[UILabel alloc] initWithFrame:CGRectMake(70, 13, 200, 30)];
    [lbTitle setText:strTitle];
    [cell.contentView addSubview:lbTitle];
    [lbTitle release];
    
    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(280, 20, 8, 15)];
    [imgArrow setImage:[UIImage imageNamed:@"ico_select_right.png"]];
    [cell.contentView addSubview:imgArrow];
    [imgArrow release];
    
    UILabel *lbSeparate = [[UILabel alloc] initWithFrame:CGRectMake(0, 54, 320, 0.5)];
    [lbSeparate setBackgroundColor:[UIColor lightGrayColor]];
    [cell.contentView addSubview:lbSeparate];
    [lbSeparate release];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (int)slideMenuItem
{
    return 3;
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
    [_viewProfile release];
    [_btnPhoto release];
    [super dealloc];
}
@end
