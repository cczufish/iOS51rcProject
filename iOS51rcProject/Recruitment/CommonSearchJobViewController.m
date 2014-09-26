
#import "CommonSearchJobViewController.h"
#import "DictionaryPickerView.h"
#import "SlideNavigationController.h"
#import "Toast+UIView.h"
#import "SearchListViewController.h"
#import "FMDatabase.h"
#import "CommonController.h"

@interface CommonSearchJobViewController ()<DictionaryPickerDelegate>
@property (strong, nonatomic) DictionaryPickerView *DictionaryPicker;
@property (retain, nonatomic) NSString *regionSelect;
@property (retain, nonatomic) NSString *jobTypeSelect;
@property (retain, nonatomic) NSString *industrySelect;
@end

@implementation CommonSearchJobViewController
@synthesize searchDelegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)cancelDicPicker
{
    [self.DictionaryPicker cancelPicker];
    self.DictionaryPicker.delegate = nil;
    self.DictionaryPicker = nil;
}

//搜索代理
-(void) gotoJobSearchResultListView{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.viewSearchSelect.layer.cornerRadius = 5;
    self.viewSearchSelect.layer.borderWidth = 1;
    self.viewSearchSelect.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    self.btnSearch.layer.cornerRadius = 5;
   
    [self.btnRegionSelect addTarget:self action:@selector(showRegionSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnJobTypeSelect addTarget:self action:@selector(showJobTypeSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnIndustrySelect addTarget:self action:@selector(showIndustrySelect:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.lbRegionSelect setText:@"山东省"];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
     self.regionSelect = [userDefault objectForKey:@"subSiteId"];
    [self showSearchHistory];
}

//显示搜索历史记录
-(void)showSearchHistory
{
    FMResultSet *searchHistory = [CommonController querySql:@"SELECT * FROM paSearchHistory ORDER BY AddDate DESC"];
    if ([searchHistory next]) {
        searchHistory = [CommonController querySql:@"SELECT * FROM paSearchHistory ORDER BY AddDate DESC LIMIT 0,10"];
        //添加搜索记录
        self.viewHistory = [[UIView alloc] initWithFrame:CGRectMake(20, 280, 280, 1000)];
        [self.viewHistory setBackgroundColor:[UIColor colorWithRed:248.f/255.f green:248.f/255.f blue:248.f/255.f alpha:1]];
        //添加小图标
        UIImageView *imgHistory = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [imgHistory setImage:[UIImage imageNamed:@"ico_searchlog_log.png"]];
        [self.viewHistory addSubview:imgHistory];
        [imgHistory release];
        //添加最近搜索记录文字
        UILabel *lbHistoryTitle = [[UILabel alloc] initWithFrame:CGRectMake(21, 1, 120, 20)];
        [lbHistoryTitle setText:@"最近搜索记录"];
        [lbHistoryTitle setTextColor:[UIColor lightGrayColor]];
        [lbHistoryTitle setFont:[UIFont systemFontOfSize:16]];
        [self.viewHistory addSubview:lbHistoryTitle];
        [lbHistoryTitle release];
        //添加全部清空按钮
        UIButton *btnClearHistory = [[UIButton alloc] initWithFrame:CGRectMake(200, 0, 80, 20)];
        [btnClearHistory setTitle:@"[全部清空]" forState:UIControlStateNormal];
        [btnClearHistory.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [btnClearHistory setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [btnClearHistory addTarget:self action:@selector(clearAllHistory) forControlEvents:UIControlEventTouchUpInside];
        [self.viewHistory addSubview:btnClearHistory];
        [btnClearHistory release];
        float fltHistoryLogHeight = 0;
        //添加搜索记录显示view
        UIView *viewHistoryLog = [[UIView alloc] initWithFrame:CGRectMake(0,30,280,300)];
        [viewHistoryLog setBackgroundColor:[UIColor whiteColor]];
        while ([searchHistory next]) {
            CGSize lableSize = [CommonController CalculateFrame:[searchHistory stringForColumn:@"Name"] fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(180, 300)];
            UIButton *btnHistoryLog = [[UIButton alloc] initWithFrame:CGRectMake(0, fltHistoryLogHeight, 280, lableSize.height+30)];
            //添加搜索内容
            UILabel *lbHistoryTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 170, lableSize.height)];
            [lbHistoryTitle setText:[searchHistory stringForColumn:@"Name"]];
            [lbHistoryTitle setFont:[UIFont systemFontOfSize:14]];
            lbHistoryTitle.numberOfLines = 0;
            lbHistoryTitle.lineBreakMode = NSLineBreakByCharWrapping;
            [btnHistoryLog addSubview:lbHistoryTitle];
            [lbHistoryTitle release];
            //添加搜索结果
            UILabel *lbHistoryResult = [[UILabel alloc] initWithFrame:CGRectMake(180, 15, 95, lableSize.height)];
            [lbHistoryResult setText:[NSString stringWithFormat:@"%@个职位",[searchHistory stringForColumn:@"JobNum"]]];
            [lbHistoryResult setTextColor:[UIColor redColor]];
            [lbHistoryResult setFont:[UIFont systemFontOfSize:14]];
            [lbHistoryResult setTextAlignment:NSTextAlignmentRight];
            [btnHistoryLog addSubview:lbHistoryResult];
            [lbHistoryResult release];
            
            //添加分割线
            UILabel *lbSeperate = [[UILabel alloc] initWithFrame:CGRectMake(0, lableSize.height+29.5, 280, 0.5)];
            [lbSeperate setBackgroundColor:[UIColor lightGrayColor]];
            [btnHistoryLog addSubview:lbSeperate];
            [lbSeperate release];
            
            [btnHistoryLog setTag:[[searchHistory stringForColumn:@"_id"] intValue]];
            [btnHistoryLog addTarget:self action:@selector(searchFromHistory:) forControlEvents:UIControlEventTouchUpInside];
            [viewHistoryLog addSubview:btnHistoryLog];
            [btnHistoryLog release];
            
            fltHistoryLogHeight += lableSize.height+30;
        }
        viewHistoryLog.layer.cornerRadius = 5;
        viewHistoryLog.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        viewHistoryLog.layer.borderWidth = 0.5;
        //重新定高
        CGRect frameHistoryLog = viewHistoryLog.frame;
        frameHistoryLog.size.height = fltHistoryLogHeight;
        [viewHistoryLog setFrame:frameHistoryLog];
        CGRect frameHistory = self.viewHistory.frame;
        frameHistory.size.height = fltHistoryLogHeight+30;
        [self.viewHistory setFrame:frameHistory];
        //scrollview定高
        [self.scrollSearch setContentSize:CGSizeMake(320, 300+self.viewHistory.frame.size.height)];
        
        [self.viewHistory addSubview:viewHistoryLog];
        [viewHistoryLog release];
        [self.scrollSearch addSubview:self.viewHistory];
        [self.viewHistory release];
    }
    [searchHistory close];
}

//点击历史记录进行搜索
-(void)searchFromHistory:(UIButton *)sender
{
    FMResultSet *oneHistory = [CommonController querySql:[NSString stringWithFormat:@"SELECT * FROM paSearchHistory WHERE _id=%d",sender.tag]];
    if ([oneHistory next]) {
        self.regionSelect = [oneHistory stringForColumn:@"dcRegionID"];
        self.jobTypeSelect = [oneHistory stringForColumn:@"dcJobTypeID"];
        self.industrySelect = [oneHistory stringForColumn:@"dcIndustryID"];
        self.txtKeyWord.text = [oneHistory stringForColumn:@"keyWords"];
        NSArray *arrName = [[oneHistory stringForColumn:@"Name"] componentsSeparatedByString:@"+"];
        self.lbRegionSelect.text = arrName[0];
        if (self.jobTypeSelect.length > 0) {
            self.lbJobTypeSelect.text = arrName[1];
            if (self.industrySelect.length > 0) {
                self.lbIndustrySelect.text = arrName[2];
            }
        }
        else if (self.industrySelect.length > 0) {
            self.lbIndustrySelect.text = arrName[1];
        }
        [self searchJob];
    }
    [oneHistory close];
}

-(void)clearAllHistory
{
    [CommonController execSql:@"DELETE FROM paSearchHistory"];
    [self.viewHistory removeFromSuperview];
}

-(void)showRegionSelect:(UIButton *)sender {
    [self cancelDicPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCustom:DictionaryPickerWithRegionL3 pickerMode:DictionaryPickerModeMulti pickerInclude:DictionaryPickerIncludeParent delegate:self defaultValue:self.regionSelect defaultName:self.lbRegionSelect.text] autorelease];
    [self.DictionaryPicker setTag:1];
    [self.DictionaryPicker showInView:[CommonController getFatherController:self.view].view ];
}

-(void)showJobTypeSelect:(UIButton *)sender {
    [self cancelDicPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCustom:DictionaryPickerWithJobType pickerMode:DictionaryPickerModeMulti pickerInclude:DictionaryPickerIncludeParent delegate:self defaultValue:self.jobTypeSelect defaultName:self.lbJobTypeSelect.text] autorelease];
    [self.DictionaryPicker setTag:2];
    [self.DictionaryPicker showInView: [CommonController getFatherController:self.view].view ];
}

-(void)showIndustrySelect:(UIButton *)sender {
    [self cancelDicPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCommon:self pickerMode:DictionaryPickerModeMulti tableName:@"dcIndustry" defaultValue:self.industrySelect defaultName:self.lbIndustrySelect.text] autorelease];
    
    [self.DictionaryPicker setTag:3];
    NSLog(@"%d",[self.DictionaryPicker retainCount]);
    [self.DictionaryPicker showInView:[CommonController getFatherController:self.view].view ];
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
        case 3:
            self.industrySelect = selectedValue;
            if (selectedValue.length == 0) {
                self.lbIndustrySelect.text = @"所有行业";
            }
            else {
                self.lbIndustrySelect.text = selectedName;
            }
            break;
        default:
            break;
    }
    [self cancelDicPicker];
}

