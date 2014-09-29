//
//  MobileCertificateViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-12.
//

#import "MobileCertificateViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "IndexViewController.h"
#import "Toast+UIView.h"
#import "CommonController.h"

@interface MobileCertificateViewController ()<NetWebServiceRequestDelegate>
{
    LoadingAnimationView *loadView;
    int secondSend;
}
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;

@end

@implementation MobileCertificateViewController

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
    //添加边框
    self.viewMobile.layer.cornerRadius = 5;
    self.viewMobile.layer.borderWidth = 1;
    self.viewMobile.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    self.btnSendSms.layer.cornerRadius = 5;
    self.btnSendSms.layer.borderWidth = 1;
    self.btnSendSms.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    self.btnMobileCer.layer.cornerRadius = 5;
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    self.txtMobile.text = self.mobile;
    secondSend = 180;
    //设置为数字键盘
    [self.txtMobile setKeyboardType:UIKeyboardTypeNumberPad];
    [self.txtVerify setKeyboardType:UIKeyboardTypeNumberPad];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    if (request.tag == 1) {
        [self.txtMobile setEnabled:false];
        [self.btnSendSms setEnabled:false];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setTimer:) userInfo:nil repeats:YES];
    }
    if (request.tag == 2) {
        if ([result isEqualToString:@"0"]) {
            [self.view makeToast:@"手机号认证失败"];
        }
        else {
            IndexViewController *indexC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
            indexC.toastType = 2;
            [self.navigationController popViewControllerAnimated:true];
        }
    }
    [loadView stopAnimating];
}

- (IBAction)confirmCertificate:(id)sender {
    [self.txtMobile resignFirstResponder];
    [self.txtVerify resignFirstResponder];
    NSString *mobile = self.txtMobile.text;
    if (mobile.length == 0) {
        [self.view makeToast:@"请输入手机号"];
        return;
    }
    if (![CommonController isValidateMobile:mobile]) {
        [self.view makeToast:@"请输入有效的手机号"];
        return;
    }
    if (self.txtVerify.text.length == 0) {
        [self.view makeToast:@"请输入验证码"];
        return;
    }
    [loadView startAnimating];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:self.txtMobile.text forKey:@"mobile"];
    [dicParam setObject:self.txtVerify.text forKey:@"verifyCode"];
    [dicParam setObject:[userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UpdatePaVerifyDate" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 2;
    self.runningRequest = request;
    [dicParam release];
}

- (IBAction)sendSms:(id)sender {
    [self.txtMobile resignFirstResponder];
    [self.txtVerify resignFirstResponder];
    NSString *mobile = self.txtMobile.text;
    if (mobile.length == 0) {
        [self.view makeToast:@"请输入手机号"];
        return;
    }
    if (![CommonController isValidateMobile:mobile]) {
        [self.view makeToast:@"请输入有效的手机号"];
        return;
    }
    [loadView startAnimating];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:self.txtMobile.text forKey:@"mobile"];
    [dicParam setObject:[userDefaults objectForKey:@"subSiteName"] forKey:@"subSiteName"];
    [dicParam setObject:[userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetPaVerifyCode" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 1;
    self.runningRequest = request;
    [dicParam release];
}

- (IBAction)backgroundTap:(id)sender
{
    [self.txtMobile resignFirstResponder];
    [self.txtVerify resignFirstResponder];
}

- (void)setTimer:(NSTimer *)timer
{
    if (secondSend == 0) {
        [self.btnSendSms setEnabled:true];
        [self.btnSendSms setTitle:@"重新认证" forState:UIControlStateNormal];
        [timer invalidate];
        secondSend = 180;
        return;
    }
    [self.btnSendSms setTitle:[NSString stringWithFormat:@"%d秒后重试",secondSend] forState:UIControlStateDisabled];
    secondSend--;
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
    [_viewMobile release];
    [_btnSendSms release];
    [_txtMobile release];
    [_txtVerify release];
    [_btnMobileCer release];
    [_runningRequest release];
    [loadView release];
    [_mobile release];
    [super dealloc];
}
@end
