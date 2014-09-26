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

#define TAG_CreateResumeOrNot 1
#define TAG_RESUME 2

@interface RegisterViewController () <CreateResumeDelegate, NetWebServiceRequestDelegate>
@property (retain, nonatomic) IBOutlet UITextField *txtUserName;
@property (retain, nonatomic) IBOutlet UITextField *txtPsd;
@property (retain, nonatomic) IBOutlet UITextField *txtRePsd;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) IBOutlet UILabel *labelBg;
@property (retain, nonatomic) IBOutlet UIButton *btnRegister;

@property (retain, nonatomic) IBOutlet UILabel *labelLine1;
@property (retain, nonatomic) IBOutlet UILabel *labelLine2;
@property (retain, nonatomic) LoadingAnimationView *loadingView;
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
    self.txtUserName.layer.borderWidth = 1;
    self.txtRePsd.layer.borderWidth = 1;
    self.txtPsd.layer.borderWidth = 1;
    self.txtUserName.layer.borderColor = [UIColor whiteColor].CGColor;
    self.txtRePsd.layer.borderColor = [UIColor whiteColor].CGColor;
    self.txtPsd.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.labelBg.layer.borderWidth = 0.3;
    self.labelBg.layer.borderColor = [UIColor grayColor].CGColor;
    self.labelBg.layer.cornerRadius = 5;

    self.btnRegister.layer.cornerRadius = 5;
    createResumeCtrl =[[CreateResumeAlertViewController alloc] init];
    self.btnRegister.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:90/255.0 blue:39/255.0 alpha:1].CGColor;
    createResumeCtrl.delegate = self;

    //设置中间的横线
    self.labelLine1.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.labelLine1 setFrame:CGRectMake(24, 75, 273, 0.5f)];
    self.labelLine2.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.labelLine2 setFrame:CGRectMake(24, 115, 273, 0.5f)];    
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
    [self.txtPsd resignFirstResponder];
    [self.txtRePsd resignFirstResponder];
    [self.txtUserName resignFirstResponder];
    userName=self.txtUserName.text;
    password= self.txtPsd.text; 
    rePassword=self.txtRePsd.text;
    
    //检查参数
    BOOL result = [self checkInput:userName Password:password RePassword:rePassword];
    if (!result) {
        return;
    }
    else{
        
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setObject:userName forKey:@"email"];
        [dicParam setObject:password forKey:@"password"];
        [dicParam setObject:@"32" forKey:@"provinceid"];
        [dicParam setObject:@"6" forKey:@"registermod"];
        [dicParam setObject:@"IOS" forKey:@"ip"];
        
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"Register" Params:dicParam];
        [request startAsynchronous];
        [request setDelegate:self];
        self.runningRequest = request;
        wsName = @"Register";
    }
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
    if ([wsName isEqual: @"Register"])
    {
        [self didReceiveRegisterData:result];        
    }
    else if ([wsName isEqualToString:@"GetPaAddDate"])
    {
        [self.loadingView stopAnimating];
        [self didReceiveGetCode:result];
    }
    
    [result retain];
    [self.loadingView stopAnimating];
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


//获取code
-(void) getCode:(NSString*) paMainID
{
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:paMainID forKey:@"paMainID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetPaAddDate" Params:dicParam];
    
    [request startAsynchronous];
    [request setDelegate:self];
    self.runningRequest = request;
    wsName = @"GetPaAddDate";
}

//当点击创建简历
-(void) CreateResume:(BOOL) hasExp
{
    [createResumeCtrl.view removeFromSuperview];
    [backGroundView removeFromSuperview];
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
            createResumeCtrl.view.frame = CGRectMake(20, 60, 280, 180);
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


- (void)dealloc {
    [_txtUserName release];
    [_txtPsd release];
    [_txtRePsd release];
    [_labelBg release];
    [_btnRegister release];
    [_labelLine1 release];
    [_labelLine2 release];
    [super dealloc];
}
@end
