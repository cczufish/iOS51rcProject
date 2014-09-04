#import "MapSearchViewController.h"
#import "NetWebServiceRequest.h"
#import "MapSearchListViewController.h"
#import "SlideNavigationController.h"

@interface MapSearchViewController () <BMKMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,NetWebServiceRequestDelegate,SlideNavigationControllerDelegate>
@property (nonatomic, retain) NetWebServiceRequest *runningRequest;
@property int pageNumber;
@property float lat;
@property float lng;
@property float distance;
@property int maxPageNumber;
@property (retain, nonatomic) NSString *rsType;
@property (nonatomic, retain) NSMutableArray *jobAnnotations;
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
    self.jobAnnotations = [NSMutableArray arrayWithCapacity:30];
    [self.viewMap setZoomLevel:14.07];
    _geocodesearch = [[BMKGeoCodeSearch alloc] init];
    self.viewMap.showMapScaleBar = YES;
    self.locService = [[BMKLocationService alloc] init];
    self.locService.delegate = self;
    
    self.pageNumber = 1;
    self.rsType = @"";
    self.distance = 5000;
    //开始定位
    [self.locService startUserLocationService];
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
    self.newAnnotation = [[[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:self.annotationViewID] autorelease];
    // 从天上掉下效果
    ((BMKPinAnnotationView*)self.newAnnotation).animatesDrop = YES;
    // 设置颜色
    ((BMKPinAnnotationView*)self.newAnnotation).pinColor = BMKPinAnnotationColorRed;
    self.newAnnotation.canShowCallout = YES;
    return self.newAnnotation;
}

//点击位置时执行此方法
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    NSLog(@"%@",view.reuseIdentifier);
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
    //将所有标注点删除
    [self.viewMap removeAnnotations:self.jobAnnotations];
    //将数组清除
    [self.jobAnnotations removeAllObjects];
    self.maxPageNumber = 0;
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
        jobPoint.title = rowData[@"JobName"];
        jobPoint.subtitle = rowData[@"cpName"];
        [self.viewMap addAnnotation:jobPoint];
        [self.jobAnnotations addObject:jobPoint];
    }
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.viewMap viewWillAppear];
    self.viewMap.delegate = self;
    self.geocodesearch.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewMap viewWillDisappear];
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
    [_newAnnotation release];
    [_annotationViewID release];
    [_geocodesearch release];
    [_lbLocation release];
    [_lbRadius release];
    [_rsType release];
    [_jobAnnotations release];
    [_lbPageCount release];
    [_imgPagePrev release];
    [_imgPageNext release];
    [super dealloc];
}
@end
