#import "MapSearchViewController.h"
#import "NetWebServiceRequest.h"
#import "MapSearchListViewController.h"
#import "SlideNavigationController.h"
#import "CommonController.h"
#import "CustomPopup.h"
#import "JobViewController.h"
#import "SearchViewController.h"

@interface MapSearchViewController () <BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,NetWebServiceRequestDelegate,SlideNavigationControllerDelegate,CustomPopupDelegate>
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property int pageNumber;
@property int jobNumber;
@property float lat;
@property float lng;
@property float distance;
@property int maxPageNumber;
@property (retain, nonatomic) NSString *rsType;
@property (nonatomic, retain) NSMutableArray *jobAnnotations;
@property (nonatomic, retain) NSMutableArray *jobDetails;
@property (nonatomic, retain) CustomPopup *cPopup;

@end

@implementation MapSearchViewController

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
    //初始化
    self.jobAnnotations = [NSMutableArray arrayWithCapacity:30];
    self.jobDetails = [NSMutableArray arrayWithCapacity:30];
    self.pageNumber = 1;
    self.rsType = @"";
    self.distance = 5000;
    [self.viewMap setHidden:true];
    //设置职位显示框的边框
    self.viewJobShow.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.viewJobShow.layer.borderWidth = 1;
    self.viewJobShow.layer.cornerRadius = 5;
    if (![[CommonController GetCurrentNet] isEqualToString:@"wifi"]) {
        //添加温馨提示说明
        NSString *strNoWifi = @"系统检测到您没有接入wifi网络，使用地图搜索可能会耗费大量流量，您确定继续这么做么？";
        CGSize labelSize = [CommonController CalculateFrame:strNoWifi fontDemond:[UIFont systemFontOfSize:14] sizeDemand:CGSizeMake(240, 5000)];
        UILabel *lbNoWifi = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, labelSize.width, labelSize.height)];
        [lbNoWifi setText: strNoWifi];
        [lbNoWifi setFont:[UIFont systemFontOfSize:14]];
        lbNoWifi.numberOfLines = 0;
        lbNoWifi.lineBreakMode = NSLineBreakByCharWrapping;
        //添加view
        UIView *viewPopup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelSize.width+20, labelSize.height+50)];
        [viewPopup addSubview:lbNoWifi];
        //添加“温馨提示”
        UILabel *lbNoWifiTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width+10, 20)];
        [lbNoWifiTitle setText:@"温馨提示"];
        [lbNoWifiTitle setTextColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        [lbNoWifiTitle setTextAlignment:NSTextAlignmentCenter];
        //添加分割线
        UILabel *lbSeperate = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, labelSize.width, 1)];
        [lbSeperate setBackgroundColor:[UIColor colorWithRed:255.f/255.f green:90.f/255.f blue:39.f/255.f alpha:1]];
        
        [viewPopup addSubview:lbNoWifiTitle];
        [viewPopup addSubview:lbSeperate];
        //显示
        self.cPopup = [[[CustomPopup alloc] popupCommon:viewPopup buttonType:PopupButtonTypeConfirmAndCancel] autorelease];
        self.cPopup.delegate = self;
        [self.cPopup showPopup:self.view];
        [lbNoWifi release];
        [lbNoWifiTitle release];
        [lbSeperate release];
        [viewPopup release];
    }
    else {
        [self confirmAndCancelPopupNext];
    }
}

//定位完成后执行此方法，将定位的位置添加到地图上
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    [self.viewMap setCenterCoordinate:userLocation.location.coordinate animated:true];
    [self.locService stopUserLocationService];
    [self getAddress:userLocation.location.coordinate];

    self.lat = userLocation.location.coordinate.latitude;
    self.lng = userLocation.location.coordinate.longitude;
    self.pageNumber = 1;
    [self onSearch];
}

//添加位置时执行此方法
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    BMKPinAnnotationView *newAnnotation = [[[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:self.annotationViewID] autorelease];
    // 从天上掉下效果
    newAnnotation.animatesDrop = YES;
    // 设置颜色
    [newAnnotation setImage:[UIImage imageNamed:@"ico_mapsearch_pointer_red.png"]];
    newAnnotation.canShowCallout = NO;
    
    [self.jobAnnotations addObject:newAnnotation];
    return newAnnotation;
}

