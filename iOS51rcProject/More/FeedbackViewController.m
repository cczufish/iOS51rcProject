#import "FeedbackViewController.h"

@interface FeedbackViewController ()<NetWebServiceRequestDelegate>{
    
}
@property (retain, nonatomic) IBOutlet UIScrollView *svContent;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) LoadingAnimationView *loading;
@property (retain, nonatomic) IBOutlet UITextView *txtInput;
@property (retain, nonatomic) IBOutlet UITextField *txtName;
@property (retain, nonatomic) IBOutlet UITextField *txtPhone;
@property (retain, nonatomic) IBOutlet UITextField *txtEmail;
@property (retain, nonatomic) IBOutlet UIButton *btnSend;
@property (retain, nonatomic) IBOutlet UIView *UserInfoView;
@property (retain, nonatomic) IBOutlet UILabel *lbInfo;
@end

@implementation FeedbackViewController

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
    //self.automaticallyAdjustsScrollViewInsets = NO;
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    //self.txtInput.delegate = self;
    self.txtName.delegate = self;
    self.txtPhone.delegate = self;
    self.txtEmail.delegate = self;
    
    [self initControl];
}

//初始化控件
-(void) initControl{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.txtEmail.text = [userDefaults objectForKey:@"UserID"];
    self.txtEmail.text = [userDefaults objectForKey:@"UserName"];
    

    self.UserInfoView.layer.cornerRadius = 5;
    self.UserInfoView.layer.borderWidth = 1;
    self.UserInfoView.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    self.btnSend.layer.cornerRadius = 5;
    
    self.txtName.layer.borderWidth = 1;
    self.txtName.layer.borderColor = [UIColor whiteColor].CGColor;
    self.txtEmail.layer.borderWidth = 1;
    self.txtEmail.layer.borderColor = [UIColor whiteColor].CGColor;
    self.txtPhone.layer.borderWidth = 1;
    self.txtPhone.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.txtInput.layer.borderWidth = 1;
    self.txtInput.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    
    //根据分辨率调整高度
    if ([[UIScreen mainScreen] bounds].size.height < 568) {//IPhone 5以下
        [self.svContent setContentSize:CGSizeMake(320, 590) ];
        self.svContent.frame = CGRectMake(0, 0, 320, 490);
        //self.txtInput.frame = CGRectMake(self.lbInfo.frame.origin.x, self.lbInfo.frame.origin.y + self.lbInfo.frame.size.height + 10, 320, self.txtInput.frame.size.height - 100);
    }
    
    //为TextView设置键盘隐藏
    UIToolbar * topView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [topView setBarStyle:UIBarStyleBlack];
    UIBarButtonItem * btnSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithTitle:@"输入完成" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:btnSpace,doneButton,nil];
    [doneButton release];
    [btnSpace release];
    
    [topView setItems:buttonsArray];
    [self.txtInput setInputAccessoryView:topView];
}

-(IBAction)dismissKeyBoard
{
    [self.txtInput resignFirstResponder];
}
//发送内容
- (IBAction)btnSendClick:(id)sender {
    //检查输入内容
    NSString *strUserName = self.txtName.text;
    NSString *strPhone = self.txtPhone.text;
    NSString *strEmail = self.txtEmail.text;
    NSString *strInput = self.txtInput.text;
    
    if ([CommonController isBlankString:strUserName]) {
        [self.view makeToast:@"姓名不能为空！"];
        return;
    }
    if ([CommonController isBlankString:strPhone]) {
        [self.view makeToast:@"手机号不能为空"];
        return;
    }
    if ([CommonController isBlankString:strEmail]) {
        [self.view makeToast:@"邮箱不能为空"];
        return;
    }
    if ([CommonController isBlankString:strInput]) {
       [self.view makeToast:@"意见不能为空！"];
        return;
    }
    if([strEmail length]>50){
        [self.view makeToast:@"邮箱长度不能超过50位"];
        return;
    }
    if (![[CommonController alloc] checkEmail:strEmail]) {
        [self.view makeToast:@"邮箱格式不正确"];
        return;
    }
    

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userID = [userDefaults objectForKey:@"UserID"];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:strInput forKey:@"Content"];
    [dicParam setObject:@"1.0" forKey:@"strVersion"];
    [dicParam setObject:userID forKey:@"paMainID"];
    [dicParam setObject:strUserName forKey:@"Name"];
    [dicParam setObject:strPhone forKey:@"strMobile"];
    [dicParam setObject:strEmail forKey:@"Email"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"FeedBackInsert" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
    self.loading = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    [self.loading startAnimating];

}

//返回结果
- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSArray *)requestData
{      
    //设置返回
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:@"FeedbackFinished"
                                                         forKey:@"operation"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"More"
     object:nil
     userInfo:dataDict];
    
    [self.navigationController popViewControllerAnimated:true];
}

//隐藏键盘
-(IBAction)textFiledReturnEditing:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)backgroundTap:(id)sender {
    [self.txtInput resignFirstResponder];
    [self.txtEmail resignFirstResponder];
    [self.txtName resignFirstResponder];
    [self.txtPhone resignFirstResponder];
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

//开始编辑输入框的时候，软键盘出现，执行此事件
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);//键盘高度216
    
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    //if(offset > 0)
        self.view.frame = CGRectMake(0.0f, offset, self.view.frame.size.width, self.view.frame.size.height);
    
    [UIView commitAnimations];
}

//当用户按下return键或者按回车键，keyboard消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//输入框编辑完成以后，将视图恢复到原始状态
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)dealloc {
    [_svContent release];
    [_txtInput release];
    [_txtName release];
    [_txtEmail release];
    [_btnSend release];
    [_UserInfoView release];
    [_txtPhone release];
    [_lbInfo release];
    [super dealloc];
}
@end
