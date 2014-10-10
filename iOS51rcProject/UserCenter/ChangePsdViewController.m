#import "LoadingAnimationView.h"
#import "NetWebServiceRequest.h"
#import "ChangePsdViewController.h"
#import "Dialog.h"
#import "GDataXMLNode.h"
#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "IndexViewController.h"

@interface ChangePsdViewController () <NetWebServiceRequestDelegate>
@property (retain, nonatomic) IBOutlet UITextField *txtOldPsd;
@property (retain, nonatomic) IBOutlet UITextField *txtPsd;
@property (retain, nonatomic) IBOutlet UITextField *txtRePsd;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) IBOutlet UIButton *btnOK;
@property (retain, nonatomic) LoadingAnimationView *loadingView;
@property (retain, nonatomic) NSString *code;
@property (retain, nonatomic) IBOutlet UIView *viewTop;
@property (retain, nonatomic) NSString *lastPsd;
@end

@implementation ChangePsdViewController

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
    self.btnOK.layer.cornerRadius = 5;
    self.viewTop.layer.borderWidth = 0.5;
    self.viewTop.layer.borderColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
    self.viewTop.layer.cornerRadius = 5;
    
    self.txtOldPsd.layer.borderWidth = 1;
    self.txtOldPsd.layer.borderColor = [UIColor whiteColor].CGColor;
    self.txtPsd.layer.borderWidth = 1;
    self.txtPsd.layer.borderColor = [UIColor whiteColor].CGColor;
    self.txtRePsd.layer.borderWidth = 1;
    self.txtRePsd.layer.borderColor = [UIColor whiteColor].CGColor;   
   
    self.navigationItem.title = @"重置密码";
}

//隐藏键盘
-(IBAction)textFiledReturnEditing:(id)sender {
    [sender resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//重置密码
- (IBAction)btnResetPsd:(id)sender {
    [self.txtPsd resignFirstResponder];
    [self.txtRePsd resignFirstResponder];
    [self.txtOldPsd resignFirstResponder];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *oldPsd = [userDefaults objectForKey:@"PassWord"];
    if (![oldPsd isEqualToString:self.txtOldPsd.text]) {
        [Dialog alert:@"旧密码不正确！"];
        return ;

    }
    NSString *passWord= self.txtPsd.text;
    NSString *rePassord=self.txtRePsd.text;
    
    BOOL result = [self checkInput:oldPsd Password:passWord RePassword:rePassord];
    if (!result) {
        return;
    }
    self.lastPsd = self.txtRePsd.text;
    NSString *userID = [userDefaults objectForKey:@"UserID"];
    NSString *code = [userDefaults objectForKey:@"code"];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject: userID forKey:@"paMainID"];
    [dicParam setObject:self.txtRePsd.text forKey:@"password"];
    [dicParam setObject:@"IOS" forKey:@"ip"];
    [dicParam setObject:code forKey:@"code"];
    
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"ResetPassword" Params:dicParam];
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

//成功
- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    [self didResetPsd:result];
    [result retain];
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
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:self.lastPsd forKey:@"PassWord"];
        
         UIViewController *pCtrl = [CommonController getFatherController:self.view];
        IndexViewController *indexCtrl = [pCtrl.navigationController.viewControllers objectAtIndex:pCtrl.navigationController.viewControllers.count-2];
        indexCtrl.toastType = 3;
        //跳转上一个界面
       
        [pCtrl.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [Dialog alert:@"未知错误"];
        return;
    }
}

- (BOOL)checkInput:(NSString *)oldPsd Password:(NSString*) passWord RePassword:(NSString*) rePsd
{
    BOOL result = true;
    if ([oldPsd length]<6||[oldPsd length]>20) {
        [Dialog alert:@"原密码长度在6-20位之间"];
        result = false;
        
    }
    else if ([passWord length]<6||[rePsd length]>20) {
        [Dialog alert:@"新密码长度在6-20位之间"];
        result = false;
    }
    else if(![rePsd isEqualToString:passWord]){
        if(rePsd==nil||[rePsd length]==0){
            [Dialog alert:@"确认密码不能为空"];
            result = false;
        }else{
            [Dialog alert:@"两次密码输入不一致"];
            result = false;
        }
    }
    
   else if (![CommonController checkPassword:passWord]) {
        [Dialog alert:@"密码只能使用字母、数字、横线、下划线、点"];
        result = false;
    }
    return result;
}

- (void)dealloc {
    [_lastPsd release];
    [_viewTop release];
    [_txtPsd release];
    [_txtRePsd release];
    [_btnOK release];
    [super dealloc];
}
@end