//点击位置时执行此方法
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    [self.btnJobShow setTag:[view.reuseIdentifier intValue]];
    NSArray *arrJobDetail = [[[NSArray alloc] init] autorelease];
    for (NSArray *arr in self.jobDetails) {
        if ([arr[3] isEqualToString:view.reuseIdentifier]) {
            arrJobDetail = arr;
        }
    }
    if (arrJobDetail == nil) {
        return;
    }
    self.jobNumber = (int)[self.jobDetails indexOfObject:arrJobDetail]+1;
    [self changeJob:arrJobDetail annotationView:view];
}

//地图位置改变时，触发此方法
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self getVisibleMapRadius];
}

//根据坐标获取地理位置
- (void)getAddress:(CLLocationCoordinate2D) pt
{
    [self.lbLocation setText:@"正在定位..."];
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [self.geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    [reverseGeocodeSearchOption release];
    if(!flag)
    {
        self.lbLocation.text = @"获取地理位置失败";
    }
}

//根据坐标获取地理位置成功执行此方法
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        [self.lbLocation setText:[NSString stringWithFormat:@"当前位置：%@",result.address]];
    }
    else {
        self.lbLocation.text = @"获取地理位置失败";
    }
}

//获取可视地图横向的半径
- (void)getVisibleMapRadius
{
    float fltRadius = self.viewMap.visibleMapRect.size.width/2000;
    [self.lbRadius setText:[NSString stringWithFormat:@"周边%.1lf公里",fltRadius]];
}

- (IBAction)startMapSearch:(UIButton *)sender {
    self.distance = self.viewMap.visibleMapRect.size.width/2;
    if (self.distance > 5000){
        [self.viewMap setZoomLevel:14.07];
        self.distance = 5000;
    }
    CLLocationCoordinate2D pointLocation = [self.viewMap centerCoordinate];
    [self getAddress:pointLocation];
    self.lat = pointLocation.latitude;
    self.lng = pointLocation.longitude;
    self.pageNumber = 1;
    [self onSearch];
}

- (IBAction)pagePrev:(id)sender {
    if (self.pageNumber == 1) {
        return;
    }
    self.pageNumber--;
    [self onSearch];
}

- (IBAction)pageNext:(id)sender {
    if (self.pageNumber == self.maxPageNumber) {
        return;
    }
    self.pageNumber++;
    [self onSearch];
}

- (IBAction)mapSearchList:(id)sender {
    MapSearchListViewController *mapSearchListC = (MapSearchListViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"MapSearchListView"];
    mapSearchListC.searchLat = self.lat;
    mapSearchListC.searchLng = self.lng;
    mapSearchListC.searchDistance = self.distance;
    [self.navigationController pushViewController:mapSearchListC animated:true];
}

- (IBAction)jobNext:(id)sender {
    if (self.jobNumber == self.jobAnnotations.count) {
        return;
    }
    self.jobNumber++;
    [self changeJob:[self.jobDetails objectAtIndex:self.jobNumber-1] annotationView:[self.jobAnnotations objectAtIndex:self.jobNumber-1]];
}

- (IBAction)jobPrev:(id)sender {
    if (self.jobNumber == 1) {
        return;
    }
    self.jobNumber--;
    [self changeJob:[self.jobDetails objectAtIndex:self.jobNumber-1] annotationView:[self.jobAnnotations objectAtIndex:self.jobNumber-1]];
}

- (IBAction)closeJobShow:(id)sender {
    if (![self.viewJobShow isHidden]) {
        [self.viewJobShow setHidden:true];
    }
}

- (IBAction)resetLocation:(id)sender {
    [self.locService startUserLocationService];
}

- (IBAction)goToJob:(id)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"JobSearch" bundle:nil];
    JobViewController *jobC = [storyBoard instantiateViewControllerWithIdentifier:@"JobView"];
    jobC.JobID = [NSString stringWithFormat:@"%d",self.btnJobShow.tag];
    [self.navigationController pushViewController:jobC animated:YES];
}

- (IBAction)switchToSearch:(id)sender {
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
                         SearchViewController *searchC = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchView"];
                         [self.navigationController pushViewController:searchC animated:false];
                     }];
}

