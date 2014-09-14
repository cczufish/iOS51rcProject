//
//  IndexViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-11.
//

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
#import "MobileCertificateViewController.h"

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
    self.btnPhotoCancel.layer.cornerRadius = 5;
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    self.viewWait = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
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
    }
    self.toastType = 0;
}

- (IBAction)changePhoto:(UIButton *)sender {
    self.cPopup = [[CustomPopup alloc] popupCommon:self.viewPhotoSelect buttonType:PopupButtonTypeNone];
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
    switch (indexPath.row) {
        case 0:
        {
            break;
        }
        case 1:
        {
            break;
        }
        case 2:
        {
            break;
        }
        case 3:
        {
            if ([CommonController isLogin]) {
                UIStoryboard *userCenter = [UIStoryboard storyboardWithName:@"UserCenter" bundle:nil];
                CpInviteViewController *CpInviteViewCtrl = [userCenter instantiateViewControllerWithIdentifier:@"CpInviteView"];
                CpInviteViewCtrl.navigationItem.title = @"企业邀约";
                self.navigationItem.title = @" ";
                [self.navigationController pushViewController:CpInviteViewCtrl animated:true];
            }else{
                UIStoryboard *login = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
                LoginViewController *loginCtrl = [login instantiateViewControllerWithIdentifier:@"LoginView"];
                [self.navigationController pushViewController:loginCtrl animated:YES];
                loginCtrl.navigationItem.title = @"企业邀约";
            }

            break;
        }
        case 4:
        {
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
    [super dealloc];
}
@end