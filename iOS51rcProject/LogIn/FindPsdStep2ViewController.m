//
//  FindPsdStep2ViewController.m
//  iOS51rcProject
//
//  Created by qlrc on 14-8-15.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import "FindPsdStep2ViewController.h"
#import "Dialog.h"
#import "CommonController.h"
#import "NetWebServiceRequest.h"
#import "GDataXMLNode.h"
#import <UIKit/UIKit.h>
#import "FindPsdStep3ViewController.h"
#import "LoadingAnimationView.h"

@interface FindPsdStep2ViewController ()<NetWebServiceRequestDelegate>
@property (retain, nonatomic) IBOutlet UITextField *txtUserName;
@property (retain, nonatomic) IBOutlet UITextField *txtVerifyCode;
@property (retain, nonatomic) IBOutlet UILabel *txtLabel;
@property (retain, nonatomic) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) IBOutlet UIButton *btnNext;
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
    UIButton *button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [button setTitle: @"重置密码" forState: UIControlStateNormal];
    [button sizeToFit];
    self.navigationItem.titleView = button;
    
    if ([self.type  isEqual: @"1"]) {
        self.txtLabel.text = @"您的邮箱";
    }else    {
        self.txtLabel.text = @"您的手机号";
    }
    self.txtUserName.text = self.name;//手机号或者邮箱
    
    //自定义从下一个视图左上角，“返回”本视图的按钮
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"后退" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem=backButton;
    self.btnNext.layer.cornerRadius = 5;
    self.btnNext.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:90/255.0 blue:39/255.0 alpha:1].CGColor;
}
- (IBAction)btnResetPsd:(id)sender {
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
    [_txtUserName release];
    [_txtVerifyCode release];
    [_txtLabel release];
    [_btnNext release];
    [super dealloc];
}
@end
