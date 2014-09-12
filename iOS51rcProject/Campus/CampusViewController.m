#import "CampusViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "MJRefresh.h"
#import "DictionaryPickerView.h"
#import "Toast+UIView.h"
#import "SlideNavigationController.h"
#import "CampusCompanyViewController.h"

@interface CampusViewController () <UICollectionViewDataSource,UICollectionViewDelegate,NetWebServiceRequestDelegate,DictionaryPickerDelegate,UIScrollViewDelegate,SlideNavigationControllerDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NSMutableArray *campusListData;
@property (nonatomic, retain) NSMutableArray *employListData;
@property (nonatomic, retain) NSMutableArray *schoolData;
@property (nonatomic, retain) NSString *regionId;
@property (nonatomic, retain) NSString *schoolId;
@property int pageNumber;
@property int pageNumberEmploy;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property (nonatomic, retain) NetWebServiceRequest *runningRequestCampus;
@property (nonatomic, retain) DictionaryPickerView *dictionaryPicker;
@end

@implementation CampusViewController

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
    [self.scrollCampus setContentSize:CGSizeMake(640, self.scrollCampus.frame.size.height)];
    self.scrollCampus.delegate = self;
    //按钮加边框
    self.btnRegionSelect.layer.borderWidth = 1;
    self.btnRegionSelect.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    self.btnCampusSelect.layer.borderWidth = 1;
    self.btnCampusSelect.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //添加上拉加载更多
    [self.collectView addFooterWithTarget:self action:@selector(footerRereshing)];
    [self.collectViewEmploy addFooterWithTarget:self action:@selector(footerRereshingEmploy)];
    self.pageNumber = 1;
    self.regionId = @"";
    self.schoolId = @"";
    [self onSearch];
    
    self.pageNumberEmploy = 1;
}

- (void)onSearch
{
    if (self.pageNumber == 1) {
        [self.campusListData removeAllObjects];
        [self.collectView reloadData];
        //开始等待动画
        [loadView startAnimating];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.pageNumber] forKey:@"pageNum"];
    [dicParam setObject:@"30" forKey:@"pageSize"];
    [dicParam setObject:self.regionId forKey:@"dcRegionID"];
    [dicParam setObject:self.schoolId forKey:@"strSchoolID"];
    [dicParam setObject:@"32" forKey:@"strProvinceID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCampusListByRegionAndSchool" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 1;
    self.runningRequest = request;
    [dicParam release];
}

- (void)onCampusSearch
{
    [loadView startAnimating];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.regionId forKey:@"regionID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetSchoolByRegionID" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 2;
    self.runningRequestCampus = request;
    [dicParam release];
}

- (void)onEmploySearch
{
    if (self.pageNumberEmploy == 1) {
        [self.employListData removeAllObjects];
        [self.collectViewEmploy reloadData];
        //开始等待动画
        [loadView startAnimating];
    }
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:@"32" forKey:@"dcProvinceID"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.pageNumberEmploy] forKey:@"pageNum"];
    [dicParam setObject:@"30" forKey:@"pageSize"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetSchoolNewsList" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 3;
    self.runningRequest = request;
    [dicParam release];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSMutableArray *)requestData
{
    if (request.tag == 1) {
        [self.collectView footerEndRefreshing];
        if (requestData.count == 0) {
            [self.view makeToast:@"没有更多数据了"];
        }
        if(self.pageNumber == 1){
            [self.campusListData removeAllObjects];
            self.campusListData = requestData;
        }
        else{
            [self.campusListData addObjectsFromArray:requestData];
        }
        //重新加载列表
        [self.collectView reloadData];
    }
    else if (request.tag == 2) {
        NSMutableArray *arrSchool = [[NSMutableArray alloc] init];
        for (int i = 0; i < requestData.count; i++) {
            NSDictionary *dicSchool = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                        requestData[i][@"ID"],@"id",
                                        requestData[i][@"SchoolName"],@"value"
                                        ,nil] autorelease];
            [arrSchool addObject:dicSchool];
        }
        self.schoolData = arrSchool;
        [arrSchool release];
    }
    else if (request.tag == 3) {
        [self.collectViewEmploy footerEndRefreshing];
        if (requestData.count == 0) {
            [self.view makeToast:@"没有更多数据了"];
        }
        if(self.pageNumberEmploy == 1){
            [self.employListData removeAllObjects];
            self.employListData = requestData;
        }
        else{
            [self.employListData addObjectsFromArray:requestData];
        }
        //重新加载列表
        [self.collectViewEmploy reloadData];
    }
    //结束等待动画
    [loadView stopAnimating];
}

- (void)footerRereshing{
    self.pageNumber++;
    [self onSearch];
}

