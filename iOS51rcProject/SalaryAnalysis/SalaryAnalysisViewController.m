#import "SalaryAnalysisViewController.h"
#import "CommonController.h"
#import "NetWebServiceRequest.h"
#import "SlideNavigationContorllerAnimator.h"
#import "DictionaryPickerView.h"
#import "Toast+UIView.h"
#import "LoadingAnimationView.h"
@interface SalaryAnalysisViewController () <DictionaryPickerDelegate,SlideNavigationControllerDelegate,UIGestureRecognizerDelegate, NetWebServiceRequestDelegate>
{
    LoadingAnimationView *loadView;
}
@property (strong, nonatomic) DictionaryPickerView *DictionaryPicker;
@property (retain, nonatomic) NSString *regionSelect;//工作地点
@property (retain, nonatomic) NSString *jobTypeSelect;//职位类别
@property (retain, nonatomic) IBOutlet UIView *viewAvg;//平均
@property (retain, nonatomic) IBOutlet UIView *viewDistribution;//分布
@property (retain, nonatomic) IBOutlet UIView *viewRank;//排行
@property (retain, nonatomic) NetWebServiceRequest *runningRequest;

-(void)cancelDicPicker;
@end

@implementation SalaryAnalysisViewController

-(void)cancelDicPicker
{
    [self.DictionaryPicker cancelPicker];
    self.DictionaryPicker.delegate = nil;
    self.DictionaryPicker = nil;
}

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

    self.automaticallyAdjustsScrollViewInsets = NO;
    self.lbQueryResult.layer.backgroundColor = [[UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1] CGColor];
    self.viewSearchSelect.layer.cornerRadius = 5;
    self.viewSearchSelect.layer.borderWidth = 1;
    self.viewSearchSelect.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    self.btnSearch.layer.cornerRadius = 5;
    
    [self.btnSearch addTarget:self action:@selector(onSearch) forControlEvents:UIControlEventTouchUpInside];
    [self.btnRegionSelect addTarget:self action:@selector(showRegionSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnJobTypeSelect addTarget:self action:@selector(showJobTypeSelect:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.lbRegionSelect setText:@"山东省"];
    self.regionSelect = @"32";
    self.jobTypeSelect = @"0";
    [self onSearch];
}


- (void)onSearch
{
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.regionSelect forKey:@"regionID"];
    [dicParam setObject:self.jobTypeSelect forKey:@"jobTypeID"];
   
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetSalaryAnalysis" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 1;
    self.runningRequest = request;
    [dicParam release];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSMutableArray *)requestData
{
    if (request.tag == 1) {
    [self GenerateViewAvg: requestData];
    }
    else if(request.tag == 2){
        NSMutableArray *arrCv = [[NSMutableArray alloc] init];
        NSDictionary *defalult = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                   @"0",@"id",
                                   @"相关简历",@"value"
                                   ,nil] autorelease];
        [arrCv addObject:defalult];
        for (int i = 0; i < requestData.count; i++) {
            NSDictionary *dicCv = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                    requestData[i][@"ID"],@"id",
                                    requestData[i][@"Name"],@"value"
                                    ,nil] autorelease];
            [arrCv addObject:dicCv];
        }
    }
    
    //结束等待动画
    [loadView stopAnimating];
}

