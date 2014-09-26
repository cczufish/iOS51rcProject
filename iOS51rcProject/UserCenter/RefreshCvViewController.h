//
//  RefreshCvViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-26.
//

#import <UIKit/UIKit.h>

@interface RefreshCvViewController : UIViewController
@property (nonatomic, retain) NSString *mobile;
@property (nonatomic, retain) NSString *cvId;
@property (retain, nonatomic) IBOutlet UIButton *btnRefresh;
@property (retain, nonatomic) IBOutlet UITextField *txtMobile;
@property (retain, nonatomic) IBOutlet UIView *viewMobile;

@end
