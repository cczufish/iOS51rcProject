#import "FindPsdStep3ViewController.h"
#import "Dialog.h"
#import "CommonController.h"
#import "NetWebServiceRequest.h"
#import "GDataXMLNode.h"
#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "LoginViewController.h"

@interface FindPsdStep3ViewController () <NetWebServiceRequestDelegate>
@property (retain, nonatomic) IBOutlet UITextField *txtUserName;
@property (retain, nonatomic) IBOutlet UITextField *txtPsd;
@property (retain, nonatomic) IBOutlet UITextField *txtRePsd;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) IBOutlet UIButton *btnOK;
@property (retain, nonatomic) LoadingAnimationView *loadingView;
@property (retain, nonatomic) NSString *code;
@property (retain, nonatomic) NSString *wsName;
@property (retain, nonatomic) IBOutlet UILabel *labelLine1;
@property (retain, nonatomic) IBOutlet UILabel *labelLine2;
@property (retain, nonatomic) IBOutlet UILabel *labelBg;
@end

@implementation FindPsdStep3ViewController

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
    
    //设置样式
    self.txtUserName.layer.borderWidth = 1;
    self.txtUserName.layer.borderColor = [UIColor whiteColor].CGColor;
    self.txtPsd.layer.borderWidth = 1;
    self.txtPsd.layer.borderColor = [UIColor whiteColor].CGColor;
    self.txtRePsd.layer.borderWidth = 1;
    self.txtRePsd.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.labelBg.layer.borderWidth = 0.3;
    self.labelBg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.labelBg.layer.cornerRadius = 5;
    
    self.labelLine1.layer.borderWidth = 0.15;
    self.labelLine1.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.labelLine1 setFrame:CGRectMake(24, 125.5, 273, 0.5)];
   
    self.labelLine2.layer.borderWidth = 0.15;
    self.labelLine2.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.labelLine2 setFrame:CGRectMake(24, 170.5, 273, 0.5)];
    
    UIButton *button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [button setTitle: @"重置密码" forState: UIControlStateNormal];
    [button sizeToFit];
    self.navigationItem.titleView = button;
    
    self.txtUserName.text = self.userName;
    //自定义从下一个视图左上角，“返回”本视图的按钮
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"后退" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem=backButton;
    self.btnOK.layer.cornerRadius = 5;
    self.btnOK.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:90/255.0 blue:39/255.0 alpha:1].CGColor;
}

//隐藏键盘
-(IBAction)textFiledReturnEditing:(id)sender {
    [sender resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)btnResetPsd:(id)sender {
    [self.txtPsd resignFirstResponder];
    [self.txtRePsd resignFirstResponder];
    [self.txtUserName resignFirstResponder];
    
    self.userName=self.txtUserName.text;
    NSString *passWord= self.txtPsd.text;
    NSString *rePassord=self.txtRePsd.text;
    
    BOOL result = [self checkInput:self.userName Password:passWord RePassword:rePassord];
    if (!result) {
        return;
    }
    //首先getcode
    [self getCode:self.paMainID];
    
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

//成功
- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    if ([self.wsName isEqual: @"ResetPassword"]) {
        [self didResetPsd:result];
        [result retain];
    }
    else if ([self.wsName isEqual: @"GetPaAddDate"]){
        [self didReceiveGetCodeData: result];
        [result retain];
    }
    //[result retain];
}

//成功设置密码
-(void) didResetPsd:(NSString*) result
{
    [self.loadingView stopAnimating];
    if([result isEqualToString:@"-3"] || [result isEqualToString:@""])
    {
        [Dialog alert:@"提交错误，请检查您的网络链接，并稍后重试……"];
        return ;
    }
    else if([result isEqualToString:@"0"])
    {
        [Dialog alert:@"修改失败，信息已经过期... ..."];
        return;
    }
    else if([result intValue] > 0)
    {
        [Dialog alert:@"修改成功"];
        [CommonController logout];//清除数据
        //跳转到登录界面
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
        LoginViewController *loginC = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginView"];
        [self.navigationController pushViewController:loginC animated:true];
    }
    else
    {
        [Dialog alert:@"未知错误"];
        return;
    }
}
//成功获取code
-(void) didReceiveGetCodeData:(NSString*) result
{
    self.code = @"";
    self.code = [self.code stringByAppendingFormat:@"%@%@%@%@%@",[result substringWithRange:NSMakeRange(11,2)],
     [result substringWithRange:NSMakeRange(0,4)],[result substringWithRange:NSMakeRange(14,2)],
     [result substringWithRange:NSMakeRange(8,2)],[result substringWithRange:NSMakeRange(5,2)]];
    
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.paMainID forKey:@"paMainID"];
    [dicParam setObject:self.txtRePsd.text forKey:@"password"];
    [dicParam setObject:@"IOS" forKey:@"ip"];
    [dicParam setObject:self.code forKey:@"code"];
    
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"ResetPassword" Params:dicParam];
    
    [request startAsynchronous];
    [request setDelegate:self];
    self.runningRequest = request;
    self.wsName = @"ResetPassword";
}

//从webservice获取code
-(void) getCode:(NSString* ) userID
{
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:userID forKey:@"paMainID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetPaAddDate" Params:dicParam];
    
    [request startAsynchronous];
    [request setDelegate:self];
    self.runningRequest = request;
    self.wsName = @"GetPaAddDate";
}

- (BOOL)checkInput:(NSString *)userName Password:(NSString*) passWord RePassword:(NSString*) rePsd
{
    BOOL result = true;
    
    if(userName==nil||[userName isEqualToString:@""]){
        //提示输入信息
        [Dialog alert:@"请输入邮箱"];
        result = false;
    }
    if(passWord==nil
       ||[passWord isEqualToString:@""]){
        
        [Dialog alert:@"请输入密码"];
        result = false;
    }
    if([self.userName length]>50){
        
        [Dialog alert:@"邮箱长度不能超过50位"];
        result = false;
    }
    
    if (![CommonController checkEmail:self.userName]) {
        [Dialog alert:@"邮箱格式不正确"];
        result = false;
    }
    if(![rePsd isEqualToString:passWord]){
        if(rePsd==nil||[rePsd length]==0){
            [Dialog alert:@"重复密码不能为空"];
            result = false;
        }else{
            [Dialog alert:@"两次密码输入不一致"];
            result = false;
        }
    }
    
    if([passWord length]<6|| [passWord length]>20){
        [Dialog alert:@"密码长度为6-20！"];
        result = false;
    }
    
    if (![CommonController checkPassword:passWord]) {
        [Dialog alert:@"密码只能使用字母、数字、横线、下划线、点"];
        result = false;
    }
    return result;
}

- (void)dealloc {
    [_txtUserName release];
    [_txtPsd release];
    [_txtRePsd release];
    [_btnOK release];
    [_labelLine1 release];
    [_labelLine2 release];
    [_labelBg release];
    [super dealloc];
}
@end
