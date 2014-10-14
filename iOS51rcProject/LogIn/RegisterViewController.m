//
//  RegisterViewController.m
//  iOS51rcProject
//
//  Created by qlrc on 14-8-15.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import "RegisterViewController.h"
#import "Dialog.h"
#import "CommonController.h"
#import "NetWebServiceRequest.h"
#import "GDataXMLNode.h"
#import <UIKit/UIKit.h>
#import "LoadingAnimationView.h"
#import "CustomPopup.h"
#import "LoadingAnimationView.h"
#import "Toast+UIView.h"
#import "CvModifyViewController.h"

#define TAG_CreateResumeOrNot 1
#define TAG_RESUME 2

@interface RegisterViewController () <CreateResumeDelegate, NetWebServiceRequestDelegate>
{
    LoadingAnimationView *loadView;
    int secondSend;
}
@property (retain, nonatomic) IBOutlet UITextField *txtUserName;
@property (retain, nonatomic) IBOutlet UITextField *txtPsd;
@property (retain, nonatomic) IBOutlet UITextField *txtRePsd;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) IBOutlet UIButton *btnRegister;
@property (retain, nonatomic) IBOutlet UIView *viewRegister;
@property (retain, nonatomic) IBOutlet UIView *viewEmailReg;
@property (retain, nonatomic) IBOutlet UIView *viewMobileReg;
@property (retain, nonatomic) IBOutlet UIButton *btnMobileReg;
@property (retain, nonatomic) IBOutlet UIButton *btnEmailReg;
@property (retain, nonatomic) IBOutlet UITextField *txtMobile;
@property (retain, nonatomic) IBOutlet UITextField *txtPsdMobile;
@property (retain, nonatomic) IBOutlet UITextField *txtRePsdMobile;
@property (retain, nonatomic) IBOutlet UITextField *txtMobileCer;
@property (retain, nonatomic) IBOutlet UIButton *btnMobileCer;
@property (retain, nonatomic) IBOutlet UIView *viewMobile;
@property (retain, nonatomic) IBOutlet UIButton *btnMobileConfirm;
@property (nonatomic, retain) CustomPopup *cPopup;
@end

@implementation RegisterViewController
@synthesize gotoHomeDelegate;
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
    self.viewRegister.layer.borderWidth = 1;
    self.viewRegister.layer.borderColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
    self.viewRegister.layer.cornerRadius = 5;

    self.btnRegister.layer.cornerRadius = 5;
    self.btnRegister.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:90/255.0 blue:39/255.0 alpha:1].CGColor;
    
    self.viewMobile.layer.borderWidth = 1;
    self.viewMobile.layer.borderColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
    self.viewMobile.layer.cornerRadius = 5;
    
    self.btnMobileConfirm.layer.cornerRadius = 5;
    self.btnMobileConfirm.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:90/255.0 blue:39/255.0 alpha:1].CGColor;
    
    self.btnMobileCer.layer.cornerRadius = 5;
    self.btnMobileCer.layer.borderWidth = 1;
    self.btnMobileCer.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    createResumeCtrl =[[CreateResumeAlertViewController alloc] init];
    createResumeCtrl.delegate = self;
    
    secondSend = 180;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//隐藏键盘
-(IBAction)textFiledReturnEditing:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)btnRegisterClick:(id)sender {
    //隐藏键盘
    [self hideKeyboard];
    
    userName=self.txtUserName.text;
    password= self.txtPsd.text; 
    rePassword=self.txtRePsd.text;
    
    //检查参数
    BOOL result = [self checkInput:userName Password:password RePassword:rePassword];
    if (!result) {
        return;
    }
    else {
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setObject:userName forKey:@"email"];
        [dicParam setObject:password forKey:@"password"];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [dicParam setObject:[userDefault objectForKey:@"subSiteId"] forKey:@"provinceid"];
        [dicParam setObject:@"6" forKey:@"registermod"];
        [dicParam setObject:@"IOS" forKey:@"ip"];
        
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"Register" Params:dicParam];
        [request startAsynchronous];
        [request setDelegate:self];
        request.tag = 1;
        self.runningRequest = request;
    }
    //缓冲界面
    if (loadView == nil) {
        loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    }
    [loadView startAnimating];
}