- (void)footerRereshingEmploy{
    self.pageNumberEmploy++;
    [self onEmploySearch];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView.tag == 1) {
        return self.campusListData.count;
    }
    else {
        return self.employListData.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 1) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"campus" forIndexPath:indexPath];
        for (UIView*view in cell.contentView.subviews) {
            if (view) {
                [view removeFromSuperview];
            }
        }
        cell.layer.borderWidth = 1;
        cell.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
        //企业名称
        NSDictionary *rowData = [self.campusListData objectAtIndex:indexPath.row];
        UILabel *lbCompanyName = [[UILabel alloc] initWithFrame:CGRectMake(10, 9, 220, 25)];
        [lbCompanyName setText:rowData[@"CompanyName"]];
        [cell.contentView addSubview:lbCompanyName];
        [lbCompanyName release];
        
        //举办日期
        NSString *strBeginTime = rowData[@"BeginTime"];
        NSDate *dtBeginTime = [CommonController dateFromString:strBeginTime];
        strBeginTime = [CommonController stringFromDate:dtBeginTime formatType:@"MM-dd HH:mm"];
        NSString *strWeek = [CommonController getWeek:dtBeginTime];
        
        UILabel *lbBeginTime = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, 220, 20)];
        [lbBeginTime setFont:[UIFont systemFontOfSize:12]];
        [lbBeginTime setTextColor:[UIColor grayColor]];
        [lbBeginTime setText:[NSString stringWithFormat:@"举办时间：%@-%@ %@",strBeginTime,[CommonController stringFromDate:[CommonController dateFromString:rowData[@"EndTime"]] formatType:@"HH:mm"],strWeek]];
        [cell.contentView addSubview:lbBeginTime];
        [lbBeginTime release];
        
        //举办学校
        UILabel *lbSchool = [[UILabel alloc] initWithFrame:CGRectMake(10, 55, 220, 20)];
        [lbSchool setFont:[UIFont systemFontOfSize:12]];
        [lbSchool setTextColor:[UIColor grayColor]];
        [lbSchool setText:[NSString stringWithFormat:@"%@[%@]",rowData[@"RegionName"],rowData[@"SchoolName"]]];
        [cell.contentView addSubview:lbSchool];
        [lbSchool release];
        
        //举办地点
        UILabel *lbPlace = [[UILabel alloc] initWithFrame:CGRectMake(10, 75, 220, 20)];
        [lbPlace setFont:[UIFont systemFontOfSize:12]];
        [lbPlace setTextColor:[UIColor grayColor]];
        [lbPlace setText:[NSString stringWithFormat:@"%@",rowData[@"Address"]]];
        [cell.contentView addSubview:lbPlace];
        [lbPlace release];
        
        //添加时间提醒
        double dayInterval = [dtBeginTime timeIntervalSinceNow]/86400;
        NSString *strDayInterval,*strFlagImg;
        if (dayInterval < -1) {
            UIImageView *imgExpired = [[UIImageView alloc] initWithFrame:CGRectMake(240, 0, 40, 40)];
            imgExpired.image = [UIImage imageNamed:@"ico_expire.png"];
            [cell.contentView addSubview:imgExpired];
            [imgExpired release];
        }
        else {
            if (dayInterval < 1) {
                strDayInterval = @"今天";
                strFlagImg = @"bg_lasttime_red.png";
            }
            else {
                strDayInterval = [NSString stringWithFormat:@"%d天",(int)dayInterval];
                strFlagImg = @"bg_lasttiem_green.png";
            }
            //添加旗子图片
            UIImageView *imgFlag = [[UIImageView alloc] initWithFrame:CGRectMake(240, 0, 30, 30)];
            [imgFlag setImage:[UIImage imageNamed:strFlagImg]];
            //添加文字
            UILabel *lbDayInterval = [[UILabel alloc] initWithFrame:CGRectMake(0, 3, 30, 20)];
            [lbDayInterval setText:strDayInterval];
            [lbDayInterval setTextColor:[UIColor whiteColor]];
            [lbDayInterval setFont:[UIFont systemFontOfSize:12]];
            [lbDayInterval setTextAlignment:NSTextAlignmentCenter];
            [imgFlag addSubview:lbDayInterval];
            [cell.contentView addSubview:imgFlag];
            [lbDayInterval release];
            [imgFlag release];
        }
        return cell;
    }
    else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"employ" forIndexPath:indexPath];
        for (UIView*view in cell.contentView.subviews) {
            if (view) {
                [view removeFromSuperview];
            }
        }
        cell.layer.borderWidth = 1;
        cell.layer.borderColor = [[UIColor colorWithRed:236.f/255.f green:236.f/255.f blue:236.f/255.f alpha:1] CGColor];
        //企业名称
        NSDictionary *rowData = [self.employListData objectAtIndex:indexPath.row];
        UILabel *lbCompanyName = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 280, 25)];
        [lbCompanyName setText:rowData[@"Title"]];
        [lbCompanyName setFont:[UIFont systemFontOfSize:14]];
        [cell.contentView addSubview:lbCompanyName];
        [lbCompanyName release];
        
        if (indexPath.row < 3) {
            UIImageView *imgHot = [[UIImageView alloc] initWithFrame:CGRectMake(270, 0, 30, 30)];
            [imgHot setImage:[UIImage imageNamed:@"ico_news_hot.png"]];
            [cell.contentView addSubview:imgHot];
            [imgHot release];
        }
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CampusCompanyViewController *campusCompanyC = [self.storyboard instantiateViewControllerWithIdentifier:@"CampusCompanyView"];
    if (collectionView.tag == 1) {
        campusCompanyC.companyId = [self.campusListData objectAtIndex:indexPath.row][@"CompanyID"];
        [campusCompanyC.navigationItem setTitle:[self.campusListData objectAtIndex:indexPath.row][@"CompanyName"]];
        campusCompanyC.tabIndex = 2;
    }
    else {
        campusCompanyC.employId = [self.employListData objectAtIndex:indexPath.row][@"id"];
        campusCompanyC.tabIndex = 3;
    }
    [self.navigationController pushViewController:campusCompanyC animated:true];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollCampus.contentOffset.x > 160) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.lbCampus setTextColor:[UIColor blackColor]];
            [self.lbEmploy setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
            [self.lbUnderline setFrame:CGRectMake(160, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
        } completion:^(BOOL finished) {
            if (self.employListData.count == 0) {
                [self onEmploySearch];
            }
        }];
    }
    else {
        [UIView animateWithDuration:0.2 animations:^{
            [self.lbEmploy setTextColor:[UIColor blackColor]];
            [self.lbCampus setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
            [self.lbUnderline setFrame:CGRectMake(0, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
        }];
    }
}

- (IBAction)swithToCampus:(id)sender {
    [self.scrollCampus setContentOffset:CGPointMake(0, 0) animated:true];
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbEmploy setTextColor:[UIColor blackColor]];
        [self.lbCampus setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbUnderline setFrame:CGRectMake(0, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
    }];
}
- (IBAction)switchToEmploy:(id)sender {
    [self.scrollCampus setContentOffset:CGPointMake(320, 0) animated:true];
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbCampus setTextColor:[UIColor blackColor]];
        [self.lbEmploy setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbUnderline setFrame:CGRectMake(160, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
    } completion:^(BOOL finished) {
        if (self.employListData.count == 0) {
            [self onEmploySearch];
        }
    }];
}