//平均工资的View
-(void) GenerateViewAvg:(NSMutableArray *) resultData{
    NSDictionary *tmpData = resultData[0];
    self.viewAvg.layer.borderWidth = 0.5;
    self.viewAvg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)] autorelease];
    title.layer.backgroundColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    title.text = [NSString stringWithFormat:@"%@职工平均工资为：%@元",self.lbRegionSelect.text, tmpData[@"AvgSalary"] ];
    title.font = [UIFont systemFontOfSize:12];
    [self.viewAvg addSubview:title];
    //3行还是两行（如果选择省以下的的是三条数据）
    int viewHeight = 120;
    int selfSalary =  [tmpData[@"AvgSalary"] integerValue];
    int p1Salary = [tmpData[@"Parent1"] integerValue];//上一级
    self.viewAvg.frame = CGRectMake(10, self.lbQueryResult.frame.origin.y + self.lbQueryResult.frame.size.height + 45, 300, viewHeight);
    int p2Salary = 0;//全国级
    if (tmpData[@"Parent2"] != nil) {
        viewHeight = 170;
        p2Salary = [tmpData[@"Parent2"] integerValue];
        self.viewAvg.frame = CGRectMake(10, self.lbQueryResult.frame.origin.y + self.lbQueryResult.frame.size.height + 45, 300, viewHeight);
    }
    
    //一条横线，x轴
    UILabel *lbX = [[[UILabel alloc] initWithFrame:CGRectMake(0, self.viewAvg.frame.size.height - 20, 300, 0.5)] autorelease];
    lbX.layer.borderColor = [UIColor lightGrayColor].CGColor;
    lbX.layer.borderWidth = 0.5;
    [self.viewAvg addSubview:lbX];
    //6个纵线
    int height = self.viewAvg.frame.size.height - title.frame.size.height - 30;//view的高度-标题的高度-下方余出的高度
    for (int i=0; i<6; i++) {
        //纵线
        UILabel *lbTmp = [[[UILabel alloc] initWithFrame:CGRectMake(25+i*50, lbX.frame.origin.y-height, 0.5, height)] autorelease];
        lbTmp.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
        [self.viewAvg addSubview:lbTmp];
        
        //单位
        UILabel *lbRange = [[[UILabel alloc] initWithFrame:CGRectMake(i*50, lbX.frame.origin.y + 1, 50, 10)] autorelease];
        if (i==0) {
            lbRange.text = @"(单位：元/月)";
        }else{
            int money = i*2000;
            lbRange.text = [NSString stringWithFormat:@"%d", money];
        }
        lbRange.textAlignment = NSTextAlignmentCenter;
        lbRange.font = [UIFont systemFontOfSize:8];
        lbRange.textColor = [UIColor grayColor];
        [self.viewAvg addSubview:lbRange];
    }
    
    //横柱子--avgView是从小10开始，左右两个空隙是25
    //自己的平均工资
    UIView *view1 = [[[UIView alloc] initWithFrame:CGRectMake(25, 40, selfSalary/10000.0*250, 40 )] autorelease];
    UILabel *lb1 = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 10)] autorelease];
    lb1.text = [NSString stringWithFormat:@"%@职工平均月薪", self.lbRegionSelect.text];
    lb1.font = [UIFont systemFontOfSize:10];
    lb1.textColor = [UIColor grayColor];
    UILabel *lb1Color = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, selfSalary/10000.0*250, 10)];
    lb1Color.layer.backgroundColor = [UIColor colorWithRed:28/255.f green:196/255.f blue:160/255.f alpha:1].CGColor;
    UILabel *lbMoney = [[UILabel alloc] initWithFrame:CGRectMake(lb1Color.frame.size.width, 10, 40, 10)];
    lbMoney.text = [NSString stringWithFormat:@"￥%d", selfSalary];
    lbMoney.font = [UIFont systemFontOfSize:10];
    [view1 addSubview:lb1];
    [view1 addSubview:lb1Color];
    [view1 addSubview:lbMoney];
    [self.viewAvg addSubview:view1];
    
    //第一层上级的平均工资
    UIView *view2 = [[[UIView alloc] initWithFrame:CGRectMake(25, 70, p1Salary/10000.0*250, 40 )] autorelease];
    UILabel *lb2 = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 10)] autorelease];
    lb2.text = [NSString stringWithFormat:@"%@职工平均月薪", self.lbRegionSelect.text];
    lb2.font = [UIFont systemFontOfSize:10];
    lb2.textColor = [UIColor grayColor];
    UILabel *lb2Color = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, p1Salary/10000.0*250, 10)];
    lb2Color.layer.backgroundColor =  [UIColor colorWithRed:254/255.f green:202/255.f blue:67/255.f alpha:1].CGColor;
    UILabel *lb2Money = [[UILabel alloc] initWithFrame:CGRectMake(lb2Color.frame.size.width, 10, 40, 10)];
    lb2Money.text = [NSString stringWithFormat:@"￥%d", p1Salary];
    lb2Money.font = [UIFont systemFontOfSize:10];
    [view2 addSubview:lb2];
    [view2 addSubview:lb2Color];
    [view2 addSubview:lb2Money];
    [self.viewAvg addSubview:view2];
    
    //全国平均
    if (p2Salary != 0) {
        UIView *view3 = [[[UIView alloc] initWithFrame:CGRectMake(25, 100, p2Salary/10000.0*250, 40 )] autorelease];
        UILabel *lb3 = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 10)] autorelease];
        lb3.text = @"全国职工平均月薪";
        lb3.font = [UIFont systemFontOfSize:10];
        lb3.textColor = [UIColor grayColor];
        UILabel *lb3Color = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, p2Salary/10000.0*250, 10)];
        lb3Color.layer.backgroundColor =  [UIColor colorWithRed:254/255.f green:202/255.f blue:67/255.f alpha:1].CGColor;
        UILabel *lb3Money = [[UILabel alloc] initWithFrame:CGRectMake(lb3Color.frame.size.width, 10, 40, 10)];
        lb3Money.text = [NSString stringWithFormat:@"￥%d", p2Salary];
        lb3Money.font = [UIFont systemFontOfSize:10];
        [view3 addSubview:lb3];
        [view3 addSubview:lb3Color];
        [view3 addSubview:lb3Money];
        [self.viewAvg addSubview:view3];
    }

}

