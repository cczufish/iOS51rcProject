//
//  RefreshCvViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-26.
//

#import "RefreshCvViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "MyCvViewController.h"

@interface RefreshCvViewController () <UITextFieldDelegate,NetWebServiceRequestDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NSUserDefaults *userDefaults;

@end

@implementation RefreshCvViewController

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
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    self.txtMobile.text = self.mobile;
    self.viewMobile.layer.cornerRadius = 5;
    self.btnRefresh.layer.cornerRadius = 5;
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
}

- (IBAction)refreshCv:(id)sender {
    [loadView startAnimating];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.cvId forKey:@"ID"];
    [dicParam setObject:self.txtMobile.text forKey:@"mobile"];
    [dicParam setObject:[self.userDefaults objectForKey:@"UserID"] forKey:@"paMainID"];
    [dicParam setObject:[self.userDefaults objectForKey:@"code"] forKey:@"code"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UpdateCvRefreshDate" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 4;
    self.runningRequest = request;
    [dicParam release];
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:true];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:true];
    return YES;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{
    MyCvViewController *cvViewC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    cvViewC.toastType = 1;
    [self.navigationController popViewControllerAnimated:true];
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
    [_runningRequest release];
    [loadView release];
    [_userDefaults release];
    [_btnRefresh release];
    [_txtMobile release];
    [_viewMobile release];
    [_mobile release];
    [_cvId release];
    [super dealloc];
}
@end