- (void)changeJob:(NSArray *)jobdetail
   annotationView:(BMKAnnotationView *)annotationView
{
    //将标注点颜色改为默认
    for (BMKPinAnnotationView *annotation in self.jobAnnotations) {
        [annotation setImage:[UIImage imageNamed:@"ico_mapsearch_pointer_red.png"]];
    }
    //将选中的标注点变色，并居中显示
    [annotationView setImage:[UIImage imageNamed:@"ico_mapsearch_pointer_blue.png"]];
    [self.viewMap setCenterCoordinate:[annotationView.annotation coordinate] animated:true];
    [self.lbJobName setText:jobdetail[0]];
    [self.lbCpName setText:jobdetail[1]];
    [self.lbJobDetail setText:jobdetail[2]];
    [self.lbJobCount setText:[NSString stringWithFormat:@"%d/%d",self.jobNumber,(int)self.jobAnnotations.count]];
    if ([self.viewJobShow isHidden]) {
        [self.viewJobShow setHidden:false];
    }
}

- (void)onSearch
{
    NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
    [dicParam setObject:[NSString stringWithFormat:@"%d",(int)self.distance] forKey:@"distance"];
    [dicParam setObject:[NSString stringWithFormat:@"%f",self.lat] forKey:@"lat"];
    [dicParam setObject:[NSString stringWithFormat:@"%f",self.lng] forKey:@"lng"];
    [dicParam setObject:@"" forKey:@"jobType"];
    [dicParam setObject:@"" forKey:@"industry"];
    [dicParam setObject:@"" forKey:@"salary"];
    [dicParam setObject:@"" forKey:@"experience"];
    [dicParam setObject:@"" forKey:@"education"];
    [dicParam setObject:@"" forKey:@"employType"];
    [dicParam setObject:[NSString stringWithFormat:@"%d",self.pageNumber] forKey:@"pageNumber"];
    [dicParam setObject:@"" forKey:@"companySize"];
    [dicParam setObject:self.rsType forKey:@"rsType"];
    [dicParam setObject:@"" forKey:@"welfare"];
    [dicParam setObject:@"" forKey:@"status"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetJobListByMapSearch" Params:dicParam];
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
    //隐藏职位弹层
    if (![self.viewJobShow isHidden]) {
        [self.viewJobShow setHidden:true];
    }
    //重新回到中心点
    CLLocationCoordinate2D centerLocation;
    centerLocation.latitude = self.lat;
    centerLocation.longitude = self.lng;
    [self.viewMap setCenterCoordinate:centerLocation animated:true];
    //将所有标注点删除
    NSArray *currentAnnotations = [[self.viewMap annotations] copy];
    [self.viewMap removeAnnotations:currentAnnotations];
    [currentAnnotations release];
    //将数组清除
    [self.jobDetails removeAllObjects];
    [self.jobAnnotations removeAllObjects];
    self.maxPageNumber = 0;
    self.jobNumber = 1;
    for (NSDictionary* rowData in requestData) {
        if (self.maxPageNumber == 0) {
            self.maxPageNumber = (int)ceilf([rowData[@"JobNumber"] floatValue]/30);
            [self.lbPageCount setText:[NSString stringWithFormat:@"%d/%d",self.pageNumber,self.maxPageNumber]];
            if (self.pageNumber == 1) {
                [self.imgPagePrev setImage:[UIImage imageNamed:@"ico_mapsearch_pre_unable.png"]];
            }
            else {
                [self.imgPagePrev setImage:[UIImage imageNamed:@"ico_mapsearch_pre.png"]];
            }
            
            if (self.pageNumber == self.maxPageNumber) {
                [self.imgPageNext setImage:[UIImage imageNamed:@"ico_mapsearch_next_unable.png"]];
            }
            else {
                [self.imgPageNext setImage:[UIImage imageNamed:@"ico_mapsearch_next.png"]];
            }
        }
        self.annotationViewID = rowData[@"ID"];
        BMKPointAnnotation *jobPoint = [[[BMKPointAnnotation alloc] init] autorelease];
        CLLocationCoordinate2D jobLocation;
        jobLocation.latitude = [rowData[@"Lat"] doubleValue];
        jobLocation.longitude = [rowData[@"Lng"] doubleValue];
        jobPoint.coordinate = jobLocation;
        [self.viewMap addAnnotation:jobPoint];
        
        NSMutableString *jobDetail = [[NSMutableString alloc] initWithCapacity:10];
        //招聘人数
        [jobDetail appendString:[CommonController getDictionaryDesc:rowData[@"NeedNumber"] tableName:@"NeedNumber"]];
        [jobDetail appendString:@"|"];
        //学历
        if ([rowData[@"dcEducationID"] isEqualToString:@"100"]) {
            [jobDetail appendString:@"学历不限"];
        }
        else {
            [jobDetail appendString:[CommonController getDictionaryDesc:rowData[@"dcEducationID"] tableName:@"dcEducation"]];
        }
        [jobDetail appendString:@"|"];
        //年龄
        if ([rowData[@"MinAge"] isEqualToString:@"99"] && [rowData[@"MaxAge"] isEqualToString:@"99"]) {
            [jobDetail appendString:@"年龄不限"];
        }
        else if ([rowData[@"MinAge"] isEqualToString:@"99"]) {
            [jobDetail appendFormat:@"%@岁以下",rowData[@"MaxAge"]];
        }
        else if ([rowData[@"MaxAge"] isEqualToString:@"99"]) {
            [jobDetail appendFormat:@"%@岁以上",rowData[@"MinAge"]];
        }
        else {
            [jobDetail appendFormat:@"%@岁~%@岁",rowData[@"MinAge"],rowData[@"MaxAge"]];
        }
        [jobDetail appendString:@"|"];
        //工作经验
        if ([rowData[@"MinExperience"] isEqualToString:@"0"]) {
            [jobDetail appendString:@"工作经验不限"];
        }
        else {
            [jobDetail appendString:[CommonController getDictionaryDesc:rowData[@"MinExperience"] tableName:@"Experience"]];
        }
        [jobDetail appendString:@"|"];
        //月薪
        if ([rowData[@"dcSalaryID"] isEqualToString:@"100"]) {
            [jobDetail appendString:@"月薪面议"];
        }
        else {
            [jobDetail appendString:[CommonController getDictionaryDesc:rowData[@"dcSalaryID"] tableName:@"dcSalary"]];
        }
        [jobDetail appendString:@"|"];
        //刷新时间
        [jobDetail appendString:[CommonController stringFromDate:[CommonController dateFromString:rowData[@"RefreshDate"]] formatType:@"MM-dd HH:mm"]];
        [self.jobDetails addObject:[NSArray arrayWithObjects:rowData[@"JobName"], rowData[@"cpName"], jobDetail, rowData[@"ID"], nil]];
        [jobDetail release];
    }
    [self.lbJobCount setText:[NSString stringWithFormat:@"%d|%d",self.jobNumber,(int)self.jobAnnotations.count]];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (int)slideMenuItem
{
    return 2;
}

- (BOOL)removeSlideGesture
{
    return YES;
}

- (void) closePopupNext
{
    [self.navigationController popViewControllerAnimated:false];
}

- (void) confirmAndCancelPopupNext
{
    [self.viewMap setHidden:false];
    [self.viewMap setZoomLevel:14.07];
    self.viewMap.showMapScaleBar = YES;
    self.locService = [[BMKLocationService alloc] init];
    self.locService.delegate = self;
    self.geocodesearch = [[BMKGeoCodeSearch alloc] init];
    self.geocodesearch.delegate = self;
    //开始定位
    [self.locService startUserLocationService];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.viewMap viewWillAppear];
    self.viewMap.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewMap viewWillDisappear];
    self.locService.delegate = nil;
    self.viewMap.delegate = nil;
    self.geocodesearch.delegate = nil;
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
    [_viewMap release];
    [_locService release];
    [_locPoint release];
    [_annotationViewID release];
    [_geocodesearch release];
    [_lbLocation release];
    [_lbRadius release];
    [_rsType release];
    [_jobAnnotations release];
    [_jobDetails release];
    [_lbPageCount release];
    [_imgPagePrev release];
    [_imgPageNext release];
    [_cPopup release];
    [_viewJobShow release];
    [_lbJobCount release];
    [_lbJobName release];
    [_lbCpName release];
    [_lbJobDetail release];
    [_btnJobShow release];
    [super dealloc];
}
@end
