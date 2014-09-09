//
//  CampusCompanyViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-9.
//

#import "CampusCompanyViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonController.h"
#import "MJRefresh.h"
#import "Toast+UIView.h"

@interface CampusCompanyViewController () <UICollectionViewDataSource,UICollectionViewDelegate,NetWebServiceRequestDelegate,UIScrollViewDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NSMutableArray *campusListData;
@property (nonatomic, retain) NSMutableArray *employData;
@property (nonatomic, retain) NSMutableArray *companyData;
@property (nonatomic, retain) NSString *regionId;
@property (nonatomic, retain) NSString *companyId;
@property int pageNumber;
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;

@end

@implementation CampusCompanyViewController

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
    [self.scrollView setContentSize:CGSizeMake(960, self.scrollView.frame.size.height)];
    switch (self.tabIndex) {
        case 1:
            [self switchToBrief:nil];
            break;
        case 2:
            [self switchToCampus:nil];
            break;
        case 3:
            [self switchToEmploy:nil];
            break;
        default:
            break;
    }
    
    //加载等待动画
    loadView = [[LoadingAnimationView alloc] initWithFrame:CGRectMake(140, 100, 80, 98) loadingAnimationViewStyle:LoadingAnimationViewStyleCarton target:self];
    //添加上拉加载更多
    [self.collectView addFooterWithTarget:self action:@selector(footerRereshing)];
}

- (void)onSearch
{
//    if (self.pageNumber == 1) {
//        [self.campusListData removeAllObjects];
//        [self.collectView reloadData];
//        //开始等待动画
//        [loadView startAnimating];
//    }
//    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
//    [dicParam setObject:[NSString stringWithFormat:@"%d",self.pageNumber] forKey:@"pageNum"];
//    [dicParam setObject:@"30" forKey:@"pageSize"];
//    [dicParam setObject:self.regionId forKey:@"dcRegionID"];
//    [dicParam setObject:@"32" forKey:@"strProvinceID"];
//    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCampusListByRegionAndSchool" Params:dicParam];
//    [request setDelegate:self];
//    [request startAsynchronous];
//    request.tag = 1;
//    self.runningRequest = request;
//    [dicParam release];
}

- (void)onEmploySearch
{
    
}

- (void)onCampusSearch
{
    
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSMutableArray *)requestData
{
    if (request.tag == 1) { //获取企业信息
        self.companyData = requestData;
    }
    else if (request.tag == 2) { //获取宣讲会
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
    else if (request.tag == 3) { //获取校园简章
        self.employData = requestData;
    }
    //结束等待动画
    [loadView stopAnimating];
}

- (IBAction)switchToBrief:(id)sender {
    
}

- (IBAction)switchToCampus:(id)sender {
    
}

- (IBAction)switchToEmploy:(id)sender {
    
}

- (void)footerRereshing{
    self.pageNumber++;
    [self onSearch];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.campusListData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",[self.campusListData objectAtIndex:indexPath.row][@"id"]);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollView.contentOffset.x > 480) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.lbCampus setTextColor:[UIColor blackColor]];
            [self.lbBrief setTextColor:[UIColor blackColor]];
            [self.lbEmploy setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
            [self.lbUnderline setFrame:CGRectMake(214, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
        } completion:^(BOOL finished) {
            if (self.employData.count == 0) {
                [self onEmploySearch];
            }
        }];
    }
    else if (self.scrollView.contentOffset.x > 160) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.lbEmploy setTextColor:[UIColor blackColor]];
            [self.lbBrief setTextColor:[UIColor blackColor]];
            [self.lbCampus setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
            [self.lbUnderline setFrame:CGRectMake(106, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
        } completion:^(BOOL finished) {
            if (self.campusListData.count == 0) {
                [self onCampusSearch];
            }
        }];
    }
    else {
        [UIView animateWithDuration:0.2 animations:^{
            [self.lbEmploy setTextColor:[UIColor blackColor]];
            [self.lbCampus setTextColor:[UIColor blackColor]];
            [self.lbBrief setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
            [self.lbUnderline setFrame:CGRectMake(0, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
        } completion:^(BOOL finished) {
            if (self.companyData.count == 0) {
                [self onSearch];
            }
        }];
    }
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
    [_lbCompanyName release];
    [_lbCity release];
    [_lbIndustry release];
    [_lbHomepage release];
    [_lbUnderline release];
    [_lbBrief release];
    [_lbCampus release];
    [_lbEmploy release];
    [_scrollView release];
    [_collectView release];
    [_campusListData release];
    [_employData release];
    [_companyData release];
    [_companyId release];
    [_runningRequest release];
    [super dealloc];
}
@end
