#import "LoginDetailsViewController.h"
#import "FindPsdStep1ViewController.h"
#import "NetWebServiceRequest.h"
#import "GDataXMLNode.h"
#import "CommonController.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CommonController.h"
#import "LoadingAnimationView.h"
#import "Toast+UIView.h"
#import "BPush.h"

@interface LoginDetailsViewController ()<NetWebServiceRequestDelegate>
@property (retain, nonatomic) IBOutlet UITextField *txtName;
@property (retain, nonatomic) IBOutlet UITextField *txtPsd;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) IBOutlet UIButton *btnLogin;
@property (retain, nonatomic) IBOutlet UIImageView *imgAutoLogin;
@property (retain, nonatomic) IBOutlet UIButton *btnAutoLogin;
@property (nonatomic, retain) LoadingAnimationView *loginLoading;
@property (retain, nonatomic) IBOutlet UIView *viewLogin;
@end


@implementation LoginDetailsViewController
@synthesize gotoHomeDelegate;
@synthesize delegate;
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
    self.viewLogin.layer.borderWidth = 0.5;
    self.viewLogin.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.viewLogin.layer.cornerRadius = 5;
    
    self.txtName.layer.borderWidth = 1;
    self.txtName.layer.borderColor = [UIColor whiteColor].CGColor;
    self.txtPsd.layer.borderWidth = 1;
    self.txtPsd.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btnLogin.layer.cornerRadius = 5;
    self.btnLogin.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:90/255.0 blue:39/255.0 alpha:1].CGColor;

    isAutoLogin = true;
}

- (IBAction)btnAutoLoginClick:(id)sender {
    isAutoLogin = !isAutoLogin;
    if (isAutoLogin) {
        self.imgAutoLogin.image = [UIImage imageNamed:@"unChecked.png" ];
    }else{
        self.imgAutoLogin.image = [UIImage imageNamed:@"checked.png"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnLoginClick:(id)sender {
    //隐藏键盘
    [self.txtName resignFirstResponder];
    [self.txtPsd resignFirstResponder];
    
    userName = self.txtName.text;
    passWord = self.txtPsd.text;
    if ([CommonController isBlankString:userName]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请输入用户名" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] ;
        [alert show];
        return;
    }
    if ([CommonController isBlankString:passWord]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请输入密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] ;
        [alert show];
        return;
    }
    
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:userName forKey:@"userName"];
    [dicParam setObject:passWord forKey:@"passWord"];
    [dicParam setObject:@"IOS" forKey:@"ip"];
    [dicParam setObject:@"32" forKey:@"provinceID"];
    [dicParam setObject:@"ismobile:IOS" forKey:@"browser"];
    [dicParam setObject:@"0" forKey:@"autoLogin"];
    
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"Login" Params:dicParam];
    
    [request startAsynchronous];
    [request setDelegate:self];
    self.runningRequest = request;
    wsName = @"login";
    //登录缓冲界面
    self.loginLoading = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    [self.loginLoading startAnimating];
}

- (IBAction)btnFindPsd:(id)sender {
    [delegate pushParentsFromLoginDetails];//调用父界面的函数
}

//失败
- (void)netRequestFailed:(NetWebServiceRequest *)request didRequestError:(int *)error
{
    [self.loginLoading stopAnimating];
}

//成功
- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    if ([wsName isEqual: @"login"]) {
        [result retain];
        [self didReceiveLoginData:result];
    }
    else if ([wsName isEqual: @"GetPaAddDate"]){
        [result retain];
        [self didReceiveGetCodeData: result];
    }
    else if ([wsName isEqual:@"GetPaMainInfoByID"]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue: userID forKey:@"UserID"];//PamainID
        [userDefaults setValue: userName forKey:@"UserName"];
        [userDefaults setValue: passWord forKey:@"PassWord"];
        [userDefaults setValue: @"1" forKey:@"BeLogined"];
        [userDefaults setBool: isAutoLogin forKey:@"isAutoLogin"];
        [userDefaults setObject:code forKey:@"code"];
        [userDefaults setObject:requestData[0][@"Name"] forKey:@"paName"];
        [self.loginLoading stopAnimating];
        [NSThread sleepForTimeInterval:1];
        [self.view makeToast:@"登录成功"];
        
        //注册百度push,把自己userID作为push的tag       
        [BPush setTag:userID];
        
        [NSThread sleepForTimeInterval:1];
        [gotoHomeDelegate gotoHome];
    }
}

//接收到登录webservice内容
-(void) didReceiveLoginData:(NSString*) result
{
    if ([result isEqual:@"-1"]) {
        [self.loginLoading stopAnimating];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您今天的登录次数已超过20次的限制，请明天再来。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] ;
        [alert show];
    } else if ([result isEqual:@"-2"]){
        [self.loginLoading stopAnimating];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"请进入用户反馈向我们反映，谢谢配合。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] ;
        [alert show];
    }else if ([result isEqual:@"-3"]){
        [self.loginLoading stopAnimating];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"提交错误，请检查您的网络链接，并稍后重试……" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] ;
        [alert show];
    }else if ([result isEqual:@"0"]){
        [self.loginLoading stopAnimating];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"用户名或密码错误，请重新输入！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] ;
        [alert show];
    }else if (result > 0){
        userID = result;
        [self getCode:result];
    }else {
        [self.loginLoading stopAnimating];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您今天的登录次数已超过20次的限制，请明天再来。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] ;
        [alert show];
    }
}

-(void) didReceiveGetCodeData:(NSString*) result
{
    NSString *realCode=@"";
    realCode =
        [realCode stringByAppendingFormat:@"%@%@%@%@%@",[result substringWithRange:NSMakeRange(11,2)],
        [result substringWithRange:NSMakeRange(0,4)],[result substringWithRange:NSMakeRange(14,2)],
        [result substringWithRange:NSMakeRange(8,2)],[result substringWithRange:NSMakeRange(5,2)]];

    code = realCode;
    [self getPaName];
}

//从webservice获取code
-(void) getCode:(NSString* ) _userID
{
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:_userID forKey:@"paMainID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetPaAddDate" Params:dicParam];
    
    [request startAsynchronous];
    [request setDelegate:self];
    self.runningRequest = request;
    wsName = @"GetPaAddDate";
}

//从webservice获取姓名
-(void) getPaName
{
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:userID forKey:@"paMainID"];
    [dicParam setObject:code forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetPaMainInfoByID" Params:dicParam];
    
    [request startAsynchronous];
    [request setDelegate:self];
    self.runningRequest = request;
    wsName = @"GetPaMainInfoByID";
}

//隐藏键盘
-(IBAction)textFiledReturnEditing:(id)sender {
    [sender resignFirstResponder];
}

- (void)dealloc {
    [_txtName release];
    [_txtPsd release];
    [_btnLogin release];
    [_imgAutoLogin release];
    [_btnAutoLogin release]; 
    [_viewLogin release];
    [super dealloc];
}
@end
