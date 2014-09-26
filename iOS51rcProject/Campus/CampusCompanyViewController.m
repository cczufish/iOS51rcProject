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

@interface CampusCompanyViewController () <UICollectionViewDataSource,UICollectionViewDelegate,NetWebServiceRequestDelegate,UIScrollViewDelegate>
{
    LoadingAnimationView *loadView;
}
@property (nonatomic, retain) NSMutableArray *campusListData;
@property (nonatomic, retain) NSMutableArray *employData;
@property (nonatomic, retain) NSMutableArray *employListData;
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
}

//获取宣讲会列表
- (void)onCampusSearch
{
    //开始等待动画
    [loadView startAnimating];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [dicParam setObject:[userDefault objectForKey:@"subSiteId"] forKey:@"ProvinceID"];
    [dicParam setObject:self.companyId forKey:@"CompanyID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCampusTalkByProvinceIDCompanyID" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 1;
    self.runningRequest = request;
    [dicParam release];
}

//获取招聘简章，根据招聘简章ID
- (void)onEmploySearch
{
    //开始等待动画
    [loadView startAnimating];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.employId forKey:@"ID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCampusCpInfoByCampusID" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 2;
    self.runningRequest = request;
    [dicParam release];
}

//获取招聘简章，根据企业ID
- (void)onEmploySearchByCpID
{
    //开始等待动画
    [loadView startAnimating];
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.companyId forKey:@"ID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCampusCpInfoByCpID" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 3;
    self.runningRequest = request;
    [dicParam release];
}

//获取往期招聘简章
- (void)onEmploySearchBefore
{
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:self.companyId forKey:@"CompanyID"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetOtherCpRmByID" Params:dicParam];
    [request setDelegate:self];
    [request startAsynchronous];
    request.tag = 4;
    self.runningRequest = request;
    [dicParam release];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(NSMutableArray *)requestData
{
    if (request.tag == 1) { //获取宣讲会
        if (requestData.count == 0) {
            [self.viewCampusTips setHidden:false];
            self.campusListData = [NSMutableArray arrayWithObject:@"null"];
        }
        else {
            [self.campusListData removeAllObjects];
            self.campusListData = requestData;
            //重新加载列表
            [self.collectView reloadData];
        }
    }
    else if (request.tag == 4) { //获取往期招聘简章
        self.employListData = requestData;
        [self fillEmployBefore];
    }
    else { //获取校园简章
        self.employData = requestData;
        self.companyId = requestData[0][@"CompanyID1"];
        [self.navigationItem setTitle:requestData[0][@"CompanyName"]];
        [self fillCpInfo];
    }
    //结束等待动画
    [loadView stopAnimating];
}

- (IBAction)switchToBrief:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:true];
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbEmploy setTextColor:[UIColor blackColor]];
        [self.lbCampus setTextColor:[UIColor blackColor]];
        [self.lbBrief setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbUnderline setFrame:CGRectMake(0, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
    } completion:^(BOOL finished) {
        if (self.employData.count == 0) {
            [self onEmploySearchByCpID];
        }
    }];
}

- (IBAction)switchToCampus:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(320, 0) animated:true];
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