//搜索职位
- (IBAction)btnSearchJobClick:(id)sender {
    [self searchJob];
}

-(void) searchJob{
    NSString *strSearchRegion = self.regionSelect;
    NSString *strSearchJobType = self.jobTypeSelect;
    NSString *strSearchIndustry = self.industrySelect;
    NSString *strSearchKeyword = self.txtKeyWord.text;
    NSString *strSearchRegionName = self.lbRegionSelect.text;
    NSString *strSearchJobTypeName = self.lbJobTypeSelect.text;
    NSString *strSearchCondition = self.lbRegionSelect.text;
    
    if (self.jobTypeSelect.length > 0) {
        strSearchCondition = [strSearchCondition stringByAppendingFormat:@"+%@",self.lbJobTypeSelect.text];
    }
    if (self.industrySelect.length > 0) {
        strSearchCondition = [strSearchCondition stringByAppendingFormat:@"+%@",self.lbIndustrySelect.text];
    }
    if (self.txtKeyWord.text.length > 0) {
        strSearchCondition = [strSearchCondition stringByAppendingFormat:@"+%@",self.txtKeyWord.text];
    }
    strSearchCondition = strSearchCondition;
    [searchDelegate gotoJobSearchResultListView:strSearchRegion SearchJobType:strSearchJobType SearchIndustry:strSearchIndustry SearchKeyword:strSearchKeyword SearchRegionName:strSearchRegionName SearchJobTypeName:strSearchJobTypeName SearchCondition:strSearchCondition];   
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (int)slideMenuItem
{
    return 2;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_viewSearchSelect release];
    [_btnSearch release];
    [_txtKeyWord release];
    [_btnRegionSelect release];
    [_btnJobTypeSelect release];
    [_btnIndustrySelect release];
    [_lbRegionSelect release];
    [_lbJobTypeSelect release];
    [_lbIndustrySelect release];
    [_regionSelect release];
    [_jobTypeSelect release];
    [_industrySelect release];
    [_DictionaryPicker release];
    [_scrollSearch release];
    [super dealloc];
}
@end

