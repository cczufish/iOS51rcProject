#import "SalaryAnalysisViewController.h"
#import "CommonController.h"
#import "NetWebServiceRequest.h"
#import "SlideNavigationContorllerAnimator.h"
#import "DictionaryPickerView.h"
#import "Toast+UIView.h"
#import "EColumnDataModel.h"
#import "EColumnChartLabel.h"
#import "EFloatBox.h"
#import "EColor.h"
#import "LoadingAnimationView.h"

@interface SalaryAnalysisViewController () <DictionaryPickerDelegate,SlideNavigationControllerDelegate,UIGestureRecognizerDelegate, NetWebServiceRequestDelegate, UIScrollViewDelegate>
{
    LoadingAnimationView *loadView;
    BOOL loadingColumnExp;//正在加载经验柱状图
    BOOL loadingColumnEdu;//正在加载学历柱状图
    NSString *jobTypeName;//职位类别名称
}
@property (strong, nonatomic) DictionaryPickerView *DictionaryPicker;
@property (retain, nonatomic) NSString *regionSelect;//工作地点
@property (retain, nonatomic) NSString *jobTypeSelect;//职位类别
@property (retain, nonatomic) IBOutlet UIView *viewAvg;//平均
@property (retain, nonatomic) IBOutlet UIView *viewDistribution;//分布
@property (retain, nonatomic) IBOutlet UIView *viewRank;//排行
@property (retain, nonatomic) NetWebServiceRequest *runningRequest;
@property (retain, nonatomic) NetWebServiceRequest *runningReqestForGetRank;//工资排名所用
@property (retain, nonatomic) EColumnChart *colExperience;
@property (retain, nonatomic) EColumnChart *colEducation;

@property (nonatomic, strong) NSArray *dataExperience;
@property (nonatomic, strong) NSArray *dataEducation;
@property (nonatomic, strong) EFloatBox *eFloatBox;
@property (nonatomic, strong) EColumn *eColumnSelected;
@property (nonatomic, strong) UIColor *tempColor;

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
    
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    
    [self.lbRegionSelect setText:@"山东省"];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    self.regionSelect = [userDefault objectForKey:@"subSiteId"];
    self.jobTypeSelect = @"0";
    jobTypeName = @"职工";
    [self onSearch];
}


- (void)onSearch
{
    //jobTypeName = [CommonController getDictionaryDesc:self.jobTypeSelect tableName:@"dcJobType"];
    //开始等待动画
    [loadView startAnimating];
    
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
        NSDictionary *tmpData = requestData[0];
        //获取工资排名的数据
        NSMutableDictionary *dicParam2 = [[NSMutableDictionary alloc] init];
        //如果自己有Parement2，说明自己是地级市，查工资排名的regionid要用parement1的id
        if (tmpData[@"Parent2"] != nil) {
            NSString *pID = [tmpData[@"dcRegionID"] substringToIndex:2];
            [dicParam2 setObject:pID forKey:@"regionID"];
        }else{
            [dicParam2 setObject:self.regionSelect forKey:@"regionID"];
        }
        
        NetWebServiceRequest *request2 = [NetWebServiceRequest serviceRequestUrl:@"GetCitySalaryRankByReginID" Params:dicParam2];
        [request2 setDelegate:self];
        [request2 startAsynchronous];
        request2.tag = 2;
        self.runningReqestForGetRank = request2;
        [dicParam2 release];

        //绑定第一批数据
        [self GenerateViewAvg: requestData];
        [self GenerateExperienceAndEducationAnalysis:requestData];
    }
    else if(request.tag == 2){
        [self GenerageSalaryRankForRegion:requestData];
        [loadView stopAnimating];
    }
    
    //结束等待动画
    //[loadView stopAnimating];
}

