#import "SearchViewController.h"
#import "DictionaryPickerView.h"
#import "SlideNavigationController.h"
#import "Toast+UIView.h"
#import "SearchListViewController.h"
#import "FMDatabase.h"
#import "MapSearchViewController.h"
#import "CommonController.h"

@interface SearchViewController () <DictionaryPickerDelegate,SlideNavigationControllerDelegate,UIGestureRecognizerDelegate>
@property (strong, nonatomic) DictionaryPickerView *DictionaryPicker;
@property (retain, nonatomic) NSString *regionSelect;
@property (retain, nonatomic) NSString *jobTypeSelect;
@property (retain, nonatomic) NSString *industrySelect;
@property (retain, nonatomic) UISwipeGestureRecognizer *swipeGesture;
-(void)cancelDicPicker;
@end

@implementation SearchViewController

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
    self.swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchToMapSearch)];
    [self.swipeGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:self.swipeGesture];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.viewSearchSelect.layer.cornerRadius = 5;
    self.viewSearchSelect.layer.borderWidth = 1;
    self.viewSearchSelect.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    self.btnSearch.layer.cornerRadius = 5;
    
    [self.btnSearch addTarget:self action:@selector(searchJob) forControlEvents:UIControlEventTouchUpInside];
    [self.btnRegionSelect addTarget:self action:@selector(showRegionSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnJobTypeSelect addTarget:self action:@selector(showJobTypeSelect:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnIndustrySelect addTarget:self action:@selector(showIndustrySelect:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.lbRegionSelect setText:@"山东省"];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    self.regionSelect = [userDefault objectForKey:@"subSiteId"];
}

-(void)switchToMapSearch
{
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.lbSearch setTextColor:[UIColor blackColor]];
                         [self.lbMapSearch setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
                         [self.imgSearch setImage:[UIImage imageNamed:@"ico_mainsearch_normalsearch2.png"]];
                         [self.imgMapSearch setImage:[UIImage imageNamed:@"ico_mainsearch_mapsearch1.png"]];
                         [self.lbUnderline setFrame:CGRectMake(160, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
                     } completion:^(BOOL finished) {
                         MapSearchViewController *mapSearchC = [self.storyboard instantiateViewControllerWithIdentifier:@"MapSearchView"];
                         [mapSearchC.navigationItem setTitle:@"地图搜索"];
                         [self.navigationController pushViewController:mapSearchC animated:false];
                     }];
}

- (IBAction)switchToMapSearch:(id)sender {
    [self switchToMapSearch];
}

-(void)showSearchHistory
{
    FMResultSet *searchHistory = [CommonController querySql:@"SELECT * FROM paSearchHistory ORDER BY AddDate DESC"];
    if ([searchHistory next]) {
        searchHistory = [CommonController querySql:@"SELECT * FROM paSearchHistory ORDER BY AddDate DESC LIMIT 0,10"];
        //添加搜索记录
        self.viewHistory = [[[UIView alloc] initWithFrame:CGRectMake(20, 280, 280, 1000)] autorelease];
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
    }
    [searchHistory close];
}

-(void)searchFromHistory:(UIButton *)sender
{
    NSLog(@"%d",sender.tag);
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
    [self.DictionaryPicker showInView:self.view];
}

-(void)showJobTypeSelect:(UIButton *)sender {
    [self cancelDicPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCustom:DictionaryPickerWithJobType pickerMode:DictionaryPickerModeMulti pickerInclude:DictionaryPickerIncludeParent delegate:self defaultValue:self.jobTypeSelect defaultName:self.lbJobTypeSelect.text] autorelease];
    [self.DictionaryPicker setTag:2];
    [self.DictionaryPicker showInView:self.view];
}

-(void)showIndustrySelect:(UIButton *)sender {
    [self cancelDicPicker];
    self.DictionaryPicker = [[[DictionaryPickerView alloc] initWithCommon:self pickerMode:DictionaryPickerModeMulti tableName:@"dcIndustry" defaultValue:self.industrySelect defaultName:self.lbIndustrySelect.text] autorelease];
    
    [self.DictionaryPicker setTag:3];
    NSLog(@"%d",[self.DictionaryPicker retainCount]);
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

- (void)searchJob
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
    SearchListViewController *destinationController = (SearchListViewController*)[mainStoryboard
                                                                      instantiateViewControllerWithIdentifier: @"SearchListView"];
    
    destinationController.searchRegion = self.regionSelect;
    destinationController.searchJobType = self.jobTypeSelect;
    destinationController.searchIndustry = self.industrySelect;
    destinationController.searchKeyword = self.txtKeyWord.text;
    destinationController.searchRegionName = self.lbRegionSelect.text;
    destinationController.searchJobTypeName = self.lbJobTypeSelect.text;
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
    destinationController.searchCondition = strSearchCondition;
    [self.navigationController pushViewController:destinationController animated:true];
}

- (void) switchToSearch
{
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [self.lbMapSearch setTextColor:[UIColor blackColor]];
                         [self.lbSearch setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
                         [self.imgSearch setImage:[UIImage imageNamed:@"ico_mainsearch_normalsearch1.png"]];
                         [self.imgMapSearch setImage:[UIImage imageNamed:@"ico_mainsearch_mapsearch2.png"]];
                         [self.lbUnderline setFrame:CGRectMake(0, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (int)slideMenuItem
{
    return 2;
}

- (UIGestureRecognizer *)haveAnotherGesture
{
    return self.swipeGesture;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self switchToSearch];
    [self showSearchHistory];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_viewHistory release];
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
    [_swipeGesture release];
    [_imgSearch release];
    [_lbSearch release];
    [_imgMapSearch release];
    [_lbMapSearch release];
    [_lbUnderline release];
    [super dealloc];
}
@end
