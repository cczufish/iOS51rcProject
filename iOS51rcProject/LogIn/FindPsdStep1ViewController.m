//
//  FindPsdStep1ViewController.m
//  iOS51rcProject
//
//  Created by qlrc on 14-8-15.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import "FindPsdStep1ViewController.h"
#import "Dialog.h"
#import "CommonController.h"
#import "NetWebServiceRequest.h"
#import "GDataXMLNode.h"
#import <UIKit/UIKit.h>
#import "FindPsdStep2ViewController.h"
#import "LoadingAnimationView.h"

@interface FindPsdStep1ViewController ()<NetWebServiceRequestDelegate>
@property (retain, nonatomic) IBOutlet UITextField *txtName;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) IBOutlet UIButton *btnOK;
@property (retain, nonatomic) LoadingAnimationView *loadingView;
@end

@implementation FindPsdStep1ViewController

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
    
    self.btnOK.layer.cornerRadius = 5;
    self.btnOK.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:90/255.0 blue:39/255.0 alpha:1].CGColor;
   
    //自定义从下一个视图左上角，“返回”本视图的按钮
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"后退" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem=backButton;
}

//隐藏键盘
-(IBAction)textFiledReturnEditing:(id)sender {
    [sender resignFirstResponder];
}

//发送验证码
- (IBAction)btnGetCode:(id)sender {
    if(self.txtName.text==nil||[self.txtName.text isEqualToString:@""]){
        //提示输入信息
        [Dialog alert:@"请输入用户名或邮箱或手机号"];
        return;
    }

    userName = @"";
    phone = @"";
    if([CommonController isValidateMobile:self.txtName.text])
    {
        phone = self.txtName.text;
    }
    else{
        userName = self.txtName.text;
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *provinceID=[defaults stringForKey:@"provinceID"];
    provinceID = @"32";
    
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:userName forKey:@"userName"];
    [dicParam setObject:userName forKey:@"email"];
    [dicParam setObject:phone forKey:@"mobile"];
    [dicParam setObject:@"IOS" forKey:@"ip"];
    [dicParam setObject:@"" forKey:@"strPageHost"];
    [dicParam setObject:@"" forKey:@"subsiteName"];
    [dicParam setObject:provinceID forKey:@"provinceID"];
    
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"paGetPassword" Params:dicParam];
    
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
    [self.loadingView stopAnimating];
    
    if([result isEqualToString:@"1"])
    {
        [Dialog alert:@"一个账号一天取回超过5次"];
        return ;
    }
    else if([result isEqualToString:@"2"])
    {
        [Dialog alert:@"一个ip一天取回超过20次"];
        return;
    }
    else if([result isEqualToString:@"3"])
    {
        [Dialog alert:@"手机号码或邮箱格式不正确，请检查！"];
        return;
    }
    else if([result isEqualToString:@"4"])
    {
        [Dialog alert:@"手机号一天取回超过3次"];
        return;
    }
    else if([result isEqualToString:@""])
    {
        [Dialog alert:@"错误，请检查您的网络链接，并稍后重试⋯⋯"];
        return;
    }
    else if([result isEqualToString:@"-1"])
    {
        [Dialog alert:@"提供数据无效，请重新检查输入"];
        return;
    }
    else
    {
        NSRange range = [result rangeOfString:@":"];
        NSString *getWay = [result substringToIndex:range.location];
        NSString *code = [result substringFromIndex:range.location+1];
        range = [code rangeOfString:@":"];
        NSString *email = @"";
        if(range.location!=NSNotFound)
        {
            range = [code rangeOfString:@":"];
            email = [code substringFromIndex:range.location+1];
            code = [code substringToIndex:range.location];
        }
        if([getWay isEqualToString:@"100"])
        {
            NSString *temp = @"激活码已经发送到您的邮箱";
            temp =[temp stringByAppendingString:email];
            temp = [temp stringByAppendingString:@"，请注意查收！"];
            [Dialog alert:temp];
            //转到下一个视图
            FindPsdStep2ViewController *find2Ctr = [self.storyboard instantiateViewControllerWithIdentifier: @"findPsd2View"];
            find2Ctr.code = code;
            find2Ctr.type = @"1";
            find2Ctr.name = userName;
            [self.navigationController pushViewController:find2Ctr animated:YES];
        }
        else
        {
            NSString *temp = @"激活码将发送到您的手机";
            temp =[temp stringByAppendingString: phone];
            temp = [temp stringByAppendingString:@"，请注意查收！"];
            [Dialog alert:temp];
            
            FindPsdStep2ViewController *find2Ctr = [self.storyboard instantiateViewControllerWithIdentifier: @"findPsd2View"];
            find2Ctr.code = code;
            find2Ctr.type = @"2";
            find2Ctr.name = phone;
            [self.navigationController pushViewController:find2Ctr animated:YES];
        }
    }
    
    [result retain];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
}

- (void)dealloc {
    [_txtName release];
    [_btnOK release];
    [super dealloc];
}
@end
