//
//  LoginViewController.m
//  iOS51rcProject
//
//  Created by qlrc on 14-8-15.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import "LoginViewController.h"
#import "NetWebServiceRequest.h"
#import "GDataXMLNode.h"
#import "CommonController.h"
#import "FindPsdStep1ViewController.h"
#import "FindPsdStep3ViewController.h"


@interface LoginViewController ()
@property (retain, nonatomic) IBOutlet UILabel *labelBgLogin;//登录背景条
@property (retain, nonatomic) IBOutlet UILabel *labelBgRegister;//注册背景条
@property (retain, nonatomic) IBOutlet UIButton *btnLogin;
@property (retain, nonatomic) IBOutlet UIButton *btnRegister;

@end

@implementation LoginViewController

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
   
    self.labelBgRegister.backgroundColor = [UIColor clearColor];
    self.navigationItem.title = @"登录";
    //返回按钮
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc] initWithTitle:@"后退" style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.backBarButtonItem = btnBack;
    [btnBack release];
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.origin.y = 107;//状态栏和切换栏的高度
    frame.size.height = frame.size.height - 107;
    //获得子View
    self.loginDetailsView = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginDetailsView"];
    self.registerView = [self.storyboard instantiateViewControllerWithIdentifier:@"RegisterView"];
    self.loginDetailsView.view.frame = frame;
    self.registerView.view.frame = frame;
    
    //初始化左侧和右侧的登录以及注册子View
    self.leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    self.rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    self.leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    self.rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:self.leftSwipeGestureRecognizer];
    [self.view addGestureRecognizer:self.rightSwipeGestureRecognizer];
    self.loginDetailsView.delegate = self;
    self.loginDetailsView.gotoHomeDelegate = self;;
    self.registerView.gotoHomeDelegate = self;
    
    //默认加载登录页面
    [self.view addSubview: self.loginDetailsView.view];
}

- (IBAction)btnLoginClick:(id)sender {
    [self.registerView removeFromParentViewController];
    [self.view addSubview:self.loginDetailsView.view];
    self.navigationItem.title = @"登录";
    self.labelBgRegister.backgroundColor = [UIColor clearColor];
    self.labelBgLogin.backgroundColor = [UIColor orangeColor];
    self.btnLogin.titleLabel.textColor = [UIColor orangeColor];
    self.btnRegister.titleLabel.textColor = [UIColor blackColor];
}

- (IBAction)btnRegisterClick:(id)sender {
    [self.loginDetailsView removeFromParentViewController];
    [self.view addSubview:self.registerView.view];
    self.navigationItem.title = @"注册";
    self.labelBgRegister.backgroundColor = [UIColor orangeColor];
    self.labelBgLogin.backgroundColor = [UIColor clearColor];
    self.btnLogin.titleLabel.textColor = [UIColor blackColor];
    self.btnRegister.titleLabel.textColor = [UIColor orangeColor];
}

- (void)handleSwipes:(UISwipeGestureRecognizer *)sender
{
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        [self.registerView removeFromParentViewController];
        [self.view addSubview:self.loginDetailsView.view];
        self.navigationItem.title = @"登录";
        self.labelBgRegister.backgroundColor = [UIColor clearColor];
        self.labelBgLogin.backgroundColor = [UIColor orangeColor];
        self.btnLogin.titleLabel.textColor = [UIColor orangeColor];
        self.btnRegister.titleLabel.textColor = [UIColor blackColor];
    }
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self.loginDetailsView removeFromParentViewController];
        [self.view addSubview:self.registerView.view];
        self.navigationItem.title = @"注册";
        self.labelBgRegister.backgroundColor = [UIColor orangeColor];
        self.labelBgLogin.backgroundColor = [UIColor clearColor];
        self.btnLogin.titleLabel.textColor = [UIColor blackColor];
        self.btnRegister.titleLabel.textColor = [UIColor orangeColor];
    }
}

//找回密码
- (void) pushParentsFromLoginDetails
{
    FindPsdStep1ViewController *findPsd1View =[self.storyboard instantiateViewControllerWithIdentifier: @"findPsd1View"];
    [self.navigationController pushViewController:findPsd1View animated:YES];
    findPsd1View.navigationItem.title = @"重置密码";
    self.navigationItem.title = @"";
}

- (void) gotoHome
{
    [self.navigationController popViewControllerAnimated:YES];
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
    //[_ni release];
    [_labelBgLogin release];
    [_labelBgRegister release];
    [_btnLogin release];
    [_btnRegister release];
    [super dealloc];
}
@end