- (IBAction)regionSelect:(UIButton *)sender {
    self.dictionaryPicker = [[[DictionaryPickerView alloc] initWithCustom:DictionaryPickerWithRegionL2 pickerMode:DictionaryPickerModeOne pickerInclude:DictionaryPickerIncludeParent delegate:self defaultValue:self.regionId defaultName:@""] autorelease];
    [self.dictionaryPicker setTag:1];
    [self.dictionaryPicker showInView:self.view];
}

- (IBAction)campusSelect:(UIButton *)sender {
    if (self.regionId.length == 0) {
        [self.view makeToast:@"请先选择地区"];
        return;
    }
    else if (self.schoolData.count == 0) {
        [self.view makeToast:@"该地区下没有学校信息"];
        return;
    }
    self.dictionaryPicker = [[[DictionaryPickerView alloc] initWithDictionary:self defaultArray:self.schoolData defalutValue:self.schoolId defalutName:@"" pickerMode:DictionaryPickerModeOne] autorelease];
    [self.dictionaryPicker setTag:2];
    [self.dictionaryPicker showInView:self.view];
}

- (void)pickerDidChangeStatus:(DictionaryPickerView *)picker
                selectedValue:(NSString *)selectedValue
                 selectedName:(NSString *)selectedName
{
    if (picker.tag == 1) {
        self.regionId = selectedValue;
        [self.lbRegionSelect setText:selectedName];
        self.pageNumber = 1;
        [self onSearch];
        [self onCampusSearch];
    }
    else if (picker.tag == 2) {
        self.schoolId = selectedValue;
        [self.lbCampusSelect setText:selectedName];
        self.pageNumber = 1;
        [self onSearch];
    }
    [self cancelDicPicker];
}

-(void)cancelDicPicker
{
    [self.dictionaryPicker cancelPicker];
    self.dictionaryPicker.delegate = nil;
    self.dictionaryPicker = nil;
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (int)slideMenuItem
{
    return 7;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    [loadView release];
    [_campusListData release];
    [_employListData release];
    [_schoolData release];
    [_regionId release];
    [_schoolId release];
    [_runningRequest release];
    [_runningRequestCampus release];
    [_dictionaryPicker release];
    [_collectView release];
    [_btnRegionSelect release];
    [_btnCampusSelect release];
    [_lbRegionSelect release];
    [_lbCampusSelect release];
    [_scrollCampus release];
    [_lbCampus release];
    [_lbEmploy release];
    [_lbUnderline release];
    [_collectViewEmploy release];
    [super dealloc];
}
@end
