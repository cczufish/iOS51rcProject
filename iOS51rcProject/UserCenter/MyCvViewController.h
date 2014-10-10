//
//  MyCvViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-12.
//

#import <UIKit/UIKit.h>

@interface MyCvViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollCv;
@property (retain, nonatomic) IBOutlet UIView *viewNoCv;
@property (retain, nonatomic) IBOutlet UIView *viewCvEdit;
@property (retain, nonatomic) IBOutlet UILabel *lbCvCount;
@property (retain, nonatomic) IBOutlet UIView *viewCreate;
@property (retain, nonatomic) IBOutlet UIButton *btnCreateCv;
@property (retain, nonatomic) IBOutlet UIButton *btnConfirmCancel;
@property (retain, nonatomic) IBOutlet UIButton *btnConfirm;
@property (retain, nonatomic) IBOutlet UIView *viewConfirm;
@property (retain, nonatomic) IBOutlet UILabel *lbDeleteInfo;
@property int toastType;

@end