- (IBAction)mobileRegister:(id)sender {
    //隐藏键盘
    [self hideKeyboard];
    
    userName=self.txtMobile.text;
    password= self.txtPsdMobile.text;
    rePassword=self.txtRePsdMobile.text;
    
    //检查参数
    BOOL result = [self checkMobileInput:userName Password:password RePassword:rePassword mobileCode:self.txtMobileCer.text];
    if (!result) {
        return;
    }
    else{
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setObject:userName forKey:@"mobile"];
        [dicParam setObject:self.txtMobileCer.text forKey:@"mobileCheckCode"];
        [dicParam setObject:password forKey:@"password"];
        [dicParam setObject:[userDefault objectForKey:@"subSiteId"] forKey:@"provinceid"];
        [dicParam setObject:@"6" forKey:@"registermod"];
        [dicParam setObject:@"IOS" forKey:@"ip"];
        
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"MobileRegister" Params:dicParam];
        [request startAsynchronous];
        [request setDelegate:self];
        request.tag = 5;
        self.runningRequest = request;
    }
    //缓冲界面
    if (loadView == nil) {
        loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    }
    [loadView startAnimating];
}

- (void)hideKeyboard
{
    [self.txtPsd resignFirstResponder];
    [self.txtRePsd resignFirstResponder];
    [self.txtUserName resignFirstResponder];
    [self.txtMobileCer resignFirstResponder];
    [self.txtMobile resignFirstResponder];
    [self.txtPsdMobile resignFirstResponder];
    [self.txtRePsdMobile resignFirstResponder];
}

- (IBAction)getMobileCode:(UIButton *)sender {
    [self hideKeyboard];
    NSString *mobile = self.txtMobile.text;
    if (mobile.length == 0) {
        [Dialog alert:@"请输入手机号"];
        return;
    }
    if (![CommonController isValidateMobile:mobile]) {
        [Dialog alert:@"请输入有效的手机号"];
        return;
    }
    if (loadView == nil) {
        loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    }
    [loadView startAnimating];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:mobile forKey:@"strMobile"];
    [dicParam setObject:@"IOS" forKey:@"strIP"];
    [dicParam setObject:[userDefaults objectForKey:@"subSiteName"] forKey:@"subSiteName"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetMobileCheckCode" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 4;
    self.runningRequest = request;
    [dicParam release];
}

- (IBAction)switchToEmailReg:(id)sender {
    [self.viewEmailReg setHidden:false];
    [self.viewMobileReg setHidden:true];
}

- (IBAction)switchToMobileReg:(id)sender {
    [self.viewEmailReg setHidden:true];
    [self.viewMobileReg setHidden:false];
}

//失败
- (void)netRequestFailed:(NetWebServiceRequest *)request didRequestError:(int *)error
{
    [loadView stopAnimating];
    [Dialog alert:@"出现意外错误"];
    return;
}

//成功
- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    if (request.tag == 1) {
        [self didReceiveRegisterData:result];
    }
    else if (request.tag == 2)
    {
        [loadView stopAnimating];
        [self didReceiveGetCode:result];
    }
    else if (request.tag == 3) {
        if ([result isEqualToString:@"0"]) {
            [self.view makeToast:@"已经创建了3份简历了"];
            return;
        }
        UIViewController *pCtrl = [CommonController getFatherController:self.view];
        UIStoryboard *userCenterStoryboard = [UIStoryboard storyboardWithName:@"UserCenter" bundle:nil];
        CvModifyViewController *cvModifyC = [userCenterStoryboard instantiateViewControllerWithIdentifier:@"CvModifyView"];
        cvModifyC.cvId = result;
        [pCtrl.navigationController pushViewController:cvModifyC animated:true];
    }
    else if (request.tag == 4) {
        NSInteger intResult = [result intValue];
        if(intResult == -1)
        {
            [Dialog alert:@"同一个IP一天内手机号注册超过20个"];
        }
        else if(intResult == -2)
        {
            [Dialog alert:@"该手机号60天内认证过"];
        }
        else if(intResult == -3)
        {
            [Dialog alert:@"程序异常！"];
        }
        else if(intResult == -4)
        {
            [Dialog alert:@"该手机号已经认证过"];
        }
        else if(intResult == 0)
        {
            [Dialog alert:@"当天认证次数已大于4次，无法发送验证码，请明天再试"];
        }
        else
        {
            [self.btnMobileCer setEnabled:false];
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setTimer:) userInfo:nil repeats:YES];
        }
    }
    else if (request.tag == 5) {
        [self didReceiveMobileRegisterData:result];
    }
