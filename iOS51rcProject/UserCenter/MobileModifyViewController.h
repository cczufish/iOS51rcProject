//
//  MobileModifyViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-12.
//

#import <UIKit/UIKit.h>

@interface MobileModifyViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIView *viewMobile;
@property (retain, nonatomic) IBOutlet UITextField *txtMobile;
@property (retain, nonatomic) IBOutlet UIButton *btnModify;
@property (retain, nonatomic) IBOutlet UILabel *lbCeritification;
@property (retain, nonatomic) NSString *mobile;
@property int mobileCertification;
@end
