#import "IndexViewController.h"
#import "SlideNavigationController.h"
#import "CustomPopup.h"
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CoreAnimation.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "MLImageCrop.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "Toast+UIView.h"
#import "CpInviteViewController.h"
#import "LoginViewController.h"
#import "CommonController.h"
#import "ChatOnlineViewController.h"
#import "MobileCertificateViewController.h"
#import "JmMainViewController.h"
#import "AccountManagementViewController.h"

@interface IndexViewController ()<UITableViewDataSource,UITableViewDelegate,SlideNavigationControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MLImageCropDelegate,NetWebServiceRequestDelegate>
{
    LoadingAnimationView *loadView;
}
@property (retain, nonatomic) CustomPopup *cPopup;
@property (retain, nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) UIActivityIndicatorView *viewWait;

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
    [self.navigationItem setTitle:@"会员中心"];
    self.btnPhotoCancel.layer.cornerRadius = 5;
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    //设置按钮
    UIButton *btnRight = [[[UIButton alloc] initWithFrame:CGRectMake(260, 0, 30, self.navigationController.navigationBar.frame.size.height)] autorelease];
    //添加设置图片
    [btnRight addTarget:self action:@selector(btnSettingClick:) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(14, (self.navigationController.navigationBar.frame.size.height-25)/2 + 5, 15, 15)] autorelease];
    UIImage *imgShared = [[UIImage imageNamed:@"ico_member_set.png"] autorelease];
    imageView.image = imgShared;
    [btnRight addSubview:imageView];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    self.navigationItem.rightBarButtonItem=backButton;
    
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    self.viewWait = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    [self.viewWait setCenter:CGPointMake(160, 125)];//指定进度轮中心点
    [self.view addSubview:self.viewWait];
    //添加边框
    self.btnMobileCer.layer.borderWidth = 1;
    self.btnMobileCer.layer.borderColor = [[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1] CGColor];
    self.btnMobileCer.layer.cornerRadius = 5;
    
    self.btnMobileModify.layer.borderWidth = 1;
    self.btnMobileModify.layer.borderColor = [[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1] CGColor];
    self.btnMobileModify.layer.cornerRadius = 5;
}

//用户设置
- (void) btnSettingClick:(UIButton*) sender{
    AccountManagementViewController *accountCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"AccountManagementView"];
    accountCtrl.navigationItem.title = @"账户管理";
    [self.navigationController pushViewController:accountCtrl animated:true];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.viewProfile setHidden:true];
    [self.viewWait startAnimating];
    [self getPaData];
    if (self.toastType == 1) {
        [self.view makeToast:@"手机号修改成功"];
    }
    else if (self.toastType == 2)
    {
        [self.view makeToast:@"手机号认证成功"];
        //修改为已认证
        [self.btnMobileCer setTitle:@"已认证" forState:UIControlStateNormal];
    }
    else if(self.toastType == 3)
    {
        [self.view makeToast:@"密码已修改成功"];
    }
    else if(self.toastType == 4)
    {
        [self.view makeToast:@"用户名已修改成功"];
    }
    self.toastType = 0;
}

- (IBAction)changePhoto:(UIButton *)sender {
    self.cPopup = [[[CustomPopup alloc] popupCommon:self.viewPhotoSelect buttonType:PopupButtonTypeNone] autorelease];
    [self.cPopup showPopup:self.view];
}