//    [result retain];
    
    [loadView stopAnimating];
}

- (void)setTimer:(NSTimer *)timer
{
    if (secondSend == 0) {
        [self.btnMobileCer setEnabled:true];
        [self.btnMobileCer setTitle:@"重新认证" forState:UIControlStateNormal];
        [timer invalidate];
        secondSend = 180;
        return;
    }
    [self.btnMobileCer setTitle:[NSString stringWithFormat:@"%d秒后重试",secondSend] forState:UIControlStateDisabled];
    secondSend--;
}

-(void) didReceiveRegisterData:(NSString *) result
{
    NSInteger intResult = [result intValue];
    if(intResult == -1)
    {
        [Dialog alert:@"您的电子邮箱已被我们列入黑名单，不再接受注册。如果您有任何疑问，请拨打全国统一客服电话400 626 5151寻求帮助。"];
        return ;
    }
    else if(intResult == -2)
    {
        [Dialog alert:@"您已经使用当前的E-mail注册过一个用户，建议您不要重复注册。"];
        return;
    }
    else if(intResult == -3)
    {
        [Dialog alert:@"用户注册失败！向保存用户信息时数据操作失败！"];
        return;
    }
    else if(intResult == -4)
    {
        [Dialog alert:@"提交错误，请检查您的网络链接，并稍后重试……"];
        return;
    }
    else if(intResult == 0)
    {
        [Dialog alert:@"用户名或密码错误，请重新输入！"];
        return;
    }
    else if(intResult > 0)
    {
        userID = result;
        [self getCode: userID];//获取code
    }
    else
    {
        [Dialog alert:@"未知错误"];
        return;
    }
}

-(void) didReceiveMobileRegisterData:(NSString *) result
{
    NSInteger intResult = [result intValue];
    if(intResult == -1)
    {
        [Dialog alert:@"用户名或密码错误，请重新输入！"];
        return ;
    }
    else if(intResult == -2)
    {
        [Dialog alert:@"验证码不正确！"];
        return;
    }
    else if(intResult == -3)
    {
        [Dialog alert:@"用户注册失败！向保存用户信息时数据操作失败！"];
        return;
    }
    else if(intResult == -4)
    {
        [Dialog alert:@"提交错误，请检查您的网络链接，并稍后重试……"];
        return;
    }
    else if(intResult == 0)
    {
        [Dialog alert:@"用户名或密码错误，请重新输入！"];
        return;
    }
    else if(intResult > 0)
    {
        userID = result;
        [self getCode: userID];//获取code
    }
    else
    {
        [Dialog alert:@"未知错误"];
        return;
    }
}


//获取code
-(void) getCode:(NSString*) paMainID
{
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:paMainID forKey:@"paMainID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetPaAddDate" Params:dicParam];
    
    request.tag = 2;
    [request startAsynchronous];
    [request setDelegate:self];
    self.runningRequest = request;
}

//当点击创建简历
-(void) CreateResume:(BOOL) hasExp
{
    [createResumeCtrl.view removeFromSuperview];
    [backGroundView removeFromSuperview];
    
    int cvType = 2;
    if (hasExp) {
        cvType = 1;
    }
    [loadView startAnimating];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[userDefaults objectForKey:@"code"] forKey:@"code"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",cvType] forKey:@"type"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"CreateResume" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 3;
    self.runningRequest = request;
    [dicParam release];
}

-(void) didReceiveGetCode:(NSString *) result
{
    NSString *realCode=@"";
    realCode =
    [realCode stringByAppendingFormat:@"%@%@%@%@%@",[result substringWithRange:NSMakeRange(11,2)],
     [result substringWithRange:NSMakeRange(0,4)],[result substringWithRange:NSMakeRange(14,2)],
     [result substringWithRange:NSMakeRange(8,2)],[result substringWithRange:NSMakeRange(5,2)]];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue: userID forKey:@"UserID"];
    [userDefaults setValue: userName forKey:@"UserName"];
    [userDefaults setValue: password forKey:@"PassWord"];
    [userDefaults setValue: @"1" forKey:@"BeLogined"];
    [userDefaults setBool: true forKey:@"isAutoLogin"];
    [userDefaults setObject:realCode forKey:@"code"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"帐号已经注册成功，立即创建简历？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: @"确定", nil] ;
    alert.tag = TAG_CreateResumeOrNot;
    [alert show];
}

