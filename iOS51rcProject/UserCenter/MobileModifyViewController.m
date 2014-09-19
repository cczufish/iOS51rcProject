//
//  MobileModifyViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-12.
//

#import "MobileModifyViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "IndexViewController.h"
#import "Toast+UIView.h"
#import "CommonController.h"

@interface MobileModifyViewController ()<NetWebServiceRequestDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;

@end

@implementation MobileModifyViewController

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
    [self.navigationItem setTitle:@"修改手机号"];
    //添加边框
    self.viewMobile.layer.cornerRadius = 5;
    self.viewMobile.layer.borderWidth = 1;
    self.viewMobile.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.btnModify.layer.cornerRadius = 5;
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //设置为数字键盘
    [self.txtMobile setKeyboardType:UIKeyboardTypeNumberPad];
}

- (IBAction)modifyMobile:(id)sender {
    [self.txtMobile resignFirstResponder];
    NSString *mobile = self.txtMobile.text;
    if (mobile.length == 0) {
        [self.view makeToast:@"请输入手机号"];
        return;
    }
    if (![CommonController isValidateMobile:mobile]) {
        [self.view makeToast:@"请输入有效的手机号"];
        return;
    }
    [loadView startAnimating];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:mobile forKey:@"mobile"];
    [dicParam setObject:[userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UpdatePamainByMobile" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
    [dicParam release];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    [loadView stopAnimating];
    IndexViewController *indexC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    indexC.toastType = 1;
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)backgroundTap:(id)sender
{
    [self.txtMobile resignFirstResponder];
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
    [_viewMobile release];
    [_txtMobile release];
    [_btnModify release];
    [_runningRequest release];
    [loadView release];
    [super dealloc];
}
@end