//平均工资的View
-(void) GenerateViewAvg:(NSMutableArray *) resultData{
    for (UIView * subview in [self.viewAvg subviews]) {
        [subview removeFromSuperview];
    }
    NSDictionary *tmpData = resultData[0];
    self.viewAvg.layer.borderWidth = 0.5;
    self.viewAvg.layer.borderColor = [UIColor lightGrayColor].CGColor;
    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)] autorelease];
    title.layer.backgroundColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    title.text = [NSString stringWithFormat:@"%@%@平均工资为：%@元",self.lbRegionSelect.text, jobTypeName, tmpData[@"AvgSalary"] ];
    title.font = [UIFont systemFontOfSize:12];
    [self.viewAvg addSubview:title];
    //3行还是两行（如果选择省以下的的是三条数据）
    int viewHeight = 160;
    int selfSalary =  [tmpData[@"AvgSalary"] integerValue];
    int p1Salary = [tmpData[@"Parent1"] integerValue];//上一级
    self.viewAvg.frame = CGRectMake(10, self.viewTop.frame.origin.y + self.viewTop.frame.size.height, 300, viewHeight);
    int p2Salary = 0;//全国级
    if (tmpData[@"Parent2"] != nil) {
        viewHeight = 200;
        p2Salary = [tmpData[@"Parent2"] integerValue];
        self.viewAvg.frame = CGRectMake(10, self.viewTop.frame.origin.y + self.viewTop.frame.size.height, 300, viewHeight);
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
    UIView *view1 = [[[UIView alloc] initWithFrame:CGRectMake(25, 50, selfSalary/10000.0*250, 40 )] autorelease];
    UILabel *lb1 = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 10)] autorelease];
    lb1.text = [NSString stringWithFormat:@"%@%@平均月薪", self.lbRegionSelect.text, jobTypeName];
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
    UIView *view2 = [[[UIView alloc] initWithFrame:CGRectMake(25, 90, p1Salary/10000.0*250, 40 )] autorelease];
    UILabel *lb2 = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 10)] autorelease];
    if (p2Salary == 0) {
        if ([jobTypeName isEqualToString:@"所有职位"]) {
            lb2.text = @"全国职工平均月薪";
        }else{
            lb2.text = [NSString stringWithFormat:@"全国%@平均月薪", jobTypeName];
        }
        
    }else{
        NSString *parementRegion = [CommonController getDictionaryDesc:tmpData[@"Parent1"] tableName: @"dcRegion"];
        lb2.text = [NSString stringWithFormat:@"%@%@平均月薪", parementRegion, jobTypeName];
    }
    
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
        UIView *view3 = [[[UIView alloc] initWithFrame:CGRectMake(25, 130, p2Salary/10000.0*250, 40 )] autorelease];
        UILabel *lb3 = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 10)] autorelease];
        lb3.text = [NSString stringWithFormat: @"全国%@平均月薪", jobTypeName];
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