-(void)showRegionSelect:(UIButton *)sender {
    [self cancelDicPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCustom:DictionaryPickerWithRegionL3 pickerMode:DictionaryPickerModeMulti pickerInclude:DictionaryPickerIncludeParent delegate:self defaultValue:self.regionSelect defaultName:self.lbRegionSelect.text] autorelease];
    [self.DictionaryPicker setTag:1];
    [self.DictionaryPicker showInView:self.view];
}

-(void)showJobTypeSelect:(UIButton *)sender {
    [self cancelDicPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCustom:DictionaryPickerWithJobType pickerMode:DictionaryPickerModeMulti pickerInclude:DictionaryPickerIncludeParent delegate:self defaultValue:self.jobTypeSelect defaultName:self.lbJobTypeSelect.text] autorelease];
    [self.DictionaryPicker setTag:2];
    [self.DictionaryPicker showInView:self.view];
}

- (void)pickerDidChangeStatus:(DictionaryPickerView *)picker
                selectedValue:(NSString *)selectedValue
                 selectedName:(NSString *)selectedName
{
    switch (picker.tag) {
        case 1:
            if (selectedValue.length == 0) {
                [self.view makeToast:@"工作地点不能为空"];
                return;
            }
            self.regionSelect = selectedValue;
            self.lbRegionSelect.text = selectedName;
            break;
        case 2:
            self.jobTypeSelect = selectedValue;
            if (selectedValue.length == 0) {
                self.lbJobTypeSelect.text = @"所有职位";
            }
            else {
                self.lbJobTypeSelect.text = selectedName;
            }
            break;
        default:
            break;
    }
    [self cancelDicPicker];
}


- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (int)slideMenuItem
{
    return 4;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_runningRequest release];
    [_viewSearchSelect release];
    [_btnSearch release];
    [_btnRegionSelect release];
    [_btnJobTypeSelect release];
    [_lbRegionSelect release];
    [_lbJobTypeSelect release];
    [_regionSelect release];
    [_jobTypeSelect release];
    [_DictionaryPicker release];
    [_scrollSearch release];    
    [_imgSearch release];
    [_lbSearch release];
    [_lbQueryResult release];
    [_viewAvg release];
    [_viewDistribution release];
    [_viewRank release];
    [super dealloc];
}
@end