- (IBAction)selectPhotoFromCamera:(id)sender {
    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)selectPhotoFromAlbum:(id)sender {
    [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)clostPopup:(id)sender {
    [self.cPopup closePopup];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if([[info objectForKey:UIImagePickerControllerMediaType] isEqual:(NSString *) kUTTypeImage])
    {
        UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        MLImageCrop *imgCrop = [[MLImageCrop alloc] init];
        imgCrop.delegate = self;
        imgCrop.image = chosenImage;
        imgCrop.ratioOfWidthAndHeight = 3.0f/4.0f;
        [imgCrop showWithAnimation:true];
    }
    if([[info objectForKey:UIImagePickerControllerMediaType] isEqual:(NSString *) kUTTypeMovie])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息!" message:@"系统只支持图片格式" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alert show];
        
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType
{
    NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if([UIImagePickerController isSourceTypeAvailable:sourceType] &&[mediatypes count]>0){
        NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = mediatypes;
        picker.delegate = self;
        picker.sourceType = sourceType;
        NSString *requiredmediatype = (NSString *)kUTTypeImage;
        NSArray *arrmediatypes = [NSArray arrayWithObject:requiredmediatype];
        [picker setMediaTypes:arrmediatypes];
        [self presentViewController:picker animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息!" message:@"当前设备不支持拍摄功能" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)cropImage:(UIImage*)cropImage forOriginalImage:(UIImage*)originalImage
{
    [self.btnPhoto setImage:cropImage forState:UIControlStateNormal];
    [self.cPopup closePopup];
    NSData *dataPhoto = UIImageJPEGRepresentation(cropImage, 0);
    NSLog(@"%d",dataPhoto.length);
    [self uploadPhoto:[dataPhoto base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
}

- (void)getPaData
{
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetPaMainInfoByID" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 1;
    self.runningRequest = request;
    [dicParam release];
}

- (void)uploadPhoto:(NSString *)dataPhoto
{
    [loadView startAnimating];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:dataPhoto forKey:@"stream"];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UploadPhoto" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 2;
    self.runningRequest = request;
    [dicParam release];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    if (request.tag == 1) {
        //头像处理
        if (requestData[0][@"PhotoProcess"])
        {
            if (![requestData[0][@"HasPhoto"] isEqualToString:@"2"]) {
                NSString *path = [NSString stringWithFormat:@"%d",([[self.userDefaults objectForKey:@"UserID"] intValue] / 100000 + 1) * 100000];
                for (int i=0; i<9-path.length; i++) {
                    path = [NSString stringWithFormat:@"0%@",path];
                }
                path = [NSString stringWithFormat:@"L%@",path];
                path = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/Photo/%@/Processed/%@",path,requestData[0][@"PhotoProcess"]];
                [self.btnPhoto setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:path]]] forState:UIControlStateNormal];
            }
        }
        //设置文字
        self.lbPaName.text = requestData[0][@"Name"];
        self.lbMobile.text = requestData[0][@"Mobile"];
        self.lbEmail.text = requestData[0][@"Email"];
        //设置手机认证
        if (requestData[0][@"MobileVerifyDate"]) {
            [self.imgMobileCer setImage:[UIImage imageNamed:@"ico_member_moblecer.png"]];
            [self.imgMobileCer setFrame:CGRectMake(198, 78, 14, 16)];
            [self.btnMobileCer setTitle:@"已认证" forState:UIControlStateNormal];
            [self.btnMobileCer setTag:1];
        }
        else {
            [self.imgMobileCer setFrame:CGRectMake(200, 78, 10, 16)];
            [self.btnMobileCer setTag:0];
        }
        [self.viewProfile setHidden:false];
        [self.viewWait stopAnimating];
    }
    else if (request.tag == 2) {
        [self.view makeToast:@"头像上传成功"];
    }
    [loadView stopAnimating];
}

- (IBAction)certificateMobile:(UIButton *)sender {
    if (sender.tag == 1) {
        return;
    }
    else {
        MobileCertificateViewController *mobileCerC = [self.storyboard instantiateViewControllerWithIdentifier:@"MobileCertificateView"];
        [mobileCerC.navigationItem setTitle:@"手机认证"];
        mobileCerC.mobile = self.lbMobile.text;
        [self.navigationController pushViewController:mobileCerC animated:true];
        
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
            strTitle = @"";
            strIcon = @"";
            iconWidth = 30;
            iconLeft = 30;
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
            UIViewController *viewC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyCvView"];
            [self.navigationController pushViewController:viewC animated:true];
            break;
        }
        case 1:
        {
            UIViewController *viewC = [self.storyboard instantiateViewControllerWithIdentifier:@"CvRecommendView"];
            [self.navigationController pushViewController:viewC animated:true];
            break;
        }
        case 2:
        {
            UIStoryboard *jm = [UIStoryboard storyboardWithName:@"JobApplication" bundle:nil];
            JmMainViewController *jmMainCtrl = [jm instantiateViewControllerWithIdentifier:@"JmMainView"];
            jmMainCtrl.navigationItem.title = @"职位申请";
            [self.navigationController pushViewController:jmMainCtrl animated:true];
            break;
        }
        case 3:
        {
            UIStoryboard *userCenter = [UIStoryboard storyboardWithName:@"UserCenter" bundle:nil];
            CpInviteViewController *CpInviteViewCtrl = [userCenter instantiateViewControllerWithIdentifier:@"CpInviteView"];
            CpInviteViewCtrl.navigationItem.title = @"企业邀约";
            [self.navigationController pushViewController:CpInviteViewCtrl animated:true];
        
            break;
        }
        case 4:
        {
            UIStoryboard *userCenter = [UIStoryboard storyboardWithName:@"UserCenter" bundle:nil];
            ChatOnlineViewController *chatOnlieCtrl = [userCenter instantiateViewControllerWithIdentifier:@"ChatOnlineView"];
            chatOnlieCtrl.navigationItem.title = @"在线沟通";
            [self.navigationController pushViewController:chatOnlieCtrl animated:true];

             break;
        }
        case 5:
        {
            break;
        }
        default:
            break;
    }

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
    [_viewWait release];
    [_btnPhoto release];
    [_viewPhotoSelect release];
    [_cPopup release];
    [_btnPhotoCancel release];
    [_userDefaults release];
    [_lbPaName release];
    [_lbEmail release];
    [_lbMobile release];
    [_btnMobileModify release];
    [_btnMobileCer release];
    [_runningRequest release];
    [loadView release];
    [super dealloc];
}
@end
