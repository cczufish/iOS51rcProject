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
    self.navigationItem.title = @"就业资讯";
    //搜索按钮样式
    self.btnSearch.layer.cornerRadius = 0;
    self.btnSearch.layer.borderColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
    self.btnSearch.layer.backgroundColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
    //文本框样式
    self.txtKeyWord.layer.cornerRadius = 1;
    self.txtKeyWord.layer.borderColor = [UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1].CGColor;
}

- (void) btnShareClick:(UIButton*) sender{
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
