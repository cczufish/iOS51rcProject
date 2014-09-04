#import <UIKit/UIKit.h>
#import "BMapKit.h"

@interface MapSearchViewController : UIViewController
@property (retain, nonatomic) IBOutlet UILabel *lbPageCount;
@property (retain, nonatomic) IBOutlet UILabel *lbLocation;
@property (retain, nonatomic) IBOutlet UILabel *lbRadius;
@property (retain, nonatomic) IBOutlet UIImageView *imgPagePrev;
@property (retain, nonatomic) IBOutlet UIImageView *imgPageNext;
@property (retain, nonatomic) IBOutlet BMKMapView *viewMap;
@property (retain, nonatomic) BMKLocationService *locService;
@property (retain, nonatomic) BMKPointAnnotation *locPoint;
@property (retain, nonatomic) BMKAnnotationView *newAnnotation;
@property (retain, nonatomic) BMKGeoCodeSearch *geocodesearch;
@property (retain, nonatomic) NSString *annotationViewID;
@end