- (IBAction)switchToEmploy:(id)sender {
    [self.scrollView setContentOffset:CGPointMake(640, 0) animated:true];
    [UIView animateWithDuration:0.2 animations:^{
        [self.lbCampus setTextColor:[UIColor blackColor]];
        [self.lbBrief setTextColor:[UIColor blackColor]];
        [self.lbEmploy setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [self.lbUnderline setFrame:CGRectMake(214, self.lbUnderline.frame.origin.y, self.lbUnderline.frame.size.width, self.lbUnderline.frame.size.height)];
    } completion:^(BOOL finished) {
        if (self.employData.count == 0) {
            if (self.companyId.length == 0) {
                [self onEmploySearch];
            }
            else {
                [self onEmploySearchByCpID];
            }
        }
    }];
}

- (void)fillCpInfo
{
    NSDictionary *dicCpInfo = self.employData[0];
    //显示公司名称、行业、工作地点
    [self.lbCompanyName setText:dicCpInfo[@"CompanyName"]];
    [self.lbIndustry setText:dicCpInfo[@"Industry"]];
    [self.lbCity setText:dicCpInfo[@"RegionName"]];
    //显示主页
    if (dicCpInfo[@"HomePage"]) {
        [self.lbHomepage setText:dicCpInfo[@"HomePage"]];
    }
    else { //没有主页的时候，隐藏，并且将公司详情的label上提
        [self.viewHomepage setHidden:true];
        [self.lbDescription setFrame:CGRectMake(self.lbDescription.frame.origin.x, 121, self.lbDescription.frame.size.width, self.lbDescription.frame.size.width)];
    }
    //显示公司详情，去除html标签
    NSString *companyDescription = dicCpInfo[@"CompanyDescription"];
    companyDescription = [CommonController FilterHtml:companyDescription];
    CGSize labelSize = [CommonController CalculateFrame:companyDescription fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(self.lbDescription.frame.size.width, 5000)];
    [self.lbDescription setText:companyDescription];
    [self.lbDescription setFrame:CGRectMake(self.lbDescription.frame.origin.x, self.lbDescription.frame.origin.y, self.lbDescription.frame.size.width, labelSize.height)];
    self.lbDescription.lineBreakMode = NSLineBreakByCharWrapping;
    self.lbDescription.numberOfLines = 0;
    //设置scrollview的高度
    [self.scrollCpInfo setContentSize:CGSizeMake(self.scrollCpInfo.contentSize.width, self.lbDescription.frame.origin.y+labelSize.height+20)];
    
    //没有招聘简章
    if (dicCpInfo[@"Title"] == nil) {
        [self.viewEmployTips setHidden:false];
        return;
    }
    //招聘简章相关内容填充
    [self.lbEmployCompany setText:dicCpInfo[@"Title"]];
    NSString *description = dicCpInfo[@"Description"];
    description = [CommonController FilterHtml:description];
    labelSize = [CommonController CalculateFrame:description fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(self.lbEmployDescription.frame.size.width, 5000)];
    [self.lbEmployDescription setText:description];
    [self.lbEmployDescription setFrame:CGRectMake(self.lbEmployDescription.frame.origin.x, self.lbEmployDescription.frame.origin.y, self.lbEmployDescription.frame.size.width, labelSize.height)];
    self.lbEmployDescription.lineBreakMode = NSLineBreakByCharWrapping;
    self.lbEmployDescription.numberOfLines = 0;
    //设置scrollview的高度
    [self.scrollEmploy setContentSize:CGSizeMake(self.scrollEmploy.contentSize.width, self.lbEmployDescription.frame.origin.y+labelSize.height+20)];
    
    [self onEmploySearchBefore];
}

- (void)fillEmployBefore
{
    if (self.employListData.count == 1) {
        return;
    }
    [self.viewEmployBefore setHidden:false];
    NSArray *arrBeforeList = self.viewEmployBefore.subviews;
    for (int i=0; i<arrBeforeList.count; i++) {
        if (i>1) {
            [arrBeforeList[i] removeFromSuperview];
        }
    }
    CGRect frameEmployBefore = self.viewEmployBefore.frame;
    frameEmployBefore.origin.y = self.scrollEmploy.contentSize.height+10;
    [self.viewEmployBefore setFrame:frameEmployBefore];
    float employBeforeHeight = 40;
    for (NSDictionary *dicEmploy in self.employListData) {
        if ([self.employData[0][@"ID"] isEqualToString:dicEmploy[@"ID"]]) {
            continue;
        }
        //添加往期简章
        UIButton *buttonTitle = [[UIButton alloc] initWithFrame:CGRectMake(5, employBeforeHeight, 280, 20)];
        [buttonTitle setTitle:dicEmploy[@"Title"] forState:UIControlStateNormal];
        [buttonTitle setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [buttonTitle.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [buttonTitle setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.viewEmployBefore addSubview:buttonTitle];
        //添加点击事件
        [buttonTitle setTag:[dicEmploy[@"ID"] intValue]];
        [buttonTitle addTarget:self action:@selector(changeEmploy:) forControlEvents:UIControlEventTouchUpInside];
        [buttonTitle release];
        //添加分割线
        UILabel *lbSeparate = [[UILabel alloc] initWithFrame:CGRectMake(5, employBeforeHeight+22, 300, 1)];
        [lbSeparate setText:@"-----------------------------------------------------------------------------------------"];
        [lbSeparate setTextColor:[UIColor lightGrayColor]];
        [self.viewEmployBefore addSubview:lbSeparate];
        [lbSeparate release];
        employBeforeHeight+=30;
    }
    [self.scrollEmploy setContentSize:CGSizeMake(self.scrollEmploy.contentSize.width, self.scrollEmploy.contentSize.height+employBeforeHeight+30)];
    [self.scrollEmploy setContentOffset:CGPointMake(self.scrollEmploy.contentOffset.x, 0) animated:true];
}

- (void)changeEmploy:(UIButton *)sender
{
    self.employId = [NSString stringWithFormat:@"%d",sender.tag];
    [self.viewEmployBefore setHidden:true];
    [self onEmploySearch];
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.scrollView.contentOffset.x > 480) {
        [self switchToEmploy:nil];
    }
    else if (self.scrollView.contentOffset.x > 160) {
        [self switchToCampus:nil];
    }
    else {
        [self switchToBrief:nil];
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
    [_employListData release];
    [_employData release];
    [_runningRequest release];
    [_employId release];
    [_companyId release];
    [_viewHomepage release];
    [_lbDescription release];
    [_scrollCpInfo release];
    [_scrollEmploy release];
    [_lbEmployCompany release];
    [_lbEmployDescription release];
    [_viewEmployTips release];
    [_viewEmployBefore release];
    [loadView release];
    [super dealloc];
}
@end
