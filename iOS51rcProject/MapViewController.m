//
//  MapViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-23.
//

#import "MapViewController.h"

@interface MapViewController () <BMKMapViewDelegate>

@end

@implementation MapViewController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.viewMap viewWillAppear];
    self.viewMap.delegate = self;
    
    BMKPointAnnotation *jobPoint = [[[BMKPointAnnotation alloc] init] autorelease];
    CLLocationCoordinate2D jobLocation;
    jobLocation.latitude = self.lat;
    jobLocation.longitude = self.lng;
    jobPoint.coordinate = jobLocation;
    [self.viewMap addAnnotation:jobPoint];
    [self.viewMap setCenterCoordinate:jobLocation animated:true];
    [self.viewMap setZoomLevel:18];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewMap viewWillDisappear];
    self.viewMap.delegate = nil;
}

//添加位置时执行此方法
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    BMKPinAnnotationView *newAnnotation = [[[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"id"] autorelease];
    // 从天上掉下效果
    newAnnotation.animatesDrop = YES;
    // 设置颜色
    [newAnnotation setImage:[UIImage imageNamed:@"ico_mapsearch_pointer_red.png"]];
    newAnnotation.canShowCallout = NO;
    return newAnnotation;
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
    [super dealloc];
}
@end
