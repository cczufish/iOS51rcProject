#import "EiSearchViewController.h"
#import "EIListViewController.h"

@interface EiSearchViewController ()
@property (retain, nonatomic) IBOutlet UITextField *txtKeyWord;
@property (retain, nonatomic) IBOutlet UIButton *btnSearch;
@property (retain, nonatomic) IBOutlet UIButton *btn1;
@property (retain, nonatomic) IBOutlet UIButton *btn2;
@property (retain, nonatomic) IBOutlet UIButton *btn3;
@property (retain, nonatomic) IBOutlet UIButton *btn4;
@property (retain, nonatomic) IBOutlet UIButton *btn5;
@property (retain, nonatomic) IBOutlet UIButton *btn6;
@property (retain, nonatomic) IBOutlet UIButton *btn7;
@end

@implementation EiSearchViewController

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
    // Do any additional setup after loading the view.
    UIButton *button = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [button setTitle: @"就业资讯" forState: UIControlStateNormal];
    [button sizeToFit];
    self.navigationItem.titleView = button;
    //返回按钮
    UIButton *leftBtn = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 40)] autorelease];
    [leftBtn addTarget:self action:@selector(btnBackClick:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *lbLeft = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 40)] autorelease];
    lbLeft.text = @"返回";
    lbLeft.font = [UIFont systemFontOfSize:13];
    //lbLeft.textColor = [UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1];
    lbLeft.textColor = [UIColor whiteColor];
    [leftBtn addSubview:lbLeft];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem=backButton;
    
    //搜索按钮样式
    self.btnSearch.layer.cornerRadius = 0;
    self.btnSearch.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.btnSearch.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
    //文本框样式
    self.txtKeyWord.layer.cornerRadius = 1;
    self.txtKeyWord.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void) btnBackClick:(UIButton*) sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)btn1Click:(id)sender {
    [self searchKeyWord:@"大学生"];
}
- (IBAction)btn2Click:(id)sender {
     [self searchKeyWord:@"简历"];
}
- (IBAction)btn3Click:(id)sender {
     [self searchKeyWord:@"面试"];
}
- (IBAction)btn4Click:(id)sender {
     [self searchKeyWord:@"公务员"];
}
- (IBAction)btn5Click:(id)sender {
     [self searchKeyWord:@"事业单位"];
}
- (IBAction)btn6Click:(id)sender {
     [self searchKeyWord:@"求职"];
}
- (IBAction)btn7Click:(id)sender {
     [self searchKeyWord:@"工资"];
}

//点击搜索按钮
- (IBAction)btnSearchClick:(id)sender {
    NSString *strKeyWord = self.txtKeyWord.text;
    if (![strKeyWord isEqualToString:@""]) {
        [self searchKeyWord:strKeyWord];
    }
}

//通用搜索
-(void) searchKeyWord:(NSString *) strKeyWord{
    EIListViewController *listCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"EIListView"];
    listCtrl.strKeyWord = strKeyWord;
    [self.navigationController pushViewController:listCtrl animated:YES];
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
    [_txtKeyWord release];
    [_btnSearch release];
    [_btn1 release];
    [_btn2 release];
    [_btn3 release];
    [_btn4 release];
    [_btn5 release];
    [_btn6 release];
    [_btn7 release];
    [super dealloc];
}
@end
