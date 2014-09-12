//
//  IndexViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 14-9-11.
//  Copyright (c) 2014年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndexViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIView *viewProfile;
@property (retain, nonatomic) IBOutlet UIButton *btnPhoto;
@property (retain, nonatomic) IBOutlet UIView *viewPhotoSelect;
@property (retain, nonatomic) IBOutlet UIButton *btnPhotoCancel;
@property (retain, nonatomic) IBOutlet UILabel *lbPaName;
@property (retain, nonatomic) IBOutlet UILabel *lbEmail;
@property (retain, nonatomic) IBOutlet UILabel *lbMobile;
@property (retain, nonatomic) IBOutlet UIImageView *imgMobileCer;
@property (retain, nonatomic) IBOutlet UIButton *btnMobileModify;
@property (retain, nonatomic) IBOutlet UIButton *btnMobileCertificate;

@end
