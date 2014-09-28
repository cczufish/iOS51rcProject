#import "ChangeNameViewController.h"
#import "NetWebServiceRequest.h"
#import "CommonController.h"
#import "LoadingAnimationView.h"
#import "Dialog.h"
#import "GDataXMLNode.h"
#import <UIKit/UIKit.h>
#import "IndexViewController.h"

@interface ChangeNameViewController ()<NetWebServiceRequestDelegate>

@property (retain, nonatomic) IBOutlet UILabel *lbOldUserName;
@property (retain, nonatomic) IBOutlet UITextField *txtPsd;
@property (retain, nonatomic) IBOutlet UITextField *txtNewUserName;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) IBOutlet UIButton *btnOK;
@property (retain, nonatomic) LoadingAnimationView *loadingView;
@property (retain, nonatomic) NSString *code;
@property (retain, nonatomic) IBOutlet UIView *viewTop;
@end

@implementation ChangeNameViewController

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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strUserName = [userDefaults objectForKey:@"UserName"];
    self.lbOldUserName.text = strUserName;
     
    //设置样式
    self.btnOK.layer.cornerRadius = 5;
    self.viewTop.layer.borderWidth = 0.5;
    self.viewTop.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.viewTop.layer.cornerRadius = 5;
   
    self.txtPsd.layer.borderWidth = 1;
    self.txtPsd.layer.borderColor = [UIColor whiteColor].CGColor;
    self.txtNewUserName.layer.borderWidth = 1;
    self.txtNewUserName.layer.borderColor = [UIColor whiteColor].CGColor;
}

//隐藏键盘
-(IBAction)textFiledReturnEditing:(id)sender {
    [sender resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//修改姓名
- (IBAction)btnResetPsd:(id)sender {
    [self.txtPsd resignFirstResponder];
    [self.txtNewUserName resignFirstResponder];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *passWord= self.txtPsd.text;
    NSString *strNewUserName=self.txtNewUserName.text;
    
    BOOL result = [self checkInput:passWord NewUserName:strNewUserName];
    if (!result) {
        return;
    }
 
    NSString *userID = [userDefaults objectForKey:@"UserID"];
    NSString *code = [userDefaults objectForKey:@"code"];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    
    [dicParam setObject: userID forKey:@"paMainID"];
    [dicParam setObject:self.txtPsd.text forKey:@"Password"];
    [dicParam setObject:self.txtNewUserName.text forKey:@"Username"];
    [dicParam setObject:code forKey:@"code"];
    
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UpdateUserName" Params:dicParam];
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

//成功修改名称
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
        [Dialog alert:@"验证身份失败！"];
        return;
    }
    else if([result isEqualToString:@"-100"])
    {
        [Dialog alert:@"Code值错误！"];
        return;
    }
    else if([result isEqualToString:@"10"])
    {
        [Dialog alert:@"用户名不是邮箱！"];
        return;
    }
    else if([result isEqualToString:@"11"])
    {
        [Dialog alert:@"用户名重复！"];
        return;
    }
    else if([result intValue] == 1)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:self.txtNewUserName.text forKey:@"UserName"];
        
        UIViewController *pCtrl = [CommonController getFatherController:self.view];
        IndexViewController *indexCtrl = [pCtrl.navigationController.viewControllers objectAtIndex:pCtrl.navigationController.viewControllers.count-2];
        indexCtrl.toastType = 4;
        //跳转上一个界面
        [pCtrl.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [Dialog alert:@"未知错误"];
        return;
    }
}

- (BOOL)checkInput:(NSString*) passWord NewUserName:(NSString*) newUserName
{
    BOOL result = true;
    if ([passWord length]<6||[passWord length]>20) {
        [Dialog alert:@"密码长度在6-20位之间"];
        result = false;
    }
    else if (![CommonController checkEmail:newUserName]) {
        [Dialog alert:@"新用户名必须为邮箱格式"];
        result = false;
    }
    return result;
}

- (void)dealloc {   
    [_viewTop release];
    [_txtPsd release];
    [_txtNewUserName release];
    [_btnOK release];
    [_lbOldUserName release];
    [super dealloc];
}
@end