//生成工作经验和学历的柱状图
-(void) GenerateExperienceAndEducationAnalysis:(NSMutableArray *) resultData{
    for (UIView * subview in [self.viewDistribution subviews]) {
        [subview removeFromSuperview];
    }
    loadingColumnExp = false;
    loadingColumnEdu = false;
    NSDictionary *tmpData = resultData[0];
    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)] autorelease];
    title.layer.backgroundColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    title.text = [NSString stringWithFormat:@"  %@%@招聘待遇分布",self.lbRegionSelect.text, jobTypeName];
    title.font = [UIFont systemFontOfSize:12];
    [self.viewDistribution addSubview:title];

    //======================工作经验的柱状图======================
    loadingColumnExp = true;
    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 4; i >= 0; i--)
    {
        int value = [tmpData[[NSString stringWithFormat:@"ExperienceSalary%d", i]] intValue];
        NSString *strExpName = @" ";
        switch (i) {
            case 0:
                strExpName = @"应届毕业生";
                break;
            case 1:
                strExpName = @"1-2年";
                break;
            case 2:
                strExpName = @"3-5年";
                break;
            case 3:
                strExpName = @"6-10年";
                break;
            case 4:
                strExpName = @"10年以上";
                break;
            default:
                break;
        }
        EColumnDataModel *eColumnDataModel = [[EColumnDataModel alloc] initWithLabel:strExpName value:value index:i unit:@""];
        [temp addObject:eColumnDataModel];
    }
    _dataExperience = [NSArray arrayWithArray:temp];
    self.colExperience = [[EColumnChart alloc] initWithFrame:CGRectMake(40, 40, 240, 160)];
    //设置颜色
    self.colExperience.maxColumnColor =  [UIColor colorWithRed:0/255.f green:109/255.f blue:191/255.f alpha:1];
    self.colExperience.minColumnColor =[UIColor colorWithRed:0/255.f green:109/255.f blue:191/255.f alpha:1];
    self.colExperience.normalColumnColor = [UIColor colorWithRed:0/255.f green:109/255.f blue:191/255.f alpha:1];
    [self.colExperience setColumnsIndexStartFromLeft:YES];
	[self.colExperience setDelegate:self];
    [self.colExperience setDataSource:self];
    
    [self.viewDistribution addSubview:self.colExperience];
    //======================学历柱状图======================
    loadingColumnExp = false;
    loadingColumnEdu = true;
    NSMutableArray *tmpArrayForEducation = [NSMutableArray array];
    for (int i = 8; i >= 4; i--)
    {
        int value = [tmpData[[NSString stringWithFormat:@"EducationSalary%d", i]] intValue];
        NSString *strEduName = @" ";
        switch (i) {
            case 4:
                strEduName = @"大专以下";
                break;
            case 5:
                strEduName = @"大专";
                break;
            case 6:
                strEduName = @"本科";
                break;
            case 7:
                strEduName = @"硕士";
                break;
            case 8:
                strEduName = @"硕士以上";
                break;
            default:
                break;
        }
        EColumnDataModel *eColumnDataModel = [[EColumnDataModel alloc] initWithLabel:strEduName value:value index:i unit:@""];
        [tmpArrayForEducation addObject:eColumnDataModel];
    }
    _dataEducation = [NSArray arrayWithArray:tmpArrayForEducation];
    self.colEducation = [[EColumnChart alloc] initWithFrame:CGRectMake(40, self.colExperience.frame.origin.y+self.colExperience.frame.size.height + 40, 240, 160)];
    [self.colEducation setColumnsIndexStartFromLeft:YES];
    //设置颜色
    self.colEducation.maxColumnColor =  [UIColor colorWithRed:211/255.f green:0/255.f blue:32/255.f alpha:1];
    self.colEducation.minColumnColor =[UIColor colorWithRed:211/255.f green:0/255.f blue:32/255.f alpha:1];
    self.colEducation.normalColumnColor = [UIColor colorWithRed:211/255.f green:0/255.f blue:32/255.f alpha:1];
	[self.colEducation setDelegate:self];
    [self.colEducation setDataSource:self];
    //loadingColumnEdu = false;
    [self.viewDistribution addSubview:self.colEducation];
    
    //日期
    UILabel *lbTime = [[[UILabel alloc] initWithFrame:CGRectMake(40, self.colEducation.frame.origin.y + self.colEducation.frame.size.height + 15, 280, 30)] autorelease];
    NSDate *  dtNow=[NSDate date];
    NSTimeInterval interval = 60 * 60 * 24;
    dtNow = [dtNow initWithTimeIntervalSinceNow:-interval];//减去一天
    NSDateFormatter  *dateformatter=[[[NSDateFormatter alloc] init] autorelease];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString * strNowDate=[dateformatter stringFromDate:dtNow];
    lbTime.text = [NSString stringWithFormat:@"统计截止到%@，该数据仅供参考",strNowDate];
    lbTime.textColor = [UIColor blackColor];
    lbTime.font = [UIFont systemFontOfSize:13];
    [self.viewDistribution addSubview:lbTime];
    
    //重新计算View大小
    self.viewDistribution.frame = CGRectMake(10, self.viewAvg.frame.origin.y+self.viewAvg.frame.size.height + 15, 300, lbTime.frame.size.height + lbTime.frame.origin.y + 10);
    self.viewDistribution.layer.borderWidth = 0.5;
    self.viewDistribution.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

