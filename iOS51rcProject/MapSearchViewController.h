#import <UIKit/UIKit.h>
#import "BMapKit.h"

@interface MapSearchViewController : UIViewController
@property (retain, nonatomic) IBOutlet UILabel *lbPageCount;
@property (retain, nonatomic) IBOutlet UILabel *lbLocation;
@property (retain, nonatomic) IBOutlet UILabel *lbRadius;
@property (retain, nonatomic) IBOutlet UIImageView *imgPagePrev;
@property (retain, nonatomic) IBOutlet UIImageView *imgPageNext;
@property (retain, nonatomic) IBOutlet BMKMapView *viewMap;
@property (retain, nonatomic) IBOutlet UIView *viewJobShow;
@property (retain, nonatomic) IBOutlet UILabel *lbJobCount;
@property (retain, nonatomic) IBOutlet UILabel *lbJobName;
@property (retain, nonatomic) IBOutlet UILabel *lbCpName;
@property (retain, nonatomic) IBOutlet UILabel *lbJobDetail;
@property (retain, nonatomic) IBOutlet UIButton *btnJobShow;
@property (retain, nonatomic) BMKLocationService *locService;
@property (retain, nonatomic) BMKPointAnnotation *locPoint;
@property (retain, nonatomic) BMKGeoCodeSearch *geocodesearch;
@property (retain, nonatomic) NSString *annotationViewID;
@end
