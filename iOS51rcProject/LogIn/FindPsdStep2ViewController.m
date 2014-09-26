#import "FindPsdStep2ViewController.h"
#import "Dialog.h"
#import "CommonController.h"
#import "NetWebServiceRequest.h"
#import "GDataXMLNode.h"
#import <UIKit/UIKit.h>
#import "FindPsdStep3ViewController.h"
#import "LoadingAnimationView.h"
#import "Toast+UIView.h"
#import "LoadingAnimationView.h"

@interface FindPsdStep2ViewController ()<NetWebServiceRequestDelegate>
{
    int secondSend;
    LoadingAnimationView *loadView;
}

@property (retain, nonatomic) IBOutlet UITextField *txtUserName;
@property (retain, nonatomic) IBOutlet UITextField *txtVerifyCode;
@property (retain, nonatomic) IBOutlet UILabel *txtLabel;
@property (retain, nonatomic) IBOutlet UIButton *btnNext;
@property (retain, nonatomic) IBOutlet UIButton *btnSendSms;
@property (retain, nonatomic) IBOutlet UIView *viewPsdStep2;
@property (retain, nonatomic) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) LoadingAnimationView *loadingView;

@end

@implementation FindPsdStep2ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//隐藏键盘
-(IBAction)textFiledReturnEditing:(id)sender {
    [sender resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    secondSend = 10;
    
    UIButton *button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [button setTitle: @"重置密码" forState: UIControlStateNormal];
    [button sizeToFit];
    self.navigationItem.titleView = button;
    
    [self.txtUserName setEnabled:false];
    if ([self.type  isEqual: @"1"]) {
        self.txtLabel.text = @"您的邮箱";
        self.btnSendSms.hidden = true;
    }else    {
        [self.btnSendSms setEnabled:false];
        self.txtLabel.text = @"您的手机号";
    }
    
    self.viewPsdStep2.layer.borderWidth = 1;
    self.viewPsdStep2.layer.borderColor = [UIColor colorWithRed:236.f/255.0 green:236.f/255.0 blue:236.f/255.0 alpha:1].CGColor;
    self.viewPsdStep2.layer.cornerRadius = 5;
    
    self.txtUserName.text = self.name;//手机号或者邮箱
    self.btnNext.layer.cornerRadius = 5;
    self.btnNext.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:90/255.0 blue:39/255.0 alpha:1].CGColor;
    //设置为数字键盘
    [self.txtVerifyCode setKeyboardType:UIKeyboardTypeNumberPad];
    //倒计时
     [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setTimer:) userInfo:nil repeats:YES];
}
- (IBAction)btnResetPsd:(id)sender {
    [self.txtVerifyCode resignFirstResponder];
    [self.txtUserName resignFirstResponder];
    [self GetCode];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//输入激活码点击下一步
- (void)GetCode {
    NSString *receiveCode = self.txtVerifyCode.text;
    
    if([receiveCode isEqualToString:@"" ])
    {
        [Dialog alert:@"请输入验证码"];
        return;
    }
    if(receiveCode.length != 6)
    {
        [Dialog alert:@"激活码为6位数字"];
        return;
    }

    verifyCode = receiveCode;
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.code forKey:@"UniqueId"];
    [dicParam setObject:receiveCode forKey:@"type"];//第二个参数是手机或者邮箱收到的ID
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetPasswordLog" Params:dicParam];
    
    [request startAsynchronous];
    [request setDelegate:self];
    self.runningRequest = request;
    
    //缓冲界面
    self.loadingView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    [self.loadingView startAnimating];
}

//失败
- (void)netRequestFailed:(NetWebServiceRequest *)request didRequestError:(int *)error
{
    [self.loadingView stopAnimating];
    [Dialog alert:@"出现意外错误"];
    return;
}

//验证激活码返回成功后操作
- (void)netRequestFinished:(NetWebServiceRequest *)request finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        [self.txtUserName setEnabled:false];
        [self.btnSendSms setEnabled:false];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setTimer:) userInfo:nil repeats:YES];
    }else
    {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSMutableArray *Array = (NSMutableArray* ) requestData;
        NSDictionary *rowData = Array[0];
        NSString *strTmp = rowData[@"ActivateCode"];
        if (![verifyCode isEqualToString:strTmp]) {
            [Dialog alert:@"您输入的激活码信息不正确，请查证！"];
        }
        else
        {
            [userDefault setValue: rowData[@"paMainID"] forKeyPath:@"UserID"];
            [userDefault setValue: rowData[@"UserName"] forKeyPath:@"UserName"];
            [userDefault setValue: rowData[@"AddDate"] forKeyPath:@"AddDate"];
            
            FindPsdStep3ViewController *find3Ctr = [self.storyboard instantiateViewControllerWithIdentifier: @"findPsd3View"];
            find3Ctr.userName = rowData[@"UserName"];
            find3Ctr.paMainID = rowData[@"paMainID"];
            [self.navigationController pushViewController:find3Ctr animated:YES];
        }
        
        [result retain];
    }
}

//重新验证
- (IBAction)sendSms:(id)sender {
    [self.txtUserName resignFirstResponder];
    [self.txtVerifyCode resignFirstResponder];
    NSString *mobile = self.txtUserName.text;
    if (mobile.length == 0) {
        [self.view makeToast:@"请输入手机号"];
        return;
    }
    if (![CommonController isValidateMobile:mobile]) {
        [self.view makeToast:@"请输入有效的手机号"];
        return;
    }
    [loadView startAnimating];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *provinceID=[defaults stringForKey:@"provinceID"];
    provinceID = @"32";
    
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.txtUserName.text forKey:@"userName"];
    [dicParam setObject:self.txtUserName.text forKey:@"email"];
    [dicParam setObject:self.txtUserName.text forKey:@"mobile"];
    [dicParam setObject:@"IOS" forKey:@"ip"];
    [dicParam setObject:@"" forKey:@"strPageHost"];
    [dicParam setObject:@"" forKey:@"subsiteName"];
    [dicParam setObject:provinceID forKey:@"provinceID"];
    
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"paGetPassword" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 1;
    self.runningRequest = request;
    [dicParam release];
}

//输入倒计时
- (void)setTimer:(NSTimer *)timer
{
    if (secondSend == 0) {
        [self.btnSendSms setEnabled:true];
        [self.btnSendSms setTitle:@"重新验证" forState:UIControlStateNormal];
        [timer invalidate];
        secondSend = 160;
        return;
    }
    [self.btnSendSms setTitle:[NSString stringWithFormat:@"%d秒后重试",secondSend] forState:UIControlStateDisabled];
    secondSend--;
}

- (void)dealloc {
    if (self.btnSendSms != nil) {
        [_btnSendSms release];
    }
    [loadView release];
    [_txtUserName release];
    [_txtVerifyCode release];
    [_txtLabel release];
    [_btnNext release];
    [_viewPsdStep2 release];
    [super dealloc];
}
@end