//生成工资排行的列表
-(void) GenerageSalaryRankForRegion:(NSMutableArray *) requestData{
    for (UIView * subview in [self.viewRank subviews]) {
        [subview removeFromSuperview];
    }
    UILabel *title = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 20)] autorelease];
    title.layer.backgroundColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    NSString *regionName = [CommonController getDictionaryDesc:[self.regionSelect substringToIndex:2] tableName:@"dcRegion"];
    title.text = [NSString stringWithFormat:@"  %@地区薪酬排行",regionName];
    title.font = [UIFont systemFontOfSize:12];
    [self.viewRank addSubview:title];
    for (int i=0; i<requestData.count; i++) {
        NSDictionary *tmpData = requestData[i];
        UIView *tmpView = [[[UIView alloc] initWithFrame:CGRectMake(0, 20 + i*20, 280, 20)] autorelease];
        //左侧圆圈
        UIImageView *imgRank = [[[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 17, 17)] autorelease];
        imgRank.image = [UIImage imageNamed:[NSString stringWithFormat:@"ico_salary_rank%d", i+1]];
        [tmpView addSubview:imgRank];
        //地区名称
        UILabel *lbRegionName = [[[UILabel alloc] initWithFrame:CGRectMake(40, 5, 200, 15)]autorelease];
        NSString *strRegion =  tmpData[@"dcRegionID"];
        NSString *strRegionName = [CommonController getDictionaryDesc:strRegion tableName:@"dcRegion"];
        lbRegionName.text = strRegionName;
        lbRegionName.font = [UIFont systemFontOfSize:13];
        [tmpView addSubview:lbRegionName];
        //薪酬
        UILabel *lbMoney = [[[UILabel alloc] initWithFrame:CGRectMake(220, 5, 80, 15)] autorelease];
        lbMoney.text = [NSString stringWithFormat:@"￥%@", tmpData[@"AvgSalary"]];
        lbMoney.font = [UIFont systemFontOfSize:13];
        [tmpView addSubview:lbMoney];
        //下划线
        UILabel *lbLine = [[[UILabel alloc] initWithFrame:CGRectMake(40, 20, 280, 5)] autorelease];
        lbLine.text = @"-------------------------------------------------------";
        lbLine.font = [UIFont systemFontOfSize:10];
        lbLine.textColor = [UIColor lightGrayColor];
        [tmpView addSubview:lbLine];
        
        [self.viewRank addSubview:tmpView];
    }
    
    self.viewRank.frame = CGRectMake(10, self.viewDistribution.frame.origin.y + self.viewDistribution.frame.size.height + 20, 300, 20+requestData.count * 20 + 20);
    self.viewRank.layer.borderWidth = 0.5;
    self.viewRank.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [self.svMain setContentSize:CGSizeMake(320, self.viewRank.frame.origin.y+self.viewRank.frame.size.height)];
}
#pragma -mark- EColumnChartDataSource

- (NSInteger)numberOfColumnsInEColumnChart:(EColumnChart *)eColumnChart
{
    //return [_dataExperience count];
    return 5;
}

- (NSInteger)numberOfColumnsPresentedEveryTime:(EColumnChart *)eColumnChart
{
    return 5;
}

//最大值
- (EColumnDataModel *)highestValueEColumnChart:(EColumnChart *)eColumnChart
{
    EColumnDataModel *maxDataModel = nil;
    float maxValue = -FLT_MIN;
    for (EColumnDataModel *dataModel in _dataExperience)
    {
        if (dataModel.value > maxValue)
        {
            maxValue = dataModel.value;
            maxDataModel = dataModel;
        }
    }
    return maxDataModel;
}

- (EColumnDataModel *)eColumnChart:(EColumnChart *)eColumnChart valueForIndex:(NSInteger)index
{    
    if (loadingColumnEdu) {
        if (index >= [_dataEducation count] || index < 0) return nil;
        return [_dataEducation objectAtIndex:index];
    }else
    {
        if (index >= [_dataExperience count] || index < 0) return nil;
        return [_dataExperience objectAtIndex:index];
    }    
}

#pragma -mark- EColumnChartDelegate
//touchMove
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    //不做任何事情
}
- (void)eColumnChart:(EColumnChart *)eColumnChart didSelectColumn:(EColumn *)eColumn
{

}

- (void)eColumnChart:(EColumnChart *)eColumnChart fingerDidEnterColumn:(EColumn *)eColumn
{

}

- (void)eColumnChart:(EColumnChart *)eColumnChart fingerDidLeaveColumn:(EColumn *)eColumn
{
    
}

- (void)fingerDidLeaveEColumnChart:(EColumnChart *)eColumnChart
{

}

//地区选择
-(void)showRegionSelect:(UIButton *)sender {
    [self cancelDicPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCustom:DictionaryPickerWithRegionL2 pickerMode:DictionaryPickerModeOne pickerInclude:DictionaryPickerIncludeParent delegate:self defaultValue:self.self.regionSelect defaultName:@"山东省"] autorelease];
    [self.DictionaryPicker setTag:1];
    [self.DictionaryPicker showInView:self.view];
}

//职位类别选择
-(void)showJobTypeSelect:(UIButton *)sender {
    [self cancelDicPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCustom:DictionaryPickerWithJobType pickerMode:DictionaryPickerModeOne pickerInclude:DictionaryPickerIncludeParent delegate:self defaultValue:self.jobTypeSelect defaultName:self.lbJobTypeSelect.text] autorelease];
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
            jobTypeName = self.lbJobTypeSelect.text;
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
    [_lbQueryResult release];
    [_viewAvg release];
    [_viewDistribution release];
    [_viewRank release];
    [_svMain release];
    [_viewTop release];
    [super dealloc];
}
@end