//注册成功后， 是否创建简历
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == TAG_CreateResumeOrNot) {
        if (buttonIndex == 0) {
           [gotoHomeDelegate gotoHome];
        }
        else {
            backGroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            backGroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
            [self.view addSubview:backGroundView];
            createResumeCtrl.view.frame = CGRectMake(35, 60, 250, 180);
            [self.view addSubview:createResumeCtrl.view];
        }
    }
}

- (BOOL)checkInput:(NSString *)_userName Password:(NSString*) _passWord RePassword:(NSString*) rePsd
{
    BOOL result = true;
    if(_userName==nil||[_userName isEqualToString:@""]){
        //提示输入信息
        [Dialog alert:@"请输入邮箱"];
        result = false;
    }
    else if(_passWord==nil
       ||[_passWord isEqualToString:@""]){
        
        [Dialog alert:@"请输入密码"];
        result = false;
    }
    else if([_userName length]>50){
        
        [Dialog alert:@"邮箱长度不能超过50位"];
        result = false;
    }
    
    else if (![CommonController checkEmail:_userName]) {
        [Dialog alert:@"邮箱格式不正确"];
        result = false;
    }
    else if(![rePsd isEqualToString:_passWord]){
        if(rePsd==nil||[rePsd length]==0){
            [Dialog alert:@"重复密码不能为空"];
            result = false;
        }else{
            [Dialog alert:@"两次输入密码不一致"];
            result = false;
        }
    }
    else if([_passWord length]<6|| [_passWord length]>20){
        [Dialog alert:@"密码长度为6-20位！"];
        result = false;
    }
    else if (![CommonController checkPassword:_passWord]) {
        [Dialog alert:@"密码只能使用字母、数字、横线、下划线、点"];
        result = false;
    }
    return result;
}

- (BOOL)checkMobileInput:(NSString *)_userName Password:(NSString*) _passWord RePassword:(NSString*) rePsd mobileCode:(NSString *) _mobileCode
{
    if(_userName == nil||[_userName isEqualToString:@""]) {
        //提示输入信息
        [Dialog alert:@"请输入手机号"];
        return false;
    }
    
    if (![CommonController isValidateMobile:_userName]) {
        [Dialog alert:@"请输入有效的手机号"];
        return false;
    }
    
    if (_mobileCode.length == 0) {
        [Dialog alert:@"请输入验证码"];
        return false;
    }
    
    if(_passWord==nil||[_passWord isEqualToString:@""]){
        
        [Dialog alert:@"请输入密码"];
        return false;
    }
    
    if(![rePsd isEqualToString:_passWord]){
        if(rePsd==nil||[rePsd length]==0){
            [Dialog alert:@"重复密码不能为空"];
            return false;
        }else{
            [Dialog alert:@"两次输入密码不一致"];
            return false;
        }
    }
    
    if([_passWord length]<6|| [_passWord length]>20){
        [Dialog alert:@"密码长度为6-20位！"];
        return false;
    }
    
    if (![CommonController checkPassword:_passWord]) {
        [Dialog alert:@"密码只能使用字母、数字、横线、下划线、点"];
        return false;
    }
    return true;
}

- (void)dealloc {
    [loadView release];
    //[_cPopup release];
    [_txtUserName release];
    [_txtPsd release];
    [_txtRePsd release];
    [_btnRegister release];
    [_viewRegister release];
    [_viewEmailReg release];
    [_viewMobileReg release];
    [_btnMobileReg release];
    [_btnEmailReg release];
    [_txtMobile release];
    [_txtPsdMobile release];
    [_txtRePsdMobile release];
    [_txtMobileCer release];
    [_btnMobileCer release];
    [_viewMobile release];
    [_btnMobileConfirm release];
    [super dealloc];
}
@end
