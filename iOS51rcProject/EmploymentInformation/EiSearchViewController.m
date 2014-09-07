#import "EiSearchViewController.h"
#import "EIListViewController.h"

@interface EiSearchViewController ()

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
    
    [self initCommon];
}

- (void) btnBackClick:(UIButton*) sender{
    [self.navigationController popViewControllerAnimated:YES];
}

//初始化控件
-(void) initCommon{
    //添加7个button
    UIButton *btn1l = [[[UIButton alloc] initWithFrame:CGRectMake(20, 60, 140, 60)] autorelease];
    [btn1l addTarget:self action:@selector(clickKeyWord:) forControlEvents:UIControlEventTouchUpInside];
    btn1l.tag = 1;
    UILabel *lb1l = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 60)] autorelease];
    lb1l.text = @"大学生";
    lb1l.font = [UIFont systemFontOfSize:12];
    lb1l.layer.backgroundColor = [UIColor greenColor].CGColor;
    [btn1l addSubview:lb1l];
    [self.view addSubview:btn1l];
    
    
    UIButton *btn1r = [[[UIButton alloc] initWithFrame:CGRectMake(200, 60, 140, 60)] autorelease];
    [btn1r addTarget:self action:@selector(clickKeyWord:) forControlEvents:UIControlEventTouchUpInside];
    btn1r.tag = 2;
    UILabel *lb12 = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 60)] autorelease];
    lb1l.text = @"简历";
    lb1l.font = [UIFont systemFontOfSize:12];
    lb1l.layer.backgroundColor = [UIColor purpleColor].CGColor;
    [btn1r addSubview:lb12];
    [self.view addSubview:btn1r];
    
    UIButton *btn2l = [[[UIButton alloc] initWithFrame:CGRectMake(20, 120, 140, 60)] autorelease];
    [btn1l addTarget:self action:@selector(clickKeyWord:) forControlEvents:UIControlEventTouchUpInside];
    btn1l.tag = 3;
    UILabel *lb2l = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 60)] autorelease];
    lb2l.text = @"面试";
    lb2l.font = [UIFont systemFontOfSize:12];
    lb2l.layer.backgroundColor = [UIColor greenColor].CGColor;
    [btn2l addSubview:lb2l];
    [self.view addSubview:btn2l];
    
    UIButton *btn2r = [[[UIButton alloc] initWithFrame:CGRectMake(200, 120, 140, 60)] autorelease];
    [btn2r addTarget:self action:@selector(clickKeyWord:) forControlEvents:UIControlEventTouchUpInside];
    btn2r.tag = 4;
    UILabel *lb2r = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 60)] autorelease];
    lb2r.text = @"公务员";
    lb2r.font = [UIFont systemFontOfSize:12];
    lb2r.layer.backgroundColor = [UIColor greenColor].CGColor;
    [btn2r addSubview:lb2r];
    [self.view addSubview:btn2r];
    
    UIButton *btn3 = [[[UIButton alloc] initWithFrame:CGRectMake(20, 320, 300, 60)] autorelease];
    [btn3 addTarget:self action:@selector(clickKeyWord:) forControlEvents:UIControlEventTouchUpInside];
    btn3.tag = 5;
    UILabel *lb3 = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 60)] autorelease];
    lb3.text = @"事业单位";
    lb3.font = [UIFont systemFontOfSize:12];
    lb3.layer.backgroundColor = [UIColor greenColor].CGColor;
    [btn3 addSubview:lb3];
    
    UIButton *btn4l = [[[UIButton alloc] initWithFrame:CGRectMake(20, 400, 140, 60)] autorelease];
    [btn4l addTarget:self action:@selector(clickKeyWord:) forControlEvents:UIControlEventTouchUpInside];
    btn4l.tag = 6;
    UILabel *lb4l = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 60)] autorelease];
    lb4l.text = @"求职";
    lb4l.font = [UIFont systemFontOfSize:12];
    lb4l.layer.backgroundColor = [UIColor greenColor].CGColor;
    [btn4l addSubview:lb4l];
    [self.view addSubview:btn4l];
    
    UIButton *btn4r = [[[UIButton alloc] initWithFrame:CGRectMake(200, 400, 140, 60)] autorelease];
    [btn4r addTarget:self action:@selector(clickKeyWord:) forControlEvents:UIControlEventTouchUpInside];
    btn4r.tag = 7;
    UILabel *lb4r = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 60)] autorelease];
    lb4r.text = @"工资";
    lb4r.font = [UIFont systemFontOfSize:12];
    lb4r.layer.backgroundColor = [UIColor greenColor].CGColor;
    [btn4r addSubview:lb4r];
    [self.view addSubview:btn4r];
}

//点击搜索按钮
-(void) clickKeyWord:(UIButton *) sender{
    NSString *strKeyWord = @"公务员";
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

@end
