//
//  MapViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-23.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@interface MapViewController : UIViewController
@property (retain, nonatomic) IBOutlet BMKMapView *viewMap;
@property float lng;
@property float lat;

@end
